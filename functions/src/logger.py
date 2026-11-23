import logging
import os
try:
    import rapidjson as json
except ImportError:
    import json
import re
import time
from config import LOG_REDACT_PATTERNS, LOG_REDACT_FIELDS

LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
ROOT_LOG_LEVEL = os.environ.get('ROOT_LOG_LEVEL', 'ERROR')


class JsonFormatter(logging.Formatter):
    """Format log records as JSON for OCI Functions compatibility."""

    def format(self, record):
        log_entry = {
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'message': record.getMessage(),
            'logger': record.name,
        }
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)
        return json.dumps(log_entry)


def log():
    log_level = getattr(logging, LOG_LEVEL.upper(), logging.INFO)
    root_log_level = getattr(logging, ROOT_LOG_LEVEL.upper(), logging.ERROR)

    logger = logging.getLogger()

    is_oci_functions = bool(os.environ.get('OCI_RESOURCE_PRINCIPAL_VERSION'))

    if is_oci_functions:
        logging.basicConfig(level=log_level, handlers=[])
        handler = logging.StreamHandler()
        handler.setFormatter(JsonFormatter())
        logger.addHandler(handler)
    else:
        logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s')

    logger.setLevel(log_level)

    for lib in ('boto3', 'botocore', 'oci', 'urllib3', 'requests', 'paramiko'):
        logging.getLogger(lib).setLevel(root_log_level)

    if not is_oci_functions:
        for handler in logging.root.handlers:
            handler.setFormatter(
                RedactingFormatter(handler.formatter,
                                   patterns=LOG_REDACT_PATTERNS,
                                   redact_fields=LOG_REDACT_FIELDS)
            )

    return logger


def DEBUG(msg):
    if LOG_LEVEL == 'DEBUG':
        print(msg)


class RedactingFormatter(object):
    """Redact sensitive information in log messages based on patterns and fields."""

    def __init__(self, orig_formatter, *args, **kwargs):
        super().__init__()
        self.orig_formatter = orig_formatter
        self._fields = kwargs.get('redact_fields', [])
        self._patterns = kwargs.get('patterns', [])

    def redact(self, msg):
        PLACEHOLDER = f'<<<PLACEHOLDER_{round(time.time() * 1000)}>>>'

        if isinstance(msg, str):
            for pattern in self._patterns:
                msg = re.sub(pattern, '<REDACTED>', msg)
            found = re.search(r'(?P<json_text>\{.+\})', msg, flags=re.DOTALL | re.MULTILINE)
            if found:
                json_text = found.group('json_text')
                try:
                    parsed_json = json.loads(json_text)
                except ValueError:
                    return msg
                msg = re.sub(r'\{.+\}', PLACEHOLDER, msg, flags=re.DOTALL | re.MULTILINE)
                redacted_json = json.dumps(self.redact(parsed_json))
                return msg.replace(PLACEHOLDER, redacted_json)
        elif isinstance(msg, list):
            return [self.redact(item) for item in msg]
        elif isinstance(msg, dict):
            return {
                key: '<REDACTED>' if key in self._fields else self.redact(value)
                for key, value in msg.items()
            }
        return msg

    def format(self, record):
        original_message = self.orig_formatter.format(record)
        return self.redact(original_message)

    def __getattr__(self, attr):
        return getattr(self.orig_formatter, attr)

