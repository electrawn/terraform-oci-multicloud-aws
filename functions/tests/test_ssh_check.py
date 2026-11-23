"""
Unit tests for ssh_check.py and func.py.

All external I/O (socket, OCI) is mocked so tests run offline.
"""

import sys
import os
import socket
from unittest.mock import Mock, patch, MagicMock
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from ssh_check import check_ssh, run_ssh_check, _emit_metrics
import ssh_check as ssh_check_module
from config import (
    STATUS_OK_STR,
    STATUS_FAILED_STR,
    SSH_STATUS_OK,
    SSH_STATUS_FAILED,
    OCI_METRIC_NAMESPACE,
    OCI_METRIC_NAME,
)


# ──────────────────────────────────────────────────────────────────────────────
# check_ssh unit tests
# ──────────────────────────────────────────────────────────────────────────────

class TestCheckSsh:

    def test_returns_ok_when_ssh_banner_received(self):
        """check_ssh returns OK when socket returns a valid SSH banner."""
        mock_sock = MagicMock()
        mock_sock.recv.return_value = b'SSH-2.0-OpenSSH_8.9\r\n'
        mock_sock.__enter__ = Mock(return_value=mock_sock)
        mock_sock.__exit__ = Mock(return_value=False)

        with patch('socket.create_connection', return_value=mock_sock):
            result = check_ssh('10.0.1.11')

        assert result['status'] == STATUS_OK_STR
        assert result['reachable'] is True
        assert result['banner'].startswith('SSH-')
        assert result['error'] is None

    def test_returns_failed_when_banner_not_ssh(self):
        """check_ssh returns FAILED when port responds but banner is not SSH."""
        mock_sock = MagicMock()
        mock_sock.recv.return_value = b'HTTP/1.1 200 OK\r\n'
        mock_sock.__enter__ = Mock(return_value=mock_sock)
        mock_sock.__exit__ = Mock(return_value=False)

        with patch('socket.create_connection', return_value=mock_sock):
            result = check_ssh('10.0.1.11')

        assert result['status'] == STATUS_FAILED_STR
        assert result['reachable'] is True
        assert result['error'] == 'SSH banner not received'

    def test_returns_failed_when_connection_refused(self):
        """check_ssh returns FAILED when the connection is refused."""
        with patch('socket.create_connection', side_effect=ConnectionRefusedError('refused')):
            result = check_ssh('10.0.1.11')

        assert result['status'] == STATUS_FAILED_STR
        assert result['reachable'] is False
        assert 'refused' in result['error']

    def test_returns_failed_on_socket_timeout(self):
        """check_ssh returns FAILED on connection timeout."""
        with patch('socket.create_connection', side_effect=socket.timeout('timed out')):
            result = check_ssh('10.0.1.11')

        assert result['status'] == STATUS_FAILED_STR
        assert result['reachable'] is False

    def test_returns_failed_on_general_os_error(self):
        """check_ssh returns FAILED on any OSError."""
        with patch('socket.create_connection', side_effect=OSError('network unreachable')):
            result = check_ssh('10.0.1.11')

        assert result['status'] == STATUS_FAILED_STR
        assert result['reachable'] is False

    def test_returns_failed_when_no_ip_address(self):
        """check_ssh returns FAILED immediately when no IP address is provided."""
        result = check_ssh('')
        assert result['status'] == STATUS_FAILED_STR
        assert result['reachable'] is False
        assert 'No IP address' in result['error']

    def test_returns_failed_when_ip_is_none(self):
        result = check_ssh(None)
        assert result['status'] == STATUS_FAILED_STR

    def test_banner_timeout_treated_as_ok_if_connection_established(self):
        """If the banner read times out (port open) treat it as FAILED (no valid banner)."""
        mock_sock = MagicMock()
        mock_sock.recv.side_effect = socket.timeout('banner timeout')
        mock_sock.__enter__ = Mock(return_value=mock_sock)
        mock_sock.__exit__ = Mock(return_value=False)

        with patch('socket.create_connection', return_value=mock_sock):
            result = check_ssh('10.0.1.11')

        # No banner received => FAILED
        assert result['status'] == STATUS_FAILED_STR
        assert result['reachable'] is True

    def test_uses_custom_port_and_timeout(self):
        """check_ssh passes the port and timeout to socket.create_connection."""
        mock_sock = MagicMock()
        mock_sock.recv.return_value = b'SSH-2.0-custom\r\n'
        mock_sock.__enter__ = Mock(return_value=mock_sock)
        mock_sock.__exit__ = Mock(return_value=False)

        with patch('socket.create_connection', return_value=mock_sock) as mock_conn:
            check_ssh('192.168.1.1', port=2222, timeout=3)

        mock_conn.assert_called_once_with(('192.168.1.1', 2222), timeout=3)


# ──────────────────────────────────────────────────────────────────────────────
# run_ssh_check unit tests
# ──────────────────────────────────────────────────────────────────────────────

class TestRunSshCheck:

    def test_raises_when_no_compartment_id(self, env_setup, monkeypatch):
        """run_ssh_check raises ValueError if compartment_id is not set."""
        monkeypatch.delenv('OCI_COMPARTMENT_ID', raising=False)
        with pytest.raises(ValueError, match='compartment_id'):
            run_ssh_check()

    def test_returns_empty_summary_when_no_nodes(self, env_setup, mock_oci_utils):
        """run_ssh_check returns zero counts when no nodes are found."""
        mock_oci_utils.collect_all_exadata_nodes.return_value = []

        result = run_ssh_check('ocid1.compartment.oc1..test')

        assert result['total'] == 0
        assert result['ok'] == 0
        assert result['failed'] == 0
        assert result['results'] == []

    def test_counts_ok_and_failed_nodes(self, env_setup, mock_oci_utils, sample_nodes_list):
        """run_ssh_check correctly tallies OK and FAILED checks."""
        env_setup.setenv('SSH_CHECK_TARGET', 'primary')  # these fixtures key off the client IP
        mock_oci_utils.collect_all_exadata_nodes.return_value = sample_nodes_list

        def _fake_check_ssh(ip_address, port=22, timeout=10):
            # First node OK, second FAILED, third OK
            if ip_address == '10.0.1.11':
                return {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
            if ip_address == '10.0.1.12':
                return {'status': STATUS_FAILED_STR, 'reachable': False, 'banner': None, 'error': 'timeout'}
            return {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}

        with patch('ssh_check.check_ssh', side_effect=_fake_check_ssh):
            result = run_ssh_check('ocid1.compartment.oc1..test')

        assert result['total'] == 3
        assert result['ok'] == 2
        assert result['failed'] == 1

    def test_result_records_contain_expected_fields(self, env_setup, mock_oci_utils, sample_nodes_list):
        """Each result record must include node_id, hostname, ip, vm_cluster, status."""
        env_setup.setenv('SSH_CHECK_TARGET', 'primary')  # record asserts the client IP
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_nodes_list[0]]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok):
            result = run_ssh_check('ocid1.compartment.oc1..test')

        record = result['results'][0]
        assert record['node_id'] == 'ocid1.dbnode.oc1.iad.node001'
        assert record['node_hostname'] == 'exanode01'
        assert record['ip_address'] == '10.0.1.11'
        assert record['vm_cluster'] == 'prod-exacluster-01'
        assert record['status'] == STATUS_OK_STR

    def test_metrics_published_for_each_node(self, env_setup, mock_oci_utils, sample_nodes_list):
        """post_metric_data is called once with data points for all nodes."""
        mock_oci_utils.collect_all_exadata_nodes.return_value = sample_nodes_list

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok):
            run_ssh_check('ocid1.compartment.oc1..test')

        mock_oci_utils.post_metric_data.assert_called_once()
        call_kwargs = mock_oci_utils.post_metric_data.call_args
        assert call_kwargs[1]['namespace'] == OCI_METRIC_NAMESPACE
        assert call_kwargs[1]['metric_name'] == OCI_METRIC_NAME
        data_points = call_kwargs[1]['data_points']
        assert len(data_points) == 3

    def test_metrics_published_to_metric_compartment_when_set(self, env_setup, mock_oci_utils, sample_node_ok):
        """Nodes are discovered in the DB compartment, but sshstatus is published
        to METRIC_COMPARTMENT_ID (the monitor compartment the alarms read)."""
        env_setup.setenv('METRIC_COMPARTMENT_ID', 'ocid1.compartment.oc1..monitor')
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_node_ok]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok):
            run_ssh_check('ocid1.compartment.oc1..dbcompartment')

        # Discovery still uses the DB compartment...
        assert mock_oci_utils.collect_all_exadata_nodes.call_args[0][0] == 'ocid1.compartment.oc1..dbcompartment'
        # ...but the metric goes to the monitor compartment.
        assert mock_oci_utils.post_metric_data.call_args[1]['compartment_id'] == 'ocid1.compartment.oc1..monitor'

    def test_probes_admin_hostname_by_default(self, env_setup, mock_oci_utils, sample_node_ok):
        """Default targets <hostname>.<SSH_CHECK_DOMAIN> (admin network, where sshd listens)."""
        node = dict(sample_node_ok, vip_address='10.0.0.41')
        env_setup.delenv('SSH_CHECK_TARGET', raising=False)
        env_setup.setenv('SSH_CHECK_DOMAIN', 'admin.example.internal')
        mock_oci_utils.collect_all_exadata_nodes.return_value = [node]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok) as probe:
            result = run_ssh_check('ocid1.compartment.oc1..test')

        expected = '{0}.admin.example.internal'.format(sample_node_ok['node_hostname'])
        assert probe.call_args[0][0] == expected
        assert result['results'][0]['ip_address'] == expected

    def test_probes_primary_ip_when_target_primary(self, env_setup, mock_oci_utils, sample_node_ok):
        node = dict(sample_node_ok, vip_address='10.0.0.41')
        env_setup.setenv('SSH_CHECK_TARGET', 'primary')
        mock_oci_utils.collect_all_exadata_nodes.return_value = [node]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok) as probe:
            run_ssh_check('ocid1.compartment.oc1..test')

        assert probe.call_args[0][0] == sample_node_ok['ip_address']

    def test_probes_vip_when_target_vip(self, env_setup, mock_oci_utils, sample_node_ok):
        node = dict(sample_node_ok, vip_address='10.0.0.41')
        env_setup.setenv('SSH_CHECK_TARGET', 'vip')
        mock_oci_utils.collect_all_exadata_nodes.return_value = [node]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok) as probe:
            run_ssh_check('ocid1.compartment.oc1..test')

        assert probe.call_args[0][0] == '10.0.0.41'

    def test_vip_target_falls_back_to_primary_ip_when_no_vip(self, env_setup, mock_oci_utils, sample_node_ok):
        node = dict(sample_node_ok, vip_address='')
        env_setup.setenv('SSH_CHECK_TARGET', 'vip')
        mock_oci_utils.collect_all_exadata_nodes.return_value = [node]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok) as probe:
            run_ssh_check('ocid1.compartment.oc1..test')

        assert probe.call_args[0][0] == sample_node_ok['ip_address']

    def test_metrics_fall_back_to_discovery_compartment(self, env_setup, mock_oci_utils, sample_node_ok):
        """Without METRIC_COMPARTMENT_ID, publishing falls back to the discovery compartment."""
        env_setup.delenv('METRIC_COMPARTMENT_ID', raising=False)
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_node_ok]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok):
            run_ssh_check('ocid1.compartment.oc1..dbcompartment')

        assert mock_oci_utils.post_metric_data.call_args[1]['compartment_id'] == 'ocid1.compartment.oc1..dbcompartment'

    def test_metric_data_point_dimensions(self, env_setup, mock_oci_utils, sample_node_ok):
        """Metric dimensions must include node_id, node_hostname, ip_address, status, vm_cluster."""
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_node_ok]

        mock_ssh_ok = {'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}
        with patch('ssh_check.check_ssh', return_value=mock_ssh_ok):
            run_ssh_check('ocid1.compartment.oc1..test')

        data_points = mock_oci_utils.post_metric_data.call_args[1]['data_points']
        dims = data_points[0]['dimensions']
        assert 'node_id' in dims
        assert 'node_hostname' in dims
        assert 'ip_address' in dims
        assert 'status' in dims
        assert 'vm_cluster' in dims
        assert dims['status'] == STATUS_OK_STR

    def test_metric_value_is_zero_for_ok(self, env_setup, mock_oci_utils, sample_node_ok):
        """Metric value should be 0.0 when SSH check is OK."""
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_node_ok]

        with patch('ssh_check.check_ssh',
                   return_value={'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}):
            run_ssh_check('ocid1.compartment.oc1..test')

        data_points = mock_oci_utils.post_metric_data.call_args[1]['data_points']
        assert data_points[0]['value'] == float(SSH_STATUS_OK)

    def test_metric_value_is_one_for_failed(self, env_setup, mock_oci_utils, sample_node_ok):
        """Metric value should be 1.0 when SSH check fails."""
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_node_ok]

        with patch('ssh_check.check_ssh',
                   return_value={'status': STATUS_FAILED_STR, 'reachable': False, 'banner': None, 'error': 'refused'}):
            run_ssh_check('ocid1.compartment.oc1..test')

        data_points = mock_oci_utils.post_metric_data.call_args[1]['data_points']
        assert data_points[0]['value'] == float(SSH_STATUS_FAILED)

    def test_node_with_no_ip_produces_failed_result(self, env_setup, mock_oci_utils, sample_node_no_ip):
        """A node with no IP address should still produce a FAILED metric entry."""
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_node_no_ip]

        result = run_ssh_check('ocid1.compartment.oc1..test')

        assert result['failed'] == 1
        assert result['ok'] == 0

    def test_emit_metrics_does_not_raise_on_failure(self, env_setup, mock_oci_utils, sample_node_ok):
        """If metric publishing fails, run_ssh_check should not propagate the error."""
        mock_oci_utils.collect_all_exadata_nodes.return_value = [sample_node_ok]
        mock_oci_utils.post_metric_data.side_effect = Exception('OCI API error')

        with patch('ssh_check.check_ssh',
                   return_value={'status': STATUS_OK_STR, 'reachable': True, 'banner': 'SSH-2.0', 'error': None}):
            # Should not raise
            result = run_ssh_check('ocid1.compartment.oc1..test')

        assert result['total'] == 1


# ──────────────────────────────────────────────────────────────────────────────
# func.py handler tests
# ──────────────────────────────────────────────────────────────────────────────

class TestFuncHandler:

    def _make_ctx(self, request_id='test-req-001'):
        ctx = Mock()
        ctx.request_id = request_id
        ctx.call_id = request_id
        ctx.id = request_id
        return ctx

    @patch('ssh_check.run_ssh_check')
    def test_handler_returns_summary(self, mock_run, env_setup):
        """handler() should return status/ok/failed summary."""
        import func
        mock_run.return_value = {'total': 3, 'ok': 2, 'failed': 1, 'results': []}

        result = func.handler(self._make_ctx())

        assert result['status'] == 'ok'
        assert result['total'] == 3
        assert result['ok'] == 2
        assert result['failed'] == 1

    @patch('ssh_check.run_ssh_check')
    def test_handler_passes_compartment_id_from_payload(self, mock_run, env_setup):
        """handler() should pass compartment_id from JSON body to run_ssh_check."""
        import func
        mock_run.return_value = {'total': 0, 'ok': 0, 'failed': 0, 'results': []}

        import json
        payload = json.dumps({'compartment_id': 'ocid1.compartment.oc1..custom'})
        func.handler(self._make_ctx(), data=payload.encode('utf-8'))

        mock_run.assert_called_once_with(compartment_id='ocid1.compartment.oc1..custom')

    @patch('ssh_check.run_ssh_check')
    def test_handler_handles_none_data(self, mock_run, env_setup):
        """handler() with no data body should still call run_ssh_check with None compartment."""
        import func
        mock_run.return_value = {'total': 0, 'ok': 0, 'failed': 0, 'results': []}

        func.handler(self._make_ctx(), data=None)

        mock_run.assert_called_once_with(compartment_id=None)

    @patch('ssh_check.run_ssh_check')
    def test_handler_accepts_file_like_data(self, mock_run, env_setup):
        """handler() should work with BytesIO (OCI FDK passes a file-like object)."""
        import func
        import io
        mock_run.return_value = {'total': 1, 'ok': 1, 'failed': 0, 'results': []}

        data = io.BytesIO(b'{}')
        result = func.handler(self._make_ctx(), data=data)

        assert result['status'] == 'ok'



# ──────────────────────────────────────────────────────────────────────────────
# oci_utils node IP resolution (VNIC-based) tests
# ──────────────────────────────────────────────────────────────────────────────

class TestNodeIpResolution:
    """DB node IPs are resolved via the node's VNIC, not a node attribute."""

    def test_get_db_node_ip_resolves_via_vnic(self):
        import oci_utils
        node = Mock()
        node.vnic_id = 'ocid1.vnic.oc1..node1'
        mock_vnic = Mock()
        mock_vnic.private_ip = '10.0.128.112'
        mock_net = Mock()
        mock_net.get_vnic.return_value = Mock(data=mock_vnic)

        with patch('oci_utils.get_network_client', return_value=mock_net):
            ip = oci_utils.get_db_node_ip(node)

        assert ip == '10.0.128.112'
        mock_net.get_vnic.assert_called_once_with(vnic_id='ocid1.vnic.oc1..node1')

    def test_get_db_node_ip_empty_when_no_vnic(self):
        import oci_utils
        node = Mock()
        node.vnic_id = ''
        assert oci_utils.get_db_node_ip(node) == ''

    def test_get_db_node_ip_empty_on_vnic_error(self):
        import oci_utils
        node = Mock()
        node.vnic_id = 'ocid1.vnic.oc1..node1'
        mock_net = Mock()
        mock_net.get_vnic.side_effect = Exception('404 not found')

        with patch('oci_utils.get_network_client', return_value=mock_net):
            assert oci_utils.get_db_node_ip(node) == ''

    def test_collect_nodes_populates_ip_from_vnic(self):
        import oci_utils
        cluster = Mock()
        cluster.id = 'ocid1.cloudvmcluster.oc1..c1'
        cluster.display_name = 'exa1vmc1'

        node = Mock()
        node.id = 'ocid1.dbnode.oc1..n1'
        node.hostname = 'exa1vmc1-node1'
        node.vnic_id = 'ocid1.vnic.oc1..v1'

        with patch('oci_utils.list_cloud_vm_clusters', return_value=[cluster]), \
             patch('oci_utils.list_db_nodes_for_vm_cluster', return_value=[node]), \
             patch('oci_utils.get_db_node_ip', return_value='10.0.128.112'):
            nodes = oci_utils.collect_all_exadata_nodes('ocid1.compartment.oc1..test')

        assert len(nodes) == 1
        assert nodes[0]['ip_address'] == '10.0.128.112'
        assert nodes[0]['node_hostname'] == 'exa1vmc1-node1'
        assert nodes[0]['vm_cluster_name'] == 'exa1vmc1'

    def test_collect_nodes_filters_by_vm_cluster_name(self):
        import oci_utils
        sbx = Mock(); sbx.id = 'c-sbx'; sbx.display_name = 'exa1vmc1'
        prd = Mock(); prd.id = 'c-prd'; prd.display_name = 'exa1vmc1'

        def _nodes_for(compartment_id, vm_cluster_id):
            n = Mock(); n.id = 'n-' + vm_cluster_id; n.hostname = vm_cluster_id + '-1'
            n.vnic_id = 'v-' + vm_cluster_id
            return [n]

        with patch('oci_utils.list_cloud_vm_clusters', return_value=[sbx, prd]), \
             patch('oci_utils.list_db_nodes_for_vm_cluster', side_effect=_nodes_for), \
             patch('oci_utils.get_db_node_ip', return_value='10.0.128.112'):
            nodes = oci_utils.collect_all_exadata_nodes(
                'ocid1.compartment.oc1..test', vm_cluster_name='exa1vmc1'
            )

        # Only the sbx cluster's node should be returned, not the prod cluster's.
        assert len(nodes) == 1
        assert nodes[0]['vm_cluster_name'] == 'exa1vmc1'
