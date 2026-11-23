# ---------------------------------------------------------------------------
# Databases on this VM cluster: the SINGLE SOURCE OF TRUTH.
#
# Each entry in local.databases creates the CDB module, its PDB modules and the
# cdbs/pdbs outputs that 4_monitoring, 5_dashboards and oci-functions read.
# To add a database: add an entry here plus an import block (see oci-functions
#
# CDB fields (PDBs may override the ones marked *):
#   home             key in local.db_homes
#   role *           template | regular | dataguard_primary | dataguard_standby | reporting
#                    (reporting = no DB Management; monitoring alarms follow the role)
#   db_management *  false to turn DB Management off (default true)
#   rarely needed:   admin_password, tde_password (PDB), auto_backup (default false),
#                    full_backup_day, backup_window, full_backup_window, module_version
#   name             only when the OCI name differs from the key
# ---------------------------------------------------------------------------
locals {
  db_homes = {
    dbhome_example = { ocid = module.dbhome_example_db_home.oci_resource_ocid, compartment = module.dbhome_example_db_home.oci_resource.compartment_id }
  }

  databases = {
    cdb006 = {
      home          = "dbhome_example"
      role          = "template"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB008 = {
          db_management = false
        }
      }
    }
    cdb009 = {
      home          = "dbhome_example"
      role          = "reporting"
      db_management = false
      auto_backup   = true
      pdbs = {
      }
    }
    cdb010 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB503 = {}
      }
    }
    cdb011 = {
      home          = "dbhome_example"
      role          = "dataguard_standby"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB014 = {
          db_management = false
        }
      }
    }
    cdb013 = {
      home        = "dbhome_example"
      role        = "dataguard_standby"
      auto_backup = true
      pdbs = {
        PDB016 = {
          db_management = false
        }
      }
    }
    cdb052 = {
      home          = "dbhome_example"
      role          = "reporting"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB051 = {
          db_management = false
        }
      }
    }
    cdb021 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB508 = {}
      }
    }
    cdb022 = {
      home          = "dbhome_example"
      role          = "reporting"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB509 = {}
      }
    }
    cdb023 = {
      home          = "dbhome_example"
      role          = "dataguard_standby"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB023 = {}
      }
    }
    cdb025 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB025 = {
          db_management = false
        }
      }
    }
    cdb037 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB515 = {}
      }
    }
    cdb038 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB516 = {}
      }
    }
    cdb039 = {
      home          = "dbhome_example"
      role          = "dataguard_standby"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB039 = {
          db_management = false
        }
      }
    }
    cdb040 = {
      home          = "dbhome_example"
      role          = "reporting"
      db_management = false
      auto_backup   = true
      pdbs = {
        pdb001 = {
          name = "PDB040"
        }
      }
    }
    cdb041 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB518 = {}
      }
    }
    cdb042 = {
      home          = "dbhome_example"
      role          = "dataguard_standby"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB040 = {
          db_management = false
        }
      }
    }
    cdb043 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB041 = {}
      }
    }
    cdb045 = {
      home          = "dbhome_example"
      role          = "reporting"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB043 = {
          db_management = false
        }
      }
    }
    cdb047 = {
      home        = "dbhome_example"
      role        = "reporting"
      auto_backup = true
      pdbs = {
        PDB047 = {
          db_management = false
        }
      }
    }
    cdb048 = {
      home          = "dbhome_example"
      role          = "reporting"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB048 = {
          db_management = false
        }
      }
    }
    cdb049 = {
      home          = "dbhome_example"
      role          = "dataguard_standby"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB049 = {
          db_management = false
        }
      }
    }
  }

  # Flattened, defaults applied (defaults = module defaults).
  cdb_list = {
    for k, c in local.databases : k => {
      name               = try(c.name, k)
      home               = c.home
      role               = c.role
      db_management      = try(c.db_management, true)
      admin_password     = try(c.admin_password, null)
      auto_backup        = try(c.auto_backup, false)
      full_backup_day    = try(c.full_backup_day, "SUNDAY")
      backup_window      = try(c.backup_window, "SLOT_TWO")
      full_backup_window = try(c.full_backup_window, "SLOT_TWO")
      module_version     = try(c.module_version, "latest")
    }
  }
  pdb_list = merge([
    for ck, c in local.databases : {
      for pk, p in c.pdbs : pk => {
        cdb            = ck
        name           = try(p.name, pk)
        role           = try(p.role, local.cdb_list[ck].role)
        db_management  = try(p.db_management, true)
        admin_password = try(p.admin_password, null)
        tde_password   = try(p.tde_password, null)
        module_version = try(p.module_version, local.cdb_list[ck].module_version)
      }
    }
  ]...)
}

module "cdb" {
  source   = "../../../../modules/cdb"
  for_each = { for k, c in local.cdb_list : k => c if c.module_version == "latest" }

  environment             = var.environment
  database_role           = each.value.role
  db_home_ocid            = local.db_homes[each.value.home].ocid
  compartment_ocid        = local.db_homes[each.value.home].compartment
  cdb_name                = each.value.name
  cdb_admin_password      = each.value.admin_password
  cdb_source              = var.cdb_source
  cdb_auto_backup_enabled = each.value.auto_backup
  auto_full_backup_day    = each.value.full_backup_day
  auto_backup_window      = each.value.backup_window
  auto_full_backup_window = each.value.full_backup_window
  enable_db_management    = each.value.db_management
  exainfra_id             = var.exainfra_id
  exainfra_ocid           = var.exainfra_ocid
  vm_cluster_id           = var.vm_cluster_id
  vm_cluster_name         = var.vm_cluster_name
  vm_cluster_ocid         = var.vm_cluster_ocid
  private_end_point_ocid  = var.private_end_point_ocid
}

locals {
  cdb_modules = merge(module.cdb)
}

module "pdb" {
  source   = "../../../../modules/pdb"
  for_each = { for k, p in local.pdb_list : k => p if p.module_version == "latest" }

  environment             = var.environment
  database_role           = each.value.role
  container_database_ocid = local.cdb_modules[each.value.cdb].cdb_resource_id
  compartment_ocid        = local.cdb_modules[each.value.cdb].cdb_resource.compartment_id
  pdb_name                = each.value.name
  pdb_admin_password      = each.value.admin_password
  pdb_tde_wallet_password = each.value.tde_password
  enable_db_management    = each.value.db_management
  exainfra_id             = var.exainfra_id
  exainfra_ocid           = var.exainfra_ocid
  vm_cluster_id           = var.vm_cluster_id
  vm_cluster_name         = var.vm_cluster_name
  vm_cluster_ocid         = var.vm_cluster_ocid
  private_end_point_ocid  = var.private_end_point_ocid
}

locals {
  pdb_modules = merge(module.pdb)
}

# Read by 4_monitoring, 5_dashboards and oci-functions via terraform_remote_state.
output "cdbs" {
  description = "Map of all CDBs with their full resource info for monitoring (from local.databases)"
  value = {
    for k, c in local.cdb_list : k => {
      name        = c.name
      id          = local.cdb_modules[k].cdb_resource_id
      ocid        = local.cdb_modules[k].cdb_resource.id
      compartment = local.cdb_modules[k].cdb_resource.compartment_id
      role        = c.role
    }
  }
}

output "pdbs" {
  description = "Map of all PDBs with their full resource info for monitoring (from local.databases)"
  value = {
    for k, p in local.pdb_list : k => {
      name        = p.name
      id          = local.pdb_modules[k].pdb_resource_id
      ocid        = local.pdb_modules[k].pdb_resource.id
      compartment = local.pdb_modules[k].pdb_resource.compartment_id
      cdb_name    = local.cdb_list[p.cdb].name
      role        = p.role
    }
  }
}
