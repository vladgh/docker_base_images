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
TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmp')

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Trap exit
bye(){
  log 'Exit detected; trying to clean up'
  clean_up; exit "${1:-0}"
}

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

# Clean-up
clean_up(){
  if [[ -d "${TMPDIR:-}" ]]; then
    if [[ "$TMPDIR" =~ tmp. ]]; then
      log  'Remove working files'
      rm -rf "${TMPDIR:?}"
    else
      log 'Could not remove working files'
    fi
  fi
}

# Import public GPG key
import_gpg_keys(){
  if [[ -d $GPG_KEY_PATH ]] && [[ ! $(ls -A "${GPG_KEY_PATH}" 2>/dev/null) ]]; then
    log "Import all keys in ${GPG_KEY_PATH} folder"
    gpg --batch --import "$GPG_KEY_PATH"/*
  elif [[ -s $GPG_KEY_PATH ]]; then
    log "Import key ${GPG_KEY_PATH}"
    gpg --batch --import "$GPG_KEY_PATH"
  elif [[ "$GPG_KEY_URL" =~ ^https://.* ]]; then
    log "Import key from ${GPG_KEY_URL}"
    curl "$GPG_KEY_URL" | gpg --import
  else
    file_env 'GPG_PASSPHRASE'
  fi
}

# Tar GZ the backup path
create_archive(){
  _backup_file="${NOW}.tar.xz"
  if [[ $(ls -A "$BACKUP_PATH" 2>/dev/null) ]]; then
    log "Create ${_backup_file}"
    tar cJf "$_backup_file" -C "$BACKUP_PATH" .
  fi
}

# Encrypt the backup tar.gz
encrypt_archive(){
  _backup_file_encrypted="${_backup_file}.gpg"

  import_gpg_keys

  if [[ -n "$GPG_RECIPIENT" ]] && [[ -s $_backup_file ]]; then
    log "Encrypt ${_backup_file_encrypted}"
    gpg \
      --trust-model always \
      --output "$_backup_file_encrypted" \
      --batch --yes \
      --encrypt \
      --recipient "$GPG_RECIPIENT" \
      "$_backup_file"
  elif [[ -n "$GPG_PASSPHRASE" ]] && [[ -s $_backup_file ]]; then
    echo "$GPG_PASSPHRASE" | gpg \
      --output "$_backup_file_encrypted" \
      --batch --yes \
      --passphrase-fd 0 \
      --armor \
      --symmetric \
      --cipher-algo=aes256 \
      "$_backup_file"
  else
    return
  fi

  _backup_file="${_backup_file_encrypted}"
}

# Create bucket, if it doesn't already exist and persist the name
ensure_s3_bucket(){
  if grep -q "${AWS_S3_BUCKET}" /var/run/backup_bucket_name 2>/dev/null; then
    log "Using '${AWS_S3_BUCKET}' bucket"
    export AWS_S3_BUCKET; AWS_S3_BUCKET="$(cat /var/run/backup_bucket_name)"
  elif [[ -s /var/run/backup_bucket_name ]]; then
    log "Updating to the '${AWS_S3_BUCKET}' bucket"
    export AWS_S3_BUCKET
    echo "$AWS_S3_BUCKET" > /var/run/backup_bucket_name
  elif aws s3 ls "$AWS_S3_BUCKET" >/dev/null 2>&1; then
    log "Set-up '${AWS_S3_BUCKET}' bucket"
    echo "$AWS_S3_BUCKET" > /var/run/backup_bucket_name
  else
    log "Create '${AWS_S3_BUCKET}' bucket"
    aws s3 mb "s3://${AWS_S3_BUCKET}"
    echo "$AWS_S3_BUCKET" > /var/run/backup_bucket_name
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

# Upload archive to AWS S3
upload_archive(){
  set_up_s3
  ensure_s3_bucket

  if [[ -s $_backup_file ]]; then
    aws s3 cp "$_backup_file" "${_aws_s3_path}/${_backup_type}/${_backup_file}"
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
    echo 'Could not retrieve the last S3 object' >&2; exit 1
  fi
}

# Get the archive to restore
get_archive(){
  if [[ -s $_restore_file ]]; then
    return
  else
    # Download the latest archive from S3
    set_up_s3
    _restore_file="$(get_latest_s3_archive)"

    if [[ -n "$_restore_file" ]]; then
      aws s3 cp "${_aws_s3_path}/${_restore_file}" "$_restore_file"
    fi
  fi
}

# Decrypt archive
decrypt_archive(){
  _decrypted_restore_file="decrypted.tar.xz"

  import_gpg_keys

  if [[ -s $_restore_file ]] && [[ $_restore_file == *.gpg ]]; then
    log "Decrypt ${_restore_file}"
    export GPG_TTY=/dev/console
    gpg --batch --output "$_decrypted_restore_file" --decrypt "$_restore_file"
  fi
}

# Extract the latest archive
extract_archive(){
  if [[ -s $_decrypted_restore_file ]]; then
    _extract_file="${_decrypted_restore_file}"
  elif [[ -s $_restore_file ]]; then
    _extract_file="${_restore_file}"
  else
    return
  fi

  log "Extract '${_extract_file}' to '/restore'"
  mkdir -p /restore
  tar xJf "$_extract_file" --directory /restore
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
  _backup_type=${1:-hourly}

  log 'Start backup'
  create_archive
  encrypt_archive
  upload_archive
}

# Restore archive
restore_backup(){
  _restore_file=${1:-}

  log 'Restore backup'
  get_archive
  decrypt_archive
  extract_archive
}

main(){
  # Trap exit
  trap 'EXCODE=$?; bye; trap - EXIT; echo $EXCODE' EXIT HUP INT QUIT PIPE TERM

  # Set working directory
  cd "$TMPDIR" || exit

  # Parse command line arguments
  cmd="${1:-once}"
  case "$cmd" in
    once)
      run_backup
      ;;
    cron)
      run_backup && run_cron
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

  # Clean-up
  clean_up
}

main "${@:-}"
