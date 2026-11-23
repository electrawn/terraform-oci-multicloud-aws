"""OCI Functions entry-point for SSH status checks.

The OCI Functions FDK calls handler(ctx, data) on each invocation.
This handler executes the Exadata SSH connectivity check and returns a
status-wrapped summary that matches the existing unit tests.
"""
try:
    import rapidjson as json
except ImportError:
    import json

import ssh_check


def handler(ctx, data=None):
    """OCI Functions entry-point for SSH checks.

    Optional JSON body fields:
        compartment_id (str): Override the OCI_COMPARTMENT_ID env var (optional).

    Returns:
        dict: {
            'status': 'ok',
            'total': int,
            'ok': int,
            'failed': int,
            'results': list,
        }
    """
    payload = {}
    if data is None:
        pass
    elif hasattr(data, 'read'):
        raw = data.read()
        if isinstance(raw, (bytes, bytearray)):
            raw = raw.decode('utf-8')
        payload = json.loads(raw or '{}')
    elif isinstance(data, (bytes, bytearray)):
        payload = json.loads(data.decode('utf-8'))
    elif isinstance(data, str):
        payload = json.loads(data) if data.strip() else {}
    else:
        payload = data or {}

    compartment_id = payload.get('compartment_id') or None

    result = ssh_check.run_ssh_check(compartment_id=compartment_id)

    if isinstance(result, dict) and 'status' not in result:
        return {'status': 'ok', **result}
    return result
