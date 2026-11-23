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
    apphome1         = { ocid = module.apphome1_db_home.oci_resource_ocid, compartment = module.apphome1_db_home.oci_resource.compartment_id }
    unmanaged_cdb050 = { ocid = "ocid1.dbhome.oc1.iad.exampleuniqueiddbhome0001", compartment = null }
    apphome2         = { ocid = module.apphome2_db_home.oci_resource_ocid, compartment = module.apphome2_db_home.oci_resource.compartment_id }
    apphome3         = { ocid = module.rr-datapump_db_home.oci_resource_ocid, compartment = module.rr-datapump_db_home.oci_resource.compartment_id }
    unmanaged_cdb033 = { ocid = "ocid1.dbhome.oc1.iad.exampleuniqueiddbhome0002", compartment = null }
    unmanaged_cdb034 = { ocid = "ocid1.dbhome.oc1.iad.exampleuniqueiddbhome0003", compartment = null }
  }

  databases = {
    cdb001 = {
      home          = "apphome1"
      role          = "regular"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB004 = {
          db_management = false
        }
      }
    }
    cdb002 = {
      home          = "apphome1"
      role          = "regular"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB005 = {
          db_management = false
        }
      }
    }
    cdb065 = {
      home          = "apphome1"
      role          = "regular"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB003 = {
          db_management = false
        }
      }
    }
    cdb005 = {
      home               = "apphome1"
      role               = "template"
      auto_backup        = true
      backup_window      = "SLOT_FIVE"
      full_backup_window = "SLOT_FIVE"
      pdbs = {
        PDB501 = {}
      }
    }
    cdb067 = {
      home               = "apphome1"
      role               = "regular"
      db_management      = false
      auto_backup        = true
      backup_window      = "SLOT_FIVE"
      full_backup_window = "SLOT_FIVE"
      pdbs = {
        PDB064 = {
          db_management = false
        }
      }
    }
    cdb015 = {
      home               = "apphome1"
      role               = "regular"
      auto_backup        = true
      backup_window      = "SLOT_SEVEN"
      full_backup_window = "SLOT_SEVEN"
      pdbs = {
        PDB505 = {}
      }
    }
    cdb017 = {
      home               = "apphome1"
      role               = "regular"
      auto_backup        = true
      backup_window      = "SLOT_FIVE"
      full_backup_window = "SLOT_ELEVEN"
      pdbs = {
        PDB506 = {}
      }
    }
    cdb050 = {
      home          = "unmanaged_cdb050"
      role          = "regular"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB050 = {
          db_management = false
        }
      }
    }
    cdb051 = {
      home               = "apphome1"
      role               = "regular"
      auto_backup        = true
      backup_window      = "SLOT_SIX"
      full_backup_window = "SLOT_SIX"
      pdbs = {
        PDB507 = {}
      }
    }
    cdb024 = {
      home          = "apphome1"
      role          = "regular"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB024 = {
          db_management = false
        }
      }
    }
    cdb026 = {
      name               = "cdb502"
      home               = "apphome2"
      role               = "regular"
      admin_password     = ""
      auto_backup        = true
      backup_window      = "SLOT_SEVEN"
      full_backup_window = "SLOT_SEVEN"
      pdbs = {
        PDB053 = {
          admin_password = ""
        }
      }
    }
    cdb055 = {
      home               = "apphome2"
      role               = "regular"
      admin_password     = ""
      auto_backup        = true
      backup_window      = "SLOT_TWELVE"
      full_backup_window = "SLOT_ONE"
      pdbs = {
        PDB055 = {
          admin_password = ""
        }
      }
    }
    cdb056 = {
      home               = "apphome2"
      role               = "regular"
      admin_password     = ""
      auto_backup        = true
      backup_window      = "SLOT_THREE"
      full_backup_window = "SLOT_THREE"
      pdbs = {
        PDB056 = {
          admin_password = ""
        }
      }
    }
    cdb027 = {
      home        = "apphome1"
      role        = "regular"
      auto_backup = true
      pdbs = {
        PDB002 = {
          name = "PDB026"
        }
      }
    }
    cdb057 = {
      home               = "apphome1"
      role               = "regular"
      auto_backup        = true
      full_backup_day    = "MONDAY"
      backup_window      = "SLOT_FIVE"
      full_backup_window = "SLOT_FIVE"
      pdbs = {
        PDB510 = {}
      }
    }
    cdb031 = {
      home               = "apphome1"
      role               = "regular"
      auto_backup        = true
      backup_window      = "SLOT_FIVE"
      full_backup_window = "SLOT_FIVE"
      pdbs = {
        PDB511 = {}
      }
    }
    cdb060 = {
      home               = "apphome1"
      role               = "regular"
      auto_backup        = true
      backup_window      = "SLOT_SEVEN"
      full_backup_window = "SLOT_SEVEN"
      pdbs = {
        PDB512 = {}
      }
    }
    cdb069 = {
      home               = "apphome1"
      role               = "regular"
      auto_backup        = true
      full_backup_day    = "MONDAY"
      backup_window      = "SLOT_FIVE"
      full_backup_window = "SLOT_ELEVEN"
      pdbs = {
        PDB513 = {}
      }
    }
    cdb071 = {
      home               = "apphome3"
      role               = "regular"
      admin_password     = ""
      auto_backup        = true
      backup_window      = "SLOT_FOUR"
      full_backup_window = "SLOT_FOUR"
      pdbs = {
        PDB066 = {
          admin_password = ""
        }
      }
    }
    cdb073 = {
      home        = "unmanaged_cdb033"
      role        = "regular"
      auto_backup = true
      pdbs = {
        PDB068 = {
          admin_password = ""
        }
      }
    }
    cdb033 = {
      home        = "unmanaged_cdb033"
      role        = "regular"
      auto_backup = true
      pdbs = {
        PDB031 = {
          admin_password = ""
        }
      }
    }
    cdb034 = {
      home = "unmanaged_cdb034"
      role = "regular"
      pdbs = {
        PDB032 = {
          admin_password = ""
        }
      }
    }
    cdb075 = {
      home          = "apphome1"
      role          = "regular"
      db_management = false
      auto_backup   = true
      pdbs = {
        PDB070 = {
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
  source   = "../../../modules/cdb"
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
  exainfra_id             = local.exainfra_id
  exainfra_ocid           = local.exainfra_ocid
  vm_cluster_id           = local.vm_cluster_id
  vm_cluster_name         = local.vm_cluster_name
  vm_cluster_ocid         = local.vm_cluster_ocid
}

locals {
  cdb_modules = merge(module.cdb)
}

module "pdb" {
  source   = "../../../modules/pdb"
  for_each = { for k, p in local.pdb_list : k => p if p.module_version == "latest" }

  environment             = var.environment
  database_role           = each.value.role
  container_database_ocid = local.cdb_modules[each.value.cdb].cdb_resource_id
  compartment_ocid        = local.cdb_modules[each.value.cdb].cdb_resource.compartment_id
  pdb_name                = each.value.name
  pdb_admin_password      = each.value.admin_password
  pdb_tde_wallet_password = each.value.tde_password
  enable_db_management    = each.value.db_management
  exainfra_id             = local.exainfra_id
  exainfra_ocid           = local.exainfra_ocid
  vm_cluster_id           = local.vm_cluster_id
  vm_cluster_name         = local.vm_cluster_name
  vm_cluster_ocid         = local.vm_cluster_ocid
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
