# AGENTS.md

## Big Picture
- This repo provisions **Oracle Database@AWS** end-to-end using Terraform modules plus two top-level templates.
- Main entrypoints are `templates/aws-oci-adbd-quickstart/` (Autonomous DB flow) and `templates/aws-oci-exadata-quickstart/` (Exadata VM/CDB/PDB flow).
- Each template splits orchestration into `main.aws.tf` (AWS-side ODB resources) and `main.oci.tf` (OCI DB resources that depend on AWS-created OCIDs).
- Cross-cloud handoff is intentional: AWS ODB resources expose OCI metadata (`oci_url`, `ocid`), then OCI provider/resources are configured from those outputs.

## Repository Layout
- `modules/aws-odb-*`: thin wrappers around AWS ODB resources (`aws_odb_network`, `aws_odb_cloud_exadata_infrastructure`, `aws_odb_cloud_vm_cluster`, etc.).
- `modules/oci-db-*`: thin wrappers around OCI DB resources (`oci_database_db_home`, `oci_database_database`, `oci_database_pluggable_database`, etc.).
- `modules/aws-oci-info/`: utility module that parses `oci_url` with regex to derive OCI region/compartment/resource OCID.
- `templates/*/terraform.tfvars.template`: canonical input examples; copy to `terraform.tfvars` and fill credentials/passwords.

## Provisioning Flows (Read Before Editing)
- Shared AWS sequence in both templates: ODB network -> optional VPC (`aws-ia/vpc/aws`) -> network peering -> Exadata infrastructure.
- ADBD template then creates `aws-odb-avmc` and OCI `oci-db-acd` -> `oci-db-adb` (`templates/aws-oci-adbd-quickstart/main.*.tf`).
- Exadata template creates `aws-odb-vmc` and OCI `oci-db-dbhome` -> `oci-db-cdb` -> `oci-db-pdb` (`templates/aws-oci-exadata-quickstart/main.*.tf`).
- `depends_on` and `locals` are heavily used for ordering and ID plumbing; preserve this pattern when adding resources.

## Developer Workflow
- Work from inside one template directory, not repo root (state is local per working dir).
- Baseline commands (from `README.md`):
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
  - `terraform destroy`
- No test harness or CI workflow is defined in this repo; treat `terraform plan` in each template as the primary verification step.

## Conventions and Project-Specific Patterns
- Keep provider config isolated in `providers.tf`; both templates set OCI provider `region = local.oci_region` (derived via module outputs).
- Sensitive vars are declared in `variables.tf` and intentionally left commented in `terraform.tfvars.template` (for example DB admin passwords).
- Module design is intentionally minimal: most modules map variables almost 1:1 to a single resource and expose IDs/OCIDs via outputs.
- In `modules/aws-odb-vmc/main.tf`, per-VM sizing inputs are converted to per-cluster API values using `local.node_count`; preserve this translation logic.
- In `modules/aws-odb-avmc/main.tf`, `lifecycle.ignore_changes` is set for `maintenance_window` and `total_container_databases`; avoid removing without understanding drift implications.

## Integration Notes / Gotchas
- `templates/aws-oci-adbd-quickstart/main.aws.tf` sources Exadata infra from `github.com/chanstev/terraform-oci-multicloud-aws//modules/aws-odb-exadata-infra` (not local module); changing module behavior may require updating this source.
- Optional VPC creation is controlled by `odb_peering_connection_peer_network_id == null`; if peer VPC ID is provided, `aws_ia_vpc` is skipped.
- Keep output names and module names aligned when editing templates/modules; cross-file wiring is dense and easy to break.
- Module READMEs are generated-style docs (`<!-- BEGIN_TF_DOCS -->` blocks); update docs consistently if variables/outputs change.

## Environments (`envs/`)
- `envs/tst` and `envs/prd` are staged roots (`0_bootstrap` .. `5_dashboards`), each stage with its own state. See `envs/README.md`.
- Modules are referenced by relative path (`../../modules/...`). Per-cluster stages (`exa1`..`exa3`) live under `2_compute`, `3_databases` and `4_monitoring` in prd.
- All IDs, OCIDs, account numbers, hostnames and database names are placeholders. Do not commit real values.

## Functions (`functions/`)
- `functions/src` is the OCI Functions framework (handler, `oci_utils`, `logger`, `config`) with one example check, `ssh_check`. Metrics land in the `example_oracledb_aws` namespace, which `modules/ocimon/custom_metrics_monitoring` alarms on.
- `functions/terraform/modules/ssh-check` deploys one function. `functions/terraform/example` is a root module with the Functions application, schedule and optional IAM. See `functions/README.md`.
