# Environments

Two example environments built on the modules in `../modules`:

| Env | Purpose |
|---|---|
| `tst` | Test environment. Single VM cluster, used to try changes before production. |
| `prd` | Production. Three Exadata infrastructures (`exa1`..`exa3`), each with its own compute, database and monitoring stack. |

Every value in these folders is a placeholder (OCIDs, account IDs, ODB IDs, host names, database names, URLs, contacts).
Replace them with your own before running `terraform plan`.

## Stage layout

Each environment is split into stages that are applied in order. Each stage has its own state
(`<env>/<stage>/terraform.tfstate`) and reads earlier stages through `terraform_remote_state`.

| Stage | Content |
|---|---|
| `0_bootstrap` | Remote state bucket and IAM for the monitoring functions |
| `1_network` | ODB network and VPC peering |
| `2_compute` | Exadata infrastructure and VM clusters |
| `3_databases` | DB homes, CDBs and PDBs. `databases.tf` is the single source of truth for each cluster |
| `4_monitoring` | CloudWatch alarms and OCI Monitoring alarms |
| `5_dashboards` | CloudWatch and OCI dashboards |

## Before you apply

- Set `AWS_PROFILE` (or use SSO) and the OCI config profile. No credentials are stored in the repo.
- Pass secrets (`cdb_admin_password`, `pdb_admin_password`, `pdb_tde_wallet_password`) with `TF_VAR_*` variables or a secrets manager. Their defaults are `null`.
- Edit `backend.tf` in each stage to point at your own state bucket.
- Module sources are relative paths into `../../modules`. Pin them to a git tag or registry version for shared use.
