#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
AWS_S3_BUCKET="${AWS_S3_BUCKET:-backup_$(date +%s | sha256sum | base64 | head -c 16 ; echo)}"
AWS_S3_PREFIX="${AWS_S3_PREFIX:-}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
GPG_PASSPHRASE="${GPG_PASSPHRASE:-}"
GPG_PASSPHRASE_FILE="${GPG_PASSPHRASE_FILE:-}"
GPG_RECIPIENT="${GPG_RECIPIENT:-}"
GPG_KEY_PATH="${GPG_KEY_PATH:-/keys}"
GPG_KEY_URL="${GPG_KEY_URL:-}"
BACKUP_PATH="${BACKUP_PATH:-/backup}"
RESTORE_PATH="${RESTORE_PATH:-/restore}"
CRON_TIME="${CRON_TIME:-8 */8 * * *}"
NOW=$(date +"%Y-%m-%d_%H-%M-%S")

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Usage: file_env VAR [DEFAULT]
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

# Import public GPG key
import_gpg_keys(){
  _gpg_cmd_options='--batch --yes'

  if [[ -d $GPG_KEY_PATH ]] && [[ $(ls -A "${GPG_KEY_PATH}" 2>/dev/null) ]]; then
    log "Import key(s) in ${GPG_KEY_PATH} folder"
    eval "gpg ${_gpg_cmd_options} --import ${GPG_KEY_PATH}/*"
  elif [[ -s $GPG_KEY_PATH ]]; then
    log "Import key ${GPG_KEY_PATH}"
    eval "gpg ${_gpg_cmd_options} --import ${GPG_KEY_PATH}"
  elif [[ "$GPG_KEY_URL" =~ ^https://.* ]]; then
    log "Import key(s) from ${GPG_KEY_URL}"
    IFS=', ' read -ra GPG_KEY_URL_ARRAY <<< "${GPG_KEY_URL:-}"
    for key_url in "${GPG_KEY_URL_ARRAY[@]}"; do
      curl "$key_url" | eval "gpg ${_gpg_cmd_options} --import"
    done
  else
    file_env 'GPG_PASSPHRASE'
  fi
}

# Set-up S3
set_up_s3(){
  if [[ -n "$AWS_S3_PREFIX" ]]; then
    _aws_s3_path="s3://${AWS_S3_BUCKET}/${AWS_S3_PREFIX}"
  else
    _aws_s3_path="s3://${AWS_S3_BUCKET}"
  fi
}

# Create bucket, if it doesn't already exist and persist the name
ensure_s3_bucket(){
  set_up_s3

  if grep -q "${AWS_S3_BUCKET}" /var/run/backup_bucket_name 2>/dev/null; then
    log "Using ${AWS_S3_BUCKET} bucket"
    export AWS_S3_BUCKET; AWS_S3_BUCKET="$(cat /var/run/backup_bucket_name)"
  elif [[ -s /var/run/backup_bucket_name ]]; then
    log "Updating to the ${AWS_S3_BUCKET} bucket"
    export AWS_S3_BUCKET
    echo "$AWS_S3_BUCKET" > /var/run/backup_bucket_name
  elif aws s3 ls "$AWS_S3_BUCKET" >/dev/null 2>&1; then
    log "Set-up ${AWS_S3_BUCKET} bucket"
    echo "$AWS_S3_BUCKET" > /var/run/backup_bucket_name
  else
    if aws s3 mb "s3://${AWS_S3_BUCKET}"; then
      log "Create ${AWS_S3_BUCKET} bucket"
      echo "$AWS_S3_BUCKET" > /var/run/backup_bucket_name
    else
      log "Could not create the ${AWS_S3_BUCKET} bucket!" >&2; exit 1
    fi
  fi
}

# Tar GZ the backup path
create_archive(){
  if [[ $(ls -A "$BACKUP_PATH" 2>/dev/null) ]]; then
    BACKUP_CMD_OUTPUT="Archive ${BACKUP_PATH}"
    BACKUP_CMD="tar cJ -C ${BACKUP_PATH} ."
    _backup_file="${NOW}.tar.xz"
  else
    log "${BACKUP_PATH} is empty!" >&2; exit 1
  fi
}

# Extract the latest archive
extract_archive(){
  mkdir -p /restore
  RESTORE_CMD_OUTPUT+=' and save to /restore'
  RESTORE_CMD="${RESTORE_CMD} | tar xJ --directory /restore"
}

# Encrypt the backup tar.gz
encrypt_archive(){
  import_gpg_keys

  if [[ -n "$GPG_RECIPIENT" ]]; then
    _gpg_cmd_options+=' --trust-model always'
    _recipients=''

    IFS=', ' read -ra GPG_RECIPIENT_ARRAY <<< "${GPG_RECIPIENT:-}"
    for recipient in "${GPG_RECIPIENT_ARRAY[@]}"; do
      _recipients+=" $recipient"
      _gpg_cmd_options+=" --recipient ${recipient}"
    done

    BACKUP_CMD_OUTPUT+=" with GPG encryption for${_recipients}"
    BACKUP_CMD="${BACKUP_CMD} | gpg ${_gpg_cmd_options} --encrypt"
  elif [[ -n "$GPG_PASSPHRASE" ]]; then
    _gpg_cmd_options+=' --cipher-algo AES256 --s2k-digest-algo SHA512'

    BACKUP_CMD_OUTPUT+=' with passphrase GPG encryption'
    BACKUP_CMD="${BACKUP_CMD} | gpg ${_gpg_cmd_options} --symmetric --passphrase '${GPG_PASSPHRASE}'"
  else
    return 0
  fi

  _backup_file="${_backup_file}.gpg"
}

# Decrypt archive (if the file is encrypted)
decrypt_archive(){
  if [[ -n "$GPG_PASSPHRASE" ]]; then
    import_gpg_keys
    _gpg_cmd_options+=" --pinentry-mode loopback --passphrase '${GPG_PASSPHRASE}'"
  else
    return 0
  fi

  RESTORE_CMD_OUTPUT+=', decrypt'
  RESTORE_CMD="${RESTORE_CMD} | gpg ${_gpg_cmd_options} --decrypt"
}

# Upload archive to AWS S3
upload_archive(){
  ensure_s3_bucket

  BACKUP_CMD_OUTPUT+=" to ${_aws_s3_path}/${_backup_type}/${_backup_file}"
  BACKUP_CMD="${BACKUP_CMD} | aws s3 cp --no-progress - ${_aws_s3_path}/${_backup_type}/${_backup_file}"
}

# Download the latest archive from S3
download_archive(){
  # Skip unless a bucket exists and you have permission to access it
  if aws s3api head-bucket --bucket "$AWS_S3_BUCKET" >/dev/null 2>&1; then
    log "Found AWS S3 bucket '${AWS_S3_BUCKET}'"
    set_up_s3

    _restore_path="$(get_latest_s3_archive)"
    _restore_file="$(basename "$_restore_path")"

    if [[ -n "$_restore_file" ]]; then
      RESTORE_CMD_OUTPUT="Extract archive from s3://${AWS_S3_BUCKET}/${_restore_path} ${_restore_file}"
      RESTORE_CMD="aws s3 cp --no-progress s3://${AWS_S3_BUCKET}/${_restore_path} -"
    fi
  fi
}

# List the latest S3 archive
get_latest_s3_archive(){
  if ! aws s3api list-objects \
    --bucket "$AWS_S3_BUCKET" \
    --prefix "$AWS_S3_PREFIX" \
    --query 'reverse(sort_by(Contents, &LastModified))[0].Key' \
    --output text
  then
    log 'Could not retrieve the last S3 object!' >&2; exit 1
  fi
}

# Run cron job
run_cron(){
  log "Run backups as a cron job for (${CRON_TIME})"
  cat > /etc/crontabs/root <<CRON
${CRON_TIME} /entrypoint.sh hourly
2 2 * * * /entrypoint.sh daily
3 3 * * 6 /entrypoint.sh weekly
5 5 1 * * /entrypoint.sh monthly
CRON
  exec crond -l 6 -f
}

# Backup archive
run_backup(){
  _backup_type="${1:-hourly}"
  log 'Start backup'
  create_archive
  encrypt_archive
  upload_archive
  log "${BACKUP_CMD_OUTPUT}"
  if ! eval "${BACKUP_CMD}"; then
    log 'Backup failed!' >&2; exit 1
  fi
}

# Restore archive
restore_backup(){
  _restore_file="${1:-}"
  log 'Restore backup'
  download_archive
  decrypt_archive
  extract_archive
  log "${RESTORE_CMD_OUTPUT}"
  if ! eval "${RESTORE_CMD}"; then
    log 'Restore failed!' >&2; exit 1
  fi
}

main(){
  # Parse command line arguments
  cmd="${1:-once}"
  case "$cmd" in
    once)
      run_backup
      ;;
    cron)
      run_backup & run_cron
      ;;
    hourly)
      run_backup 'hourly'
      ;;
    daily)
      run_backup 'daily'
      ;;
    weekly)
      run_backup 'weekly'
      ;;
    monthly)
      run_backup 'monthly'
      ;;
    restore)
      shift
      restore_backup "$@"
      ;;
    *)
      log "Unknown command: ${cmd}" >&2; exit 1
      ;;
  esac
}

main "${@:-}"
