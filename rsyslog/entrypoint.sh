#!/usr/bin/env bash
# Entry Point
# @author Vlad Ghinea

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
CA_CERT="${CA_CERT:-/etc/ssl/certs/ca-cert.pem}"
SERVER_KEY="${SERVER_KEY:-/etc/ssl/certs/server-key.pem}"
SERVER_CERT="${SERVER_CERT:-/etc/ssl/certs/server-cert.pem}"
SERVER_TCP_PORT="${SERVER_PORT:-10514}"
REMOTE_LOGS_PATH="${REMOTE_LOGS_PATH:-/logs/remote}"
LOGZIO_TOKEN="${LOGZIO_TOKEN:-}"
LOGZIO_TOKEN_FILE="${LOGZIO_TOKEN_FILE:-}"
TIME_ZONE="${TIME_ZONE:-}"
TIME_SERVER="${TIME_SERVER:-'pool.ntp.org'}"

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

# Make sure required files and directories exist
mkdir -p /var/spool/rsyslog
touch /var/log/messages

# Generate RSysLog global configuration
read -r -d '' RSYSLOG_GLOBAL_CONF <<RSYSLOG_GLOBAL_CONF || true
# Global configuration
global(
  processInternalMessages="on"
  WorkDirectory="/var/spool/rsyslog"
)
RSYSLOG_GLOBAL_CONF

# Generate RSysLog global TLS configuration
read -r -d '' RSYSLOG_GLOBAL_CA_CONF <<RSYSLOG_GLOBAL_CA_CONF || true
# Global configuration
global(
  processInternalMessages="on"
  WorkDirectory="/var/spool/rsyslog"
  defaultNetstreamDriver="gtls"
  defaultNetstreamDriverCAFile="${CA_CERT}"
  defaultNetstreamDriverCertFile="${SERVER_CERT}"
  defaultNetstreamDriverKeyFile="${SERVER_KEY}"
)
RSYSLOG_GLOBAL_CA_CONF

# Generate RSysLog default configuration
read -r -d '' RSYSLOG_IMUXSOCK_CONF <<RSYSLOG_IMUXSOCK_CONF || true
# Provides support for local system logging (e.g. via logger command)
module(load="imuxsock")
RSYSLOG_IMUXSOCK_CONF

read -r -d '' RSYSLOG_IMMARK_CONF <<RSYSLOG_IMMARK_CONF || true
# Provides --MARK-- message capability
module(load="immark")
RSYSLOG_IMMARK_CONF

read -r -d '' RSYSLOG_OMSTDOUT_CONF <<RSYSLOG_OMSTDOUT_CONF || true
# Provides support for writing messages to STDOUT
module(load="omstdout")
RSYSLOG_OMSTDOUT_CONF

read -r -d '' RSYSLOG_TCP_CONF <<RSYSLOG_TCP_CONF || true
# Provides TCP syslog reception
module(
  load="imtcp"
  MaxSessions="512"
)
input(
  type="imtcp"
  port="${SERVER_TCP_PORT}"
)
RSYSLOG_TCP_CONF

read -r -d '' RSYSLOG_TCP_SSL_CONF <<RSYSLOG_TCP_SSL_CONF || true
# Provides TCP syslog reception
module(
  load="imtcp"
  MaxSessions="512"
  StreamDriver.Name="gtls"
  StreamDriver.mode="1"
  StreamDriver.AuthMode="anon"
)
input(
  type="imtcp"
  port="${SERVER_TCP_PORT}"
)
RSYSLOG_TCP_SSL_CONF

read -r -d '' RSYSLOG_OUT_CONF <<RSYSLOG_OUT_CONF || true
# Log all rsyslog messages to the console.
syslog.*  :omstdout:

# Separate logs by hostname
template(name="dynaFile" type="string" string="${REMOTE_LOGS_PATH}/%HOSTNAME%.log")
*.* action(type="omfile" dynaFile="dynaFile")
RSYSLOG_OUT_CONF

# Generate RSysLog Logz.io configuration
file_env LOGZIO_TOKEN # Read env var or file
read -r -d '' RSYSLOG_LOGZIO_CONF <<RSYSLOG_LOGZIO_CONF || true
# Logz.io
template(name="logzioFormat" type="string" string="[${LOGZIO_TOKEN}] <%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [type=syslog] %msg%\\n")
*.* action(
  type="omfwd"
  Protocol="tcp"
  Target="listener.logz.io"
  Port="5001"
  StreamDriverMode="1"
  StreamDriver="gtls"
  StreamDriverAuthMode="x509/name"
  StreamDriverPermittedPeers="*.logz.io"
  template="logzioFormat"
  queue.filename="fwdRule1"
  queue.maxdiskspace="1g"
  queue.saveonshutdown="on"
  queue.type="LinkedList"
)
RSYSLOG_LOGZIO_CONF

# Build Rsyslog Configuration
RSYSLOG_FULL_CONFIG=''
if [[ -s "$CA_CERT" ]] && [[ -s "$SERVER_KEY" ]] && [[ -s "$SERVER_CERT" ]]; then
  RSYSLOG_FULL_CONFIG+="$RSYSLOG_GLOBAL_CA_CONF"
else
  RSYSLOG_FULL_CONFIG+="$RSYSLOG_GLOBAL_CONF"
fi
RSYSLOG_FULL_CONFIG+=$'\n'
RSYSLOG_FULL_CONFIG+="$RSYSLOG_IMUXSOCK_CONF"
RSYSLOG_FULL_CONFIG+=$'\n'
RSYSLOG_FULL_CONFIG+="$RSYSLOG_IMMARK_CONF"
RSYSLOG_FULL_CONFIG+=$'\n'
RSYSLOG_FULL_CONFIG+="$RSYSLOG_OMSTDOUT_CONF"
RSYSLOG_FULL_CONFIG+=$'\n'
if [[ -s "$CA_CERT" ]] && [[ -s "$SERVER_KEY" ]] && [[ -s "$SERVER_CERT" ]]; then
  RSYSLOG_FULL_CONFIG+="$RSYSLOG_TCP_SSL_CONF"
else
  RSYSLOG_FULL_CONFIG+="$RSYSLOG_TCP_CONF"
fi
RSYSLOG_FULL_CONFIG+=$'\n'
RSYSLOG_FULL_CONFIG+="$RSYSLOG_OUT_CONF"
if [[ -n "$LOGZIO_TOKEN" ]] && [[ -s "$CA_CERT" ]]; then
  RSYSLOG_FULL_CONFIG+=$'\n\n'
  RSYSLOG_FULL_CONFIG+="$RSYSLOG_LOGZIO_CONF"
fi
echo "$RSYSLOG_FULL_CONFIG" > /etc/rsyslog.conf

# Configure timezone if provided
if [[ -n "${TIME_ZONE:-}" ]]; then
  cp "/usr/share/zoneinfo/${TIME_ZONE}" /etc/localtime
  echo "$TIME_ZONE" > /etc/timezone
fi

# Update time
ntpd -q -p "$TIME_SERVER" || true

# Remove previous PID file
rm -f /var/run/rsyslogd.pid

# Execute rsyslogd
/usr/sbin/rsyslogd -n
