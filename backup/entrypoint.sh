#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
AWS_S3_BUCKET="${AWS_S3_BUCKET:-backup_$(date +%s | sha256sum | base64 | head -c 16 ; echo)}"
AWS_S3_PREFIX="${AWS_S3_PREFIX:-}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
GPG_PASSPHRASE="${GPG_PASSPHRASE:-}"
GPG_RECIPIENT="${GPG_RECIPIENT:-}"
GPG_KEY_PATH="${GPG_KEY_PATH:-/keys}"
GPG_KEY_URL="${GPG_KEY_URL:-}"
BACKUP_PATH="${BACKUP_PATH:-/backup}"
CRON_TIME="${CRON_TIME:-8 */8 * * *}"
NOW=$(date +"%Y-%m-%d_%H-%M-%S")
TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmp')

# Log message
log(){
  echo "$(date): ${*}"
}

# Import public GPG key
import_gpg_keys(){
  if ls -A "$GPG_KEY_PATH" >/dev/null 2>&1; then
    log 'Import all keys in /keys folder'
    gpg --batch --import "$GPG_KEY_PATH"/*
  elif [[ "$GPG_KEY_URL" =~ ^https://.* ]]; then
    log "Import key from ${GPG_KEY_URL}"
    curl "$GPG_KEY_URL" | gpg --import
  fi
}

# Tar GZ the backup path
create_archive(){
  export BACKUP_FILE="${NOW}.tar.xz"
  if [[ "$(ls -A "$BACKUP_PATH" 2>&1)" ]]; then
    log "Create ${BACKUP_FILE}"
    tar cJf "$BACKUP_FILE" -C "$BACKUP_PATH" .
  fi
}

# Encrypt the backup tar.gz
encrypt_archive(){
  export BACKUP_FILE_ENCRYPTED="${BACKUP_FILE}.gpg"
  if [[ -n "$GPG_RECIPIENT" ]] && [[ -s "$BACKUP_FILE" ]]; then
    log "Encrypt ${BACKUP_FILE_ENCRYPTED}"
    gpg \
      --trust-model always \
      --output "$BACKUP_FILE_ENCRYPTED" \
      --batch --yes \
      --encrypt \
      --recipient "$GPG_RECIPIENT" \
      "$BACKUP_FILE"
  elif [[ -n "$GPG_PASSPHRASE" ]] && [[ -s "$BACKUP_FILE" ]]; then
    echo "$GPG_PASSPHRASE" | gpg \
      --output "$BACKUP_FILE_ENCRYPTED" \
      --batch --yes \
      --passphrase-fd 0 \
      --armor \
      --symmetric \
      --cipher-algo=aes256 \
      "$BACKUP_FILE"
  fi
}

# Create bucket, if it doesn't already exist and persist the name
ensure_s3_bucket(){
  if grep -q "${AWS_S3_BUCKET}" /var/run/backup_bucket_name; then
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

# Upload archive to AWS S3
upload_archive(){
  # Copy to AWS S3
  if [[ -s "$BACKUP_FILE_ENCRYPTED" ]]; then
    aws s3 cp "$BACKUP_FILE_ENCRYPTED" "${AWS_S3_PATH}/${BACKUP_TYPE}/${BACKUP_FILE_ENCRYPTED}"
  elif [[ -s "$BACKUP_FILE" ]]; then
    aws s3 cp "$BACKUP_FILE" "${AWS_S3_PATH}/${BACKUP_TYPE}/${BACKUP_FILE}"
  fi
}

# Backup archive
backup_archive(){
  export BACKUP_TYPE=${1:-hourly}

  create_archive
  encrypt_archive
  ensure_s3_bucket
  upload_archive
}

# List the latest S3 archive
get_latest_s3_archive(){
  if ! aws s3api list-objects \
    --bucket "$AWS_S3_BUCKET" \
    --prefix "$AWS_S3_PREFIX" \
    --query 'reverse(sort_by(Contents, &LastModified))[0].Key' \
    --output text
  then
    echo 'Could not retrieve the last S3 object'; exit 1
  fi
}

# Download the latest archive from S3
download_s3_archive(){
  aws s3 cp "s3://${AWS_S3_PATH}/${RESTORE_FILE}" "$RESTORE_FILE"
}

# Decrypt archive
decrypt_archive(){
  export RESTORE_FILE_DECRYPTED="decrypted.tar.xz"
  if [[ -s "$RESTORE_FILE" ]]; then
    log "Decrypt ${RESTORE_FILE}"
    export GPG_TTY=/dev/console
    gpg --batch --output "$RESTORE_FILE_DECRYPTED" --decrypt "$RESTORE_FILE"
  fi
}

# Extract the latest archive
extract_archive(){
  if [[ -s "$RESTORE_FILE_DECRYPTED" ]]; then
    log "Extract '${RESTORE_FILE_DECRYPTED}' to '/restore'"
    mkdir -p /restore
    tar xJf "$RESTORE_FILE_DECRYPTED" --directory /restore
  fi
}

# Restore archive
restore_archive(){
  export RESTORE_FILE; RESTORE_FILE="$(get_latest_s3_archive)"

  download_s3_archive
  decrypt_archive
  extract_archive
}

# Remove archives
clean_up(){
  # Clean-up
  if [[ -d "$TMPDIR" ]]; then
    if [[ "$TMPDIR" =~ tmp. ]]; then
      log  'Remove working files'
      rm -rf "${TMPDIR:?}"
    else
      log 'Could not remove working files'
    fi
  fi
}

# Trap exit
bye(){
  log 'Exit detected; trying to clean up'
  clean_up; exit "${1:-0}"
}

main(){
  # Trap exit
  trap 'bye $?' HUP INT QUIT TERM

  if [[ -n "$AWS_S3_PREFIX" ]]; then
    AWS_S3_PATH="s3://${AWS_S3_BUCKET}/${AWS_S3_PREFIX}"
  else
    AWS_S3_PATH="s3://${AWS_S3_BUCKET}"
  fi

  # Import GPG keys
  import_gpg_keys

  # Set working directory
  cd "$TMPDIR" || exit

  # Parse CLI
  cmd="${1:-once}"
  case "$cmd" in
    once)
      ensure_s3_bucket
      backup_archive
      ;;
    cron)
      log 'Start initial backup'
      backup_archive 'hourly'

      cat > /etc/crontabs/root <<CRON
${CRON_TIME} /entrypoint.sh hourly
2 2 * * * /entrypoint.sh daily
3 3 * * 6 /entrypoint.sh weekly
5 5 1 * * /entrypoint.sh monthly
CRON
      log "Run backups as a cronjob for ${CRON_TIME}"
      exec crond -l 2 -f
      ;;
    hourly)
      backup_archive 'hourly'
      ;;
    daily)
      backup_archive 'daily'
      ;;
    weekly)
      backup_archive 'weekly'
      ;;
    monthly)
      backup_archive 'monthly'
      ;;
    restore)
      log 'Restoring files'
      restore_archive
      ;;
    *)
      log "Unknown command: ${cmd}"; exit 1
      ;;
  esac

  # Clean-up
  clean_up
}

main "${@:-}"
