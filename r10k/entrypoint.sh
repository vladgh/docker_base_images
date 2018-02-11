#!/usr/bin/env bash
# R10K Entry Point

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
REMOTE=${REMOTE:-}
POSTRUN=${POSTRUN:-}
CRONTIME="${CRONTIME:-}"
CACHEDIR=${CACHEDIR:-/var/cache/r10k}
CFG='/etc/puppetlabs/r10k/r10k.yaml'

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Generate R10K configuration
generate_configuration(){
  # Make sure R10K configuration directory exists
  mkdir -p "$(dirname ${CFG})"

  # Create R10K configuration
  if [[ ! -s "$CFG" ]]; then
    log 'Save R10K configuration'
    cat << EOF > "$CFG"
# The location to use for storing cached Git repos
:cachedir: '${CACHEDIR}'
EOF

    generate_sources
    generate_postrun_hook
  fi
}

generate_sources(){
  if [[ -n "$REMOTE" ]]; then
    log 'Save R10K sources configuration'
    cat << EOF >> "$CFG"

# A list of git repositories to create
:sources:
  # This will clone the git repository and instantiate an environment per
  # branch in /etc/puppetlabs/code/environments
  :main:
    remote: '${REMOTE}'
    basedir: '/etc/puppetlabs/code/environments'
EOF
  fi
}

generate_postrun_hook(){
  if [[ -n "$POSTRUN" ]]; then
    log 'Save R10K postrun hook configuration'
    cat << EOF >> "$CFG"

# Postrun Hook
postrun: ${POSTRUN}
EOF
  fi
}

# Run R10K command
run_command(){
  local IFS=' '
  log "Run 'r10k ${*}'"
  until r10k "${@:-}"; do
    log 'Command failed! Retrying in 10 seconds...' >&2
    sleep 10
  done
}

# Install cron job
run_cron(){
  log "Setup cron job '${CRONTIME}'"
  # $* produces all the scripts arguments separated by the first character of
  # $IFS which we set earlier to newline and tab, so we change it back to space
  local IFS=' '
  echo "${CRONTIME} sh -c 'r10k ${*:-}'" > /etc/crontabs/root
  exec crond -f -l 6
}

# Main function
main(){
  # Run command
  if [[ -n ${*:-} ]] ; then
    generate_configuration
    run_command "${@:-}"

    # Run cronjob
    if [[ -n "$CRONTIME" ]]; then
      run_cron "${@:-}"
    fi
  else
    r10k version
  fi
}

main "${@:-}"
