# functions

OCI Functions that emulate Nagios-style health checks for Oracle Database@AWS (Exadata) and publish the results as custom OCI Monitoring metrics. The alarms in `modules/ocimon/custom_metrics_monitoring` consume those metrics.

This directory holds the shared function framework and one example function, `ssh_check`. More checks follow the same pattern.

## Layout

| Path | Purpose |
|---|---|
| `src/func.py` | OCI Functions (FDK) entry point. Parses the request body and calls the check. |
| `src/ssh_check.py` | The example check: TCP connect plus SSH banner read against every Exadata DB node. |
| `src/oci_utils.py` | Framework: OCI signer (resource principal, with `~/.oci/config` fallback), DB node and VNIC discovery, paginated `post_metric_data`, Vault secret reader. |
| `src/logger.py` | Framework: JSON logs inside OCI Functions, redacting formatter locally. |
| `src/config.py` | Constants: metric namespace and name, ports, timeouts, redaction fields. |
| `Dockerfile`, `func.yaml.example` | Container image and Fn config. |
| `tests/` | Offline unit tests. Sockets and the OCI SDK are mocked. |
| `terraform/modules/ssh-check` | Deploys one function. |
| `terraform/example` | Root module: Functions application, logging, schedule and optional IAM. |

## The `ssh_check` function

1. Lists the Cloud VM Clusters in `OCI_COMPARTMENT_ID` (optionally only the one named in `SSH_CHECK_VM_CLUSTER_NAME`).
2. Lists each cluster's DB nodes and resolves the client IP and VIP from the node's VNIC.
3. Opens a TCP connection to each node and expects a banner starting with `SSH-`.
4. Publishes one data point per node, in batches of 50, to `METRIC_COMPARTMENT_ID` (falls back to `OCI_COMPARTMENT_ID`).

| Attribute | Value |
|---|---|
| Metric namespace | `example_oracledb_aws` |
| Metric name | `sshstatus` |
| Value | `0` = OK, `1` = FAILED |
| Dimensions | `node_id`, `node_hostname`, `ip_address`, `status`, `vm_cluster` |

### Environment variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `OCI_COMPARTMENT_ID` | yes | | Compartment that holds the Exadata VM clusters |
| `OCI_REGION` | yes | | OCI region, e.g. `us-ashburn-1` |
| `METRIC_COMPARTMENT_ID` | | `OCI_COMPARTMENT_ID` | Compartment the metric is published to. Put it where your alarms live |
| `SSH_CHECK_TARGET` | | `admin` | `admin` probes `<hostname>.<SSH_CHECK_DOMAIN>`. `primary` probes the client IP. `vip` probes the node VIP |
| `SSH_CHECK_DOMAIN` | | `admin.example.internal` | Admin DNS domain used when the target is `admin` |
| `SSH_CHECK_VM_CLUSTER_NAME` | | all clusters | Restrict the check to one VM cluster display name |
| `SSH_CHECK_PORT` | | `22` | TCP port |
| `SSH_CHECK_TIMEOUT` | | `10` | Connect timeout in seconds |
| `LOG_LEVEL` | | `INFO` | Python log level |

Which `SSH_CHECK_TARGET` works depends on your network. On the original deployment sshd listened only on the admin network, the client primary IP timed out and the VIP refused port 22. Test from the function subnet before you pick one.

## Adding another check

1. Add `src/<name>_check.py` with a `run_<name>_check()` that returns a summary dict and calls `oci_utils.post_metric_data(...)`.
2. Add its constants to `src/config.py`.
3. Add a handler (or route on the request body in `func.py`) and set `FUNCTION_SCRIPT` at build time.
4. Copy `terraform/modules/ssh-check` to a new module and adjust the config block.
5. Add a test file next to `tests/test_ssh_check.py`.

## Build, test, deploy

```
python -m venv .venv && . .venv/bin/activate
pip install -r requirements-dev.txt
pytest

docker build -t <region>.ocir.io/<tenancy-namespace>/ssh-check:0.0.1 .
docker push  <region>.ocir.io/<tenancy-namespace>/ssh-check:0.0.1
```

Then deploy with Terraform:

```
cd terraform/example
cp terraform.tfvars.example terraform.tfvars   # fill in your OCIDs
terraform init && terraform plan
```

`create_iam = true` also creates the resource-principal dynamic group and policy (read database and network families in the DB compartment, use metrics in the monitor compartment) plus the Resource Scheduler dynamic group and policy. Leave it `false` if IAM is managed in another stack.

## Notes

- The tests need no OCI access. The 34 tests took about 3 minutes in the first run on a laptop without an OCI config.
- Resource Scheduler's minimum frequency is hourly. For more frequent checks create several schedules at different minutes.
- Do not start several functions in the same second. Cold starts of many images at once can return 503, and a 503 is not retried.
- The Python pins target Python 3.11 (the Docker base image). `python-rapidjson` is optional; the code falls back to `json`.
