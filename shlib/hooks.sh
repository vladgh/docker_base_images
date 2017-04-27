#!/usr/bin/env bash
# Docker build hooks
# https://docs.docker.com/docker-cloud/builds/advanced/

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
GIT_TAG="$(git describe --always --tags)"
declare -A MICROBADGER_TOKENS=(
  ['vladgh/apache']='1LIUNGTtioEcpHJoQZzwK3qQPhE='
  ['vladgh/awscli']='mbMppUV6he_zmIGik-MeJ22K8a0='
  ['vladgh/backup']='ZjbRHMtrAhl9V2MWjWmOR0KWlGc='
  ['vladgh/:wdeluge']='BvOV7ec7tt2N207sgMKqFrGzSxs='
  ['vladgh/fpm']='OG17Glgq8CvSRFJjkK5vdC_pn_A='
  ['vladgh/gpg']='Sg_CkaULmDjZ0K3u5W1mIqXlkOk='
  ['vladgh/minidlna']='Qr9rUtKpdDGoUVh3tGwGTBzSmQ8='
  ['vladgh/puppet']='uj5nZE_tFQ3DyNFvERhnamfJbis='
  ['vladgh/puppetdb']='eLBcOfMSKHB7seTlBGvZD8VjK4A='
  ['vladgh/puppetserver']='Z8Ruox6vyG737HPGY6VKyeuL5qU='
  ['vladgh/puppetserverdb']='8d7IFiC0YkD1xJinK5UtgkQ88V0='
  ['vladgh/r10k']='OvMmZQPNL_0s5G-CYxrRmNFMDxE='
  ['vladgh/s3sync']='eB40MYq66N9GQvIisktwJVOL_tw='
  ['vladgh/webhook']='tRhT7nPREdQwptZxaMHDTgrazYY='
)

# Build hook
run_build_hook(){
  deepen_git_repo
  docker_build_image
}

# Post-Push hook
run_post_push_hook(){
  tag_semantic_versions
  notify_microbadger
}

# Deepen repository history
# When Docker Cloud pulls a branch from a source code repository, it performs a shallow clone (only the tip of the specified branch). This has the advantage of minimizing the amount of data transfer necessary from the repository and speeding up the build because it pulls only the minimal code necessary.
# Because of this, if you need to perform a custom action that relies on a different branch (such as a post_push hook), you won’t be able checkout that branch, unless you do one of the following:
#    $ git pull --depth=50
#    $ git fetch --unshallow origin
deepen_git_repo(){
  echo 'Deepen repository history'
  git fetch --unshallow origin
}

# Build the image with the specified arguments
docker_build_image(){
  echo 'Build the image with the specified arguments'
  docker build \
    --build-arg VERSION="${GIT_TAG}" \
    --build-arg VCS_URL="$(git config --get remote.origin.url)" \
    --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
    --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    -t "$IMAGE_NAME" .
}

# Publish version
publish_version(){
  local version="${1:-}"

  # Publish semantic versions based on latest only
  if [[ "$DOCKER_TAG" == 'latest' ]]; then
    echo "Pushing version (${DOCKER_REPO}:${version})"
    docker tag "$IMAGE_NAME" "${DOCKER_REPO}:${version}"
    docker push "${DOCKER_REPO}:${version}"
  fi
}

# Generate semantic version tags
tag_semantic_versions(){
  local IFS=$' ' # required by the version components below

  # If tag matches semantic version
  if [[ "$GIT_TAG" != v* ]]; then
    echo "Version (${GIT_TAG}) does not match semantic version; Skipping..."
    return
  fi

  # Break the version into components
  semver="${GIT_TAG#v}"
  semver="${semver%%-*}"
  semver=( ${semver//./ } )

  major="${semver[0]}"
  minor="${semver[1]}"
  patch="${semver[2]}"

  # Publish patch version
  publish_version "${major}.${minor}.${patch}"

  # Publish minor version
  publish_version "${major}.${minor}"

  # Publish major version
  publish_version "${major}"
}

notify_microbadger(){
  local repo="${DOCKER_REPO#*/}"
  local token="${MICROBADGER_TOKENS[${repo:-}]}"
  local url="https://hooks.microbadger.com/images/${repo}/${token}"

  if [[ -n "${token:-}" ]]; then
    echo "Notify MicroBadger: $(curl -X POST "$url")"
  fi
}
