"""OCI SDK helper utilities for oci-functions.

Provides authenticated clients for:
  - OCI Vault / Secrets Service
  - OCI Database Service (DbNodes, VM Clusters, Cloud Exadata)
  - OCI Monitoring Service (custom metrics)
"""
import os

from logger import log

log = log()

try:
    import oci
except ImportError:
    oci = None


def is_available():
    return oci is not None


def _get_signer_and_config():
    if oci is None:
        raise RuntimeError('oci SDK is not available in this runtime')

    try:
        signer = oci.auth.signers.get_resource_principals_signer()
    except Exception:
        signer = None

    if signer is not None:
        return signer, {}

    config_file = os.environ.get('OCI_CONFIG_FILE')
    profile = os.environ.get('OCI_CONFIG_PROFILE', 'DEFAULT')
    try:
        config = oci.config.from_file(file_location=config_file, profile_name=profile)
    except Exception as err:
        raise RuntimeError(
            'Unable to initialize OCI signer or config: {err}'.format(err=err)
        )

    return None, config


def _client_kwargs():
    signer, config = _get_signer_and_config()
    kwargs = {'config': config}
    if signer is not None:
        kwargs['signer'] = signer
    return kwargs


# ──────────────────────────────────────────────────────────────────────────────
# Secrets / Vault
# ──────────────────────────────────────────────────────────────────────────────

def get_secret_value(secret_id):
    """Decode and return the plaintext value of an OCI Vault secret."""
    import base64
    kwargs = _client_kwargs()
    client = oci.secrets.SecretsClient(**kwargs)
    response = client.get_secret_bundle(secret_id=secret_id)
    bundle_content = response.data.secret_bundle_content

    if hasattr(bundle_content, 'content'):
        decoded = base64.b64decode(bundle_content.content)
        try:
            return decoded.decode('utf-8')
        except UnicodeDecodeError:
            return decoded.decode('utf-8', errors='replace')

    raise RuntimeError(
        'OCI secret bundle for {secret_id} did not contain decodable content'.format(
            secret_id=secret_id
        )
    )


# ──────────────────────────────────────────────────────────────────────────────
# Database Service – Exadata / VM-Cluster DB nodes
# ──────────────────────────────────────────────────────────────────────────────

def get_database_client():
    """Return an OCI DatabaseClient or None if SDK is unavailable."""
    if oci is None:
        log.debug('OCI SDK not available; cannot create DatabaseClient')
        return None
    try:
        return oci.database.DatabaseClient(**_client_kwargs())
    except Exception as err:
        log.error('Failed to create OCI DatabaseClient: {err}'.format(err=err))
        return None


def get_network_client():
    """Return an OCI VirtualNetworkClient or None if SDK is unavailable."""
    if oci is None:
        log.debug('OCI SDK not available; cannot create VirtualNetworkClient')
        return None
    try:
        return oci.core.VirtualNetworkClient(**_client_kwargs())
    except Exception as err:
        log.error('Failed to create OCI VirtualNetworkClient: {err}'.format(err=err))
        return None


def get_db_node_ip(db_node):
    """Resolve a DB node's client private IP.

    OCI DbNode resources do not expose an IP attribute directly; the address is
    reached via the node's primary VNIC (``vnic_id``). This fetches that VNIC
    and returns its private IP. A backup VNIC (``backup_vnic_id``) is ignored.
    """
    vnic_id = getattr(db_node, 'vnic_id', '') or ''
    if not vnic_id:
        return ''

    net_client = get_network_client()
    if net_client is None:
        return ''

    try:
        vnic = net_client.get_vnic(vnic_id=vnic_id).data
        return getattr(vnic, 'private_ip', '') or ''
    except Exception as err:
        log.error(
            'Failed to resolve IP for DB node VNIC {vnic_id}: {err}'.format(
                vnic_id=vnic_id, err=err
            )
        )
        return ''


def get_db_node_vip(db_node, hostname=''):
    """Resolve a DB node's own Clusterware VIP address.

    Exadata DB nodes carry several private IPs on the client VNIC: the primary
    (node) IP, the node VIP (hostname label ``<hostname>-vip``) and possibly a
    SCAN IP. From the ODB client subnet, traffic to the node's PRIMARY IP is
    dropped on every port by the guest, while the VIP and SCAN addresses
    answer. So connectivity probes must target the node VIP.

    Returns the VIP address, or '' if it cannot be determined.
    """
    vnic_id = getattr(db_node, 'vnic_id', '') or ''
    if not vnic_id:
        return ''

    net_client = get_network_client()
    if net_client is None:
        return ''

    try:
        private_ips = oci.pagination.list_call_get_all_results(
            net_client.list_private_ips,
            vnic_id=vnic_id,
        ).data
    except Exception as err:
        log.error(
            'Failed to list private IPs for DB node VNIC {vnic_id}: {err}'.format(
                vnic_id=vnic_id, err=err
            )
        )
        return ''

    wanted = '{0}-vip'.format(hostname).lower() if hostname else ''
    fallback = ''
    for pip in private_ips:
        label = (getattr(pip, 'hostname_label', '') or '').lower()
        address = getattr(pip, 'ip_address', '') or ''
        if not address or not label.endswith('-vip'):
            continue
        if wanted and label == wanted:
            return address
        fallback = fallback or address
    return fallback


def list_cloud_vm_clusters(compartment_id):
    """List all Cloud VM Clusters in a compartment.

    Returns a list of CloudVmClusterSummary objects (may be empty).
    """
    client = get_database_client()
    if client is None:
        return []

    try:
        response = oci.pagination.list_call_get_all_results(
            client.list_cloud_vm_clusters,
            compartment_id=compartment_id,
        )
        return [
            item for item in response.data
            if getattr(item, 'lifecycle_state', '') not in ('TERMINATED', 'TERMINATING')
        ]
    except Exception as err:
        log.error('Failed to list Cloud VM Clusters: {err}'.format(err=err))
        return []


def list_db_nodes_for_vm_cluster(compartment_id, vm_cluster_id):
    """List all DB nodes that belong to a Cloud VM Cluster.

    Returns a list of DbNodeSummary objects.
    """
    client = get_database_client()
    if client is None:
        return []

    try:
        response = oci.pagination.list_call_get_all_results(
            client.list_db_nodes,
            compartment_id=compartment_id,
            vm_cluster_id=vm_cluster_id,
        )
        return [
            item for item in response.data
            if getattr(item, 'lifecycle_state', '') not in ('TERMINATED', 'TERMINATING')
        ]
    except Exception as err:
        log.error(
            'Failed to list DB nodes for VM cluster {vm_cluster_id}: {err}'.format(
                vm_cluster_id=vm_cluster_id, err=err
            )
        )
        return []


def get_db_node_details(db_node_id):
    """Fetch full details of a single DB node (includes hostname and IPs)."""
    client = get_database_client()
    if client is None:
        return None
    try:
        return client.get_db_node(db_node_id=db_node_id).data
    except Exception as err:
        log.error(
            'Failed to get DB node details for {db_node_id}: {err}'.format(
                db_node_id=db_node_id, err=err
            )
        )
        return None


def collect_all_exadata_nodes(compartment_id, vm_cluster_name=None):
    """Return a list of dicts describing Exadata DB nodes in a compartment.

    Each dict contains:
        node_id       – OCID of the DB node
        node_hostname – hostname of the DB node
        ip_address    – client/private IP address
        vm_cluster_id – OCID of the parent VM cluster
        vm_cluster_name – display name of the parent VM cluster

    If ``vm_cluster_name`` is provided, only nodes belonging to the VM cluster
    with that display name are returned. This scopes the check to a single
    cluster when a compartment holds several (e.g. prod + dev + sbx clusters),
    avoiding slow, unreachable probes against unrelated clusters.
    """
    vm_clusters = list_cloud_vm_clusters(compartment_id)
    if vm_cluster_name:
        wanted = vm_cluster_name.strip().lower()
        vm_clusters = [
            c for c in vm_clusters
            if (getattr(c, 'display_name', '') or '').strip().lower() == wanted
        ]
    log.info(
        'Found {n} active Cloud VM Clusters in compartment {cid}{scope}'.format(
            n=len(vm_clusters),
            cid=compartment_id,
            scope=' (filtered to {0})'.format(vm_cluster_name) if vm_cluster_name else '',
        )
    )

    nodes = []
    for cluster in vm_clusters:
        cluster_id = cluster.id
        cluster_name = getattr(cluster, 'display_name', cluster_id)
        db_nodes = list_db_nodes_for_vm_cluster(compartment_id, cluster_id)

        for node in db_nodes:
            node_id = node.id
            hostname = getattr(node, 'hostname', '') or ''

            # OCI DbNode resources do not carry an IP attribute; the client IP
            # is resolved via the node's primary VNIC (vnic_id). Fetch full
            # details when the summary lacks vnic_id/hostname, then resolve the
            # VNIC's private IP.
            details = None
            if not getattr(node, 'vnic_id', '') or not hostname:
                details = get_db_node_details(node_id)
                if details:
                    hostname = hostname or getattr(details, 'hostname', '') or ''

            ip_address = get_db_node_ip(node)
            if not ip_address and details is not None:
                ip_address = get_db_node_ip(details)

            vip_address = get_db_node_vip(node, hostname)
            if not vip_address and details is not None:
                vip_address = get_db_node_vip(details, hostname)

            nodes.append({
                'node_id': node_id,
                'node_hostname': hostname,
                'ip_address': ip_address,
                'vip_address': vip_address,
                'vm_cluster_id': cluster_id,
                'vm_cluster_name': cluster_name,
            })

    log.info('Collected {n} Exadata DB nodes'.format(n=len(nodes)))
    return nodes


# ──────────────────────────────────────────────────────────────────────────────
# Monitoring Service – custom metrics
# ──────────────────────────────────────────────────────────────────────────────

def get_monitoring_client():
    """Return an OCI MonitoringClient configured for metric *ingestion*.

    Posting custom metrics (post_metric_data) must go to the Telemetry
    *ingestion* endpoint (telemetry-ingestion.<region>.oraclecloud.com), not the
    default telemetry (query) endpoint. Without this override OCI rejects the
    post with 404 NotAuthorizedOrNotFound ("Incorrect Telemetry endpoint").
    """
    if oci is None:
        log.debug('OCI SDK not available; cannot create MonitoringClient')
        return None
    try:
        kwargs = _client_kwargs()
        client = oci.monitoring.MonitoringClient(**kwargs)
        region = _monitoring_region(kwargs)
        if region:
            client.base_client.endpoint = (
                'https://telemetry-ingestion.{region}.oraclecloud.com'.format(region=region)
            )
        return client
    except Exception as err:
        log.error('Failed to create OCI MonitoringClient: {err}'.format(err=err))
        return None


def _monitoring_region(kwargs):
    """Best-effort resolution of the region for the telemetry-ingestion endpoint."""
    # Prefer an explicit env var, then the signer/config region.
    region = os.environ.get('OCI_REGION', '') or os.environ.get('OCI_REGION_ID', '')
    if region:
        return region
    config = kwargs.get('config') or {}
    if isinstance(config, dict):
        return config.get('region', '') or ''
    return getattr(config, 'region', '') or ''


# Maximum metric objects per PostMetricData request (OCI API limit).
POST_METRIC_DATA_MAX_BATCH = 50


def post_metric_data(compartment_id, namespace, metric_name, data_points):
    """Publish a batch of custom metric data points to OCI Monitoring.

    Args:
        compartment_id (str): Target compartment OCID.
        namespace      (str): Custom metric namespace (e.g. 'example_oracledb_aws').
        metric_name    (str): Metric name (e.g. 'sshstatus').
        data_points    (list[dict]): Each dict:
            {
              'dimensions': {'dim_key': 'dim_value', ...},
              'value':      <float>,           # numeric metric value
              'timestamp':  <datetime | None>, # None = now
            }

    Returns:
        bool: True on success, False on failure.
    """
    client = get_monitoring_client()
    if client is None:
        return False

    import datetime

    metric_data_details_list = []
    for dp in data_points:
        dimensions = dp.get('dimensions', {})
        value = float(dp.get('value', 0))
        ts = dp.get('timestamp') or datetime.datetime.now(datetime.timezone.utc)

        datapoint = oci.monitoring.models.Datapoint(
            timestamp=ts,
            value=value,
        )
        metric_data_details_list.append(
            oci.monitoring.models.MetricDataDetails(
                namespace=namespace,
                compartment_id=compartment_id,
                name=metric_name,
                dimensions=dimensions,
                datapoints=[datapoint],
            )
        )

    if not metric_data_details_list:
        log.debug('No metric data points to publish')
        return True

    # OCI PostMetricData accepts at most POST_METRIC_DATA_MAX_BATCH metric
    # objects per request; a larger request is rejected outright (nothing is
    # published). Send in chunks and treat any rejected chunk or any
    # per-metric failure as an overall failure so callers can surface it.
    total = len(metric_data_details_list)
    all_ok = True
    published = 0
    for start in range(0, total, POST_METRIC_DATA_MAX_BATCH):
        chunk = metric_data_details_list[start:start + POST_METRIC_DATA_MAX_BATCH]
        post_metric_data_details = oci.monitoring.models.PostMetricDataDetails(
            metric_data=chunk,
        )
        try:
            response = client.post_metric_data(
                post_metric_data_details=post_metric_data_details
            )
        except Exception as err:
            all_ok = False
            log.error(
                'Failed to publish metric batch {first}-{last} of {total} to '
                '{ns}.{metric}: {err}'.format(
                    first=start + 1, last=start + len(chunk), total=total,
                    ns=namespace, metric=metric_name, err=err,
                )
            )
            continue

        failed = getattr(response.data, 'failed_metrics_count', 0) or 0
        published += len(chunk) - failed
        if failed:
            all_ok = False
            log.warning(
                'Metric batch {first}-{last} of {total} to {ns}.{metric} had '
                '{n} rejected metrics: {details}'.format(
                    first=start + 1, last=start + len(chunk), total=total,
                    ns=namespace, metric=metric_name, n=failed,
                    details=getattr(response.data, 'failed_metrics', None),
                )
            )

    if all_ok:
        log.info(
            'Successfully published {n} data points to {ns}.{metric}'.format(
                n=total, ns=namespace, metric=metric_name
            )
        )
    else:
        log.error(
            'Published only {ok} of {total} data points to {ns}.{metric}'.format(
                ok=published, total=total, ns=namespace, metric=metric_name
            )
        )
    return all_ok
