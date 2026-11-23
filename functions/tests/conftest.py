"""
Pytest configuration and shared fixtures for oci-functions SSH check test suite.
"""

import sys
import os
import json
from unittest.mock import Mock, patch, MagicMock
import pytest

# Make src/ importable without installation
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

try:
    import rapidjson
except ImportError:
    rapidjson = None


def pytest_configure(config):
    """Set sensible defaults for OCI connectivity."""
    default_oci_config = os.path.expanduser('~/.oci/config')
    if os.path.exists(default_oci_config) and not os.environ.get('OCI_CONFIG_FILE'):
        os.environ['OCI_CONFIG_FILE'] = default_oci_config


# ──────────────────────────────────────────────────────────────────────────────
# Environment fixtures
# ──────────────────────────────────────────────────────────────────────────────

@pytest.fixture
def env_setup(monkeypatch):
    """Minimal environment variables required for the SSH check function."""
    monkeypatch.setenv('OCI_REGION', 'us-ashburn-1')
    monkeypatch.setenv('OCI_COMPARTMENT_ID', 'ocid1.compartment.oc1..test123')
    monkeypatch.setenv('LOG_LEVEL', 'DEBUG')
    monkeypatch.setenv('SSH_CHECK_PORT', '22')
    monkeypatch.setenv('SSH_CHECK_TIMEOUT', '5')

    default_oci_config = os.path.expanduser('~/.oci/config')
    if os.path.exists(default_oci_config):
        monkeypatch.setenv('OCI_CONFIG_FILE', default_oci_config)

    return monkeypatch


# ──────────────────────────────────────────────────────────────────────────────
# Sample node fixtures
# ──────────────────────────────────────────────────────────────────────────────

@pytest.fixture
def sample_node_ok():
    return {
        'node_id': 'ocid1.dbnode.oc1.iad.node001',
        'node_hostname': 'exanode01',
        'ip_address': '10.0.1.11',
        'vm_cluster_id': 'ocid1.cloudvmcluster.oc1.iad.cluster001',
        'vm_cluster_name': 'prod-exacluster-01',
    }


@pytest.fixture
def sample_node_no_ip():
    return {
        'node_id': 'ocid1.dbnode.oc1.iad.node002',
        'node_hostname': 'exanode02',
        'ip_address': '',
        'vm_cluster_id': 'ocid1.cloudvmcluster.oc1.iad.cluster001',
        'vm_cluster_name': 'prod-exacluster-01',
    }


@pytest.fixture
def sample_nodes_list():
    return [
        {
            'node_id': 'ocid1.dbnode.oc1.iad.node001',
            'node_hostname': 'exanode01',
            'ip_address': '10.0.1.11',
            'vm_cluster_id': 'ocid1.cloudvmcluster.oc1.iad.cluster001',
            'vm_cluster_name': 'prod-exacluster-01',
        },
        {
            'node_id': 'ocid1.dbnode.oc1.iad.node002',
            'node_hostname': 'exanode02',
            'ip_address': '10.0.1.12',
            'vm_cluster_id': 'ocid1.cloudvmcluster.oc1.iad.cluster001',
            'vm_cluster_name': 'prod-exacluster-01',
        },
        {
            'node_id': 'ocid1.dbnode.oc1.iad.node003',
            'node_hostname': 'exanode03',
            'ip_address': '10.0.2.11',
            'vm_cluster_id': 'ocid1.cloudvmcluster.oc1.iad.cluster002',
            'vm_cluster_name': 'dev-exacluster-01',
        },
    ]


# ──────────────────────────────────────────────────────────────────────────────
# OCI mock helpers
# ──────────────────────────────────────────────────────────────────────────────

@pytest.fixture
def mock_oci_utils():
    """Patch oci_utils so no real OCI calls are made."""
    with patch('ssh_check.oci_utils') as mock_utils:
        mock_utils.collect_all_exadata_nodes.return_value = []
        mock_utils.post_metric_data.return_value = True
        yield mock_utils


@pytest.fixture
def mock_post_metric_data():
    with patch('oci_utils.post_metric_data') as mock_pmd:
        mock_pmd.return_value = True
        yield mock_pmd

