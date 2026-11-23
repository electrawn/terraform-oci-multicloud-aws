# Logging configuration (used by logger.RedactingFormatter)
LOG_REDACT_FIELDS = ['password', 'authorization', 'token', 'db_password', 'username', 'secret']
LOG_REDACT_PATTERNS = []

# SSH check configuration
SSH_CHECK_PORT = 22
SSH_CHECK_TIMEOUT_SECONDS = 10
SSH_BANNER_TIMEOUT_SECONDS = 5

# OCI Monitoring custom metric. The namespace must match the one your alarms
# query (see terraform/modules/ssh-check outputs).
OCI_METRIC_NAMESPACE = 'example_oracledb_aws'
OCI_METRIC_NAME = 'sshstatus'

# Status values emitted as the metric value
SSH_STATUS_OK = 0       # Node responds on the SSH port with an SSH banner
SSH_STATUS_FAILED = 1   # Node does not respond, or no SSH banner

# Status strings used as a metric dimension
STATUS_OK_STR = 'OK'
STATUS_FAILED_STR = 'FAILED'
