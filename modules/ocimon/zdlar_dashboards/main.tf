# ---------------------------------------------------------------------------
# OCI ZDLAR (Zero Data Loss Autonomous Recovery Service) dashboards
#
# One OCI Management Dashboard per protected database, reproducing the
# structure of a working dashboard exported from the console (via
# `oci management-dashboard dashboard export --query data`). Metrics come from
# the oci_recovery_service namespace and are keyed on the PROTECTED DATABASE
# resource OCID (ocid1.recoveryserviceprotecteddatabase...) — not the AWS db
# name or dBUniqueName.
#
# The import payload MUST be camelCase (the raw ManagementDashboard API schema);
# the CLI export is kebab-case and the CLI converts it internally. Terraform's
# jsonencode() serializes lists as JSON arrays, which the API requires (empty
# lists included). This exact shape was validated with a real apply.
#
# Widgets mirror the console template:
#   ProtectedDatabaseHealth [30m].max()
#   ProtectedDatabaseSize   [1440m].max()
#   RecoveryWindow          -> DataLossExposure [1440m].max()
#   DataLossExposure        [30m].mean()
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : "${var.vm_cluster_name}-ZDLAR"

  # Metric tiles, in a 2-column grid (width 4, height 3).
  widgets = [
    { key = "health", metric = "ProtectedDatabaseHealth", title = "ProtectedDatabaseHealth", interval = "30m", agg = "max", row = 0, col = 0 },
    { key = "size", metric = "ProtectedDatabaseSize", title = "ProtectedDatabaseSize", interval = "1440m", agg = "max", row = 0, col = 4 },
    { key = "recwin", metric = "DataLossExposure", title = "RecoveryWindow", interval = "1440m", agg = "max", row = 3, col = 0 },
    { key = "dle", metric = "DataLossExposure", title = "DataLossExposure", interval = "30m", agg = "mean", row = 3, col = 4 },
  ]

  # Build the full dashboards[] payload, one dashboard per protected database.
  dashboards = [
    for db_name, resource_ocid in var.protected_databases : {
      dashboardId       = "zdlar-${lower(replace(var.vm_cluster_name, "/[^A-Za-z0-9]/", ""))}-${lower(db_name)}"
      displayName       = "${local.name_prefix}-${db_name}"
      description       = "Zero Data Loss Autonomous Recovery Service backups for ${db_name} (${var.environment})."
      compartmentId     = var.compartment_ocid
      providerId        = "management-dashboard"
      providerName      = "Management Dashboard"
      providerVersion   = "3.0.0"
      isOobDashboard    = false
      isShowInHome      = false
      isShowDescription = true
      isFavorite        = false
      metadataVersion   = "2.0"
      screenImage       = ""
      type              = "normal"
      nls               = {}
      freeformTags      = {}
      definedTags       = {}
      dataConfig        = []
      drilldownConfig   = []
      featuresConfig    = { crossService = { shared = true }, serviceTypes = ["management-dashboard"] }
      parametersConfig = [
        { name = "compartmentId", savedSearchId = "OOBSS-management-dashboard-compartment-filter", state = "DEFAULT", width = 4, localStorageKey = "compartmentId", parametersMap = { isActiveCompartment = "true", isStoreInLocalStorage = false, showIncludeSubcompartments = true } },
        { name = "time", displayName = "$${bundle.globalSavedSearch.TIME}", src = "$${context.time}" },
      ]
      uiConfig = {
        isFilteringEnabled = false
        isRefreshEnabled   = true
        isTimeRangeEnabled = true
      }

      savedSearches = [
        for w in local.widgets : {
          id               = "zdlar-ss-${lower(db_name)}-${w.key}"
          displayName      = w.title
          description      = w.title
          compartmentId    = var.compartment_ocid
          providerId       = "management-dashboard"
          providerName     = "Management Dashboard"
          providerVersion  = "3.0.0"
          type             = "WIDGET_SHOW_IN_DASHBOARD"
          isOobSavedSearch = false
          metadataVersion  = "2.0"
          screenImage      = ""
          nls              = {}
          freeformTags     = {}
          definedTags      = {}
          widgetTemplate   = "visualizations/chartWidgetTemplate.html"
          widgetVM         = "visualizations/chartWidget"
          drilldownConfig  = []
          parametersConfig = [
            { name = "time", required = true, displayName = "$${bundle.globalSavedSearch.TIME_PARAMETER_NAME}", editUi = { inputType = "savedSearch", filterTile = { filterId = "OOBSS-management-dashboard-time-selector-filter", parametersMap = { maxDurationDays = 89 } } } },
            { name = "compartmentId", required = true, displayName = "$${bundle.globalSavedSearch.COMPARTMENT}", defaultFilterIds = ["OOBSS-management-dashboard-compartment-filter"], editUi = { inputType = "compartmentSelect" }, valueFormat = { type = "object" } },
            { name = "regionName", required = false, displayName = "$${bundle.globalSavedSearch.REGION}", defaultFilterIds = ["OOBSS-management-dashboard-region-filter"], editUi = { inputType = "savedSearch", filterTile = { filterId = "OOBSS-management-dashboard-region-filter", parametersMap = { selectionMode = "single" } } }, valueFormat = { type = "string" } },
          ]
          uiConfig = {
            vizType           = "chart"
            defaultDataSource = "oci_recovery_service/${w.metric}"
            chartInfo = {
              colorBy = "name"
              group   = "aggregatedDatapoints.timestamp"
              series  = "name"
              value   = "aggregatedDatapoints.value"
              jetConfig = {
                timeAxisType = "enabled"
                type         = "line"
                xAxis        = { viewportMin = "$${params.time.start}", viewportMax = "$${params.time.end}" }
              }
            }
          }
          dataConfig = [
            {
              name = "oci_recovery_service/${w.metric}"
              type = "monitoringDataSource"
              parameters = {
                compartmentId = "$${params.compartmentId}"
                startTime     = "$${params.time.start}"
                endTime       = "$${params.time.end}"
                regionName    = "$${params.regionName}"
                maxDataPoints = "useIntervalExact"
                namespace     = "oci_recovery_service"
                mql           = "${w.metric}[${w.interval}]{resourceId = \"${resource_ocid}\"}.${w.agg}()"
              }
            }
          ]
        }
      ]

      tiles = [
        for w in local.widgets : {
          savedSearchId   = "zdlar-ss-${lower(db_name)}-${w.key}"
          displayName     = "__INHERIT__"
          row             = w.row
          column          = w.col
          height          = 3
          width           = 4
          nls             = {}
          uiConfig        = {}
          dataConfig      = []
          drilldownConfig = []
          state           = "DEFAULT"
          parametersMap = {
            compartmentId = "$${dashboard.params.compartmentId}"
            regionName    = "$${context.regionName}"
            time          = "$${dashboard.params.time}"
          }
        }
      ]
    }
  ]
}

# All ZDLAR dashboards imported in a single API call (avoids the parallel
# SplatStore race, and matches the console export's single-payload shape).
resource "oci_management_dashboard_management_dashboards_import" "this" {
  count = length(var.protected_databases) > 0 ? 1 : 0

  override_same_name                  = true
  override_dashboard_compartment_ocid = var.compartment_ocid

  import_details = jsonencode({ dashboards = local.dashboards })
}
