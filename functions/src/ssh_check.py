"""SSH Check – Nagios-style SSH port reachability check for OCI Exadata nodes.

Flow:
  1. Read the target compartment from the environment.
  2. Query OCI Database Service for all Cloud VM Clusters and their DB nodes.
  3. For each node, attempt a TCP connection to port 22 and read the SSH
     banner. sshd listens on the admin network, so the default target is
     <node_hostname>.<SSH_CHECK_DOMAIN> (SSH_CHECK_TARGET=admin, domain default
     admin.example.internal). SSH_CHECK_TARGET=primary|vip target the client primary
     IP or node VIP instead.
  4. Emit a custom OCI metric ``sshstatus`` in namespace ``example_oracledb_aws``.
  5. Return a summary of results.

Metric shape:
  Namespace  : example_oracledb_aws
  Name       : sshstatus
  Value      : 0 = OK  /  1 = FAILED
  Dimensions :
    node_id       – DB node OCID
    node_hostname – node hostname
    ip_address    – client IP
    status        – "OK" or "FAILED"
    vm_cluster    – display name of the parent VM cluster
"""

import os
import socket
import datetime

from logger import log
from config import (
    SSH_CHECK_PORT,
    SSH_CHECK_TIMEOUT_SECONDS,
    SSH_BANNER_TIMEOUT_SECONDS,
    OCI_METRIC_NAMESPACE,
    OCI_METRIC_NAME,
    SSH_STATUS_OK,
    SSH_STATUS_FAILED,
    STATUS_OK_STR,
    STATUS_FAILED_STR,
)
import oci_utils

log = log()


# ──────────────────────────────────────────────────────────────────────────────
# SSH / TCP connectivity check
# ──────────────────────────────────────────────────────────────────────────────

def check_ssh(ip_address, port=None, timeout=None):
    """Check whether an SSH daemon is reachable at *ip_address*:*port*.

    The function opens a TCP connection and reads the SSH banner
    (expected to start with ``SSH-``).  A missing banner is still treated
    as FAILED even though the port is open.

    Args:
        ip_address (str): Target IP address.
        port       (int): TCP port (default: SSH_CHECK_PORT from config).
        timeout    (int): Connection timeout in seconds.

    Returns:
        dict:
            {
              'status':        'OK' | 'FAILED',
              'reachable':     bool,
              'banner':        str | None,
              'error':         str | None,
            }
    """
    port = port or SSH_CHECK_PORT
    timeout = timeout if timeout is not None else SSH_CHECK_TIMEOUT_SECONDS

    if not ip_address:
        return {
            'status': STATUS_FAILED_STR,
            'reachable': False,
            'banner': None,
            'error': 'No IP address provided',
        }

    try:
        with socket.create_connection((ip_address, port), timeout=timeout) as sock:
            sock.settimeout(SSH_BANNER_TIMEOUT_SECONDS)
            try:
                banner_bytes = sock.recv(256)
                banner = banner_bytes.decode('utf-8', errors='replace').strip()
            except socket.timeout:
                banner = ''

        if banner.startswith('SSH-'):
            return {
                'status': STATUS_OK_STR,
                'reachable': True,
                'banner': banner,
                'error': None,
            }
        # Port open but no valid SSH banner
        return {
            'status': STATUS_FAILED_STR,
            'reachable': True,
            'banner': banner or None,
            'error': 'SSH banner not received',
        }

    except (socket.timeout, ConnectionRefusedError, OSError) as err:
        return {
            'status': STATUS_FAILED_STR,
            'reachable': False,
            'banner': None,
            'error': str(err),
        }


# ──────────────────────────────────────────────────────────────────────────────
# Orchestration
# ──────────────────────────────────────────────────────────────────────────────

def run_ssh_check(compartment_id=None):
    """Run the full SSH-check pass across all Exadata nodes in a compartment.

    Args:
        compartment_id (str | None): OCI compartment OCID.  Falls back to the
            ``OCI_COMPARTMENT_ID`` environment variable.

    Returns:
        dict:
            {
              'total':   int,
              'ok':      int,
              'failed':  int,
              'results': [ { node_info + ssh result } ],
            }
    """
    compartment_id = compartment_id or os.environ.get('OCI_COMPARTMENT_ID', '')
    if not compartment_id:
        raise ValueError(
            'compartment_id must be supplied or OCI_COMPARTMENT_ID env var must be set'
        )

    port = int(os.environ.get('SSH_CHECK_PORT', SSH_CHECK_PORT))
    timeout = int(os.environ.get('SSH_CHECK_TIMEOUT', SSH_CHECK_TIMEOUT_SECONDS))
    # Optional: scope the check to a single VM cluster by display name. When a
    # compartment holds several clusters (prod/dev/sbx), this avoids slow,
    # unreachable probes against unrelated clusters.
    vm_cluster_name = os.environ.get('SSH_CHECK_VM_CLUSTER_NAME', '').strip() or None

    log.info(
        'Starting SSH check for Exadata nodes in compartment={cid} port={port}{scope}'.format(
            cid=compartment_id,
            port=port,
            scope=' cluster={0}'.format(vm_cluster_name) if vm_cluster_name else '',
        )
    )

    nodes = oci_utils.collect_all_exadata_nodes(compartment_id, vm_cluster_name=vm_cluster_name)
    if not nodes:
        log.warning('No Exadata nodes found – nothing to check')
        return {'total': 0, 'ok': 0, 'failed': 0, 'results': []}

    results = []
    ok_count = 0
    failed_count = 0
    metric_data_points = []
    now = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)

    # Which node address to probe for SSH.
    #
    # sshd on these Exadata nodes listens on the ADMIN network
    # (<hostname>.admin.example.internal), NOT on the client-VNIC primary IP or the
    # VIP. Verified from inside the function subnet: admin hostname:22 answers
    # with an SSH banner, the client primary IP times out, and the VIP refuses
    # 22. So by default we build the target from the node hostname plus
    # SSH_CHECK_DOMAIN (admin DNS domain) and resolve it over DNS.
    #
    # Fallbacks for other topologies:
    #   SSH_CHECK_TARGET=primary  -> node client primary IP
    #   SSH_CHECK_TARGET=vip      -> node VIP
    #   SSH_CHECK_TARGET=admin    -> <hostname>.<SSH_CHECK_DOMAIN> (default)
    target_mode = os.environ.get('SSH_CHECK_TARGET', 'admin').strip().lower()
    ssh_domain = os.environ.get('SSH_CHECK_DOMAIN', 'admin.example.internal').strip().strip('.')

    for node in nodes:
        node_id = node['node_id']
        hostname = node['node_hostname']
        if target_mode == 'vip':
            ip_address = node.get('vip_address') or node['ip_address']
        elif target_mode == 'primary':
            ip_address = node['ip_address']
        else:  # 'admin' (default): resolve <hostname>.<domain>
            ip_address = '{0}.{1}'.format(hostname, ssh_domain) if (hostname and ssh_domain) else (node.get('vip_address') or node['ip_address'])
        vm_cluster = node.get('vm_cluster_name', '')

        log.debug(
            'Checking SSH on node {hostname} ({ip})'.format(
                hostname=hostname, ip=ip_address
            )
        )

        check_result = check_ssh(ip_address, port=port, timeout=timeout)
        status = check_result['status']

        if status == STATUS_OK_STR:
            ok_count += 1
            metric_value = SSH_STATUS_OK
            log.info(
                'SSH OK  – node={hostname} ip={ip} banner={banner}'.format(
                    hostname=hostname,
                    ip=ip_address,
                    banner=check_result.get('banner', ''),
                )
            )
        else:
            failed_count += 1
            metric_value = SSH_STATUS_FAILED
            log.warning(
                'SSH FAILED – node={hostname} ip={ip} error={err}'.format(
                    hostname=hostname,
                    ip=ip_address,
                    err=check_result.get('error', ''),
                )
            )

        result_record = {
            'node_id': node_id,
            'node_hostname': hostname,
            'ip_address': ip_address,
            'vm_cluster': vm_cluster,
            'status': status,
            'reachable': check_result['reachable'],
            'banner': check_result.get('banner'),
            'error': check_result.get('error'),
        }
        results.append(result_record)

        # Build metric data point
        # OCI Monitoring dimension values are strings; node_id can be long so
        # we truncate to 256 chars if needed.
        metric_data_points.append({
            'dimensions': {
                'node_id': node_id[:256],
                'node_hostname': hostname[:256] if hostname else 'unknown',
                'ip_address': ip_address[:64] if ip_address else 'unknown',
                'status': status,
                'vm_cluster': vm_cluster[:256] if vm_cluster else 'unknown',
            },
            'value': float(metric_value),
            'timestamp': now,
        })

    # Publish all metrics in one batch call. Discovery and publishing can use
    # different compartments: nodes are discovered in the DB compartment
    # (OCI_COMPARTMENT_ID), but the metric belongs in the monitor compartment
    # (METRIC_COMPARTMENT_ID) next to the other ocidb-monitoring metrics and
    # the alarms that consume them. Falls back to the discovery compartment.
    metric_compartment_id = os.environ.get('METRIC_COMPARTMENT_ID', '').strip() or compartment_id
    metric_emitted = _emit_metrics(metric_compartment_id, metric_data_points)

    summary = {
        'total': len(nodes),
        'ok': ok_count,
        'failed': failed_count,
        'metric_emitted': metric_emitted,
        'results': results,
    }
    log.info(
        'SSH check complete: total={total} ok={ok} failed={failed}'.format(
            **summary
        )
    )
    return summary


def _emit_metrics(compartment_id, data_points):
    """Publish sshstatus metric data points; log but do not raise on failure.

    Returns True when every data point was published (or there were none).
    """
    if not data_points:
        return True
    try:
        return bool(oci_utils.post_metric_data(
            compartment_id=compartment_id,
            namespace=OCI_METRIC_NAMESPACE,
            metric_name=OCI_METRIC_NAME,
            data_points=data_points,
        ))
    except Exception as err:
        log.error('Failed to emit SSH status metrics: {err}'.format(err=err))
        return False

