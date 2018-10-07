#!/usr/bin/env bash
# Docker scripts
# https://docs.docker.com/docker-cloud/builds/advanced/

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
APPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd -P)"
GIT_TAG="$(git describe --always --tags)"
GIT_BRANCH="${GIT_BRANCH:-$(git symbolic-ref --short HEAD)}" # Specify the branch name manually when on a detached HEAD
BUILD_PATH="${BUILD_PATH:-/}"
DOCKERFILE_PATH="${DOCKERFILE_PATH:-Dockerfile}"
DOCKER_USERNAME="${DOCKER_USERNAME:-}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-}"
DOCKER_REPO="${DOCKER_REPO:-}"
DOCKER_TAG="${DOCKER_TAG:-$(if [[ "$GIT_BRANCH" == 'master' ]]; then echo latest; else echo "$GIT_BRANCH"; fi)}"
IMAGE_NAME="${IMAGE_NAME:-${DOCKER_REPO}:${DOCKER_TAG}}"

# Generate semantic version style tags
generate_semantic_version(){
  # If tag matches semantic version
  if [[ "$GIT_TAG" != v* ]]; then
    echo "Version (${GIT_TAG}) does not match semantic version; Skipping..."
    return
  fi

  # Break the version into components
  semver="${GIT_TAG#v}" # Remove the 'v' prefix
  semver="${semver%%-*}" # Remove the commit number
  IFS="." read -r -a semver <<< "$semver" # Create an array with version numbers

  export major="${semver[0]}"
  export minor="${semver[1]}"
  export patch="${semver[2]}"
}

# Deepen repository history
# When Docker Cloud pulls a branch from a source code repository, it performs a shallow clone (only the tip of the specified branch). This has the advantage of minimizing the amount of data transfer necessary from the repository and speeding up the build because it pulls only the minimal code necessary.
# Because of this, if you need to perform a custom action that relies on a different branch (such as a post_push hook), you won’t be able checkout that branch, unless you do one of the following:
#    $ git pull --depth=50
#    $ git fetch --unshallow origin
deepen_git_repo(){
  if [[ -f $(git rev-parse --git-dir)/shallow ]]; then
    echo 'Deepen repository history'
    git fetch --unshallow origin
  fi
}

# Build the image with the specified arguments
build_image(){
  deepen_git_repo

  echo 'Build the image with the specified arguments'
  (
  cd "${APPDIR}${BUILD_PATH}" # In Docker Hub this is `/` or `/dir`
  docker build \
    --build-arg VERSION="$GIT_TAG" \
    --build-arg VCS_URL="$(git config --get remote.origin.url)" \
    --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
    --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --file "$DOCKERFILE_PATH" \
    --tag "$IMAGE_NAME" \
    .
  )
}

# Push
push_image(){
  echo "Pushing ${IMAGE_NAME}"
  docker push "${IMAGE_NAME}"
}

# Tag image
# This creates semantic version style tags from latest (built just once).
# An alternative approach would be to use build rules (however, this triggers multiple builds for each tag, which is inefficient).
#
#     Type    Name                                  Location    Tag
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}.{\2}.{\3}
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}.{\2}
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}
tag_image(){
  generate_semantic_version

  for version in "${major}.${minor}.${patch}" "${major}.${minor}" "${major}"; do
    echo "Pushing version (${DOCKER_REPO}:${version})"
    docker tag "$IMAGE_NAME" "${DOCKER_REPO}:${version}"
    docker push "${DOCKER_REPO}:${version}"
  done
}

# Notify Microbadger
# Sample `.microbadger` tokens file:
#     #!/usr/bin/env bash
#     # MicroBadger tokens
#     declare -A MICROBADGER_TOKENS=(
#       ['vladgh/testAutobuildHooks']='ABCDEF='
#     )
#     export MICROBADGER_TOKENS

notify_microbadger(){
  local tokens_file
  tokens_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/.microbadger"

  if [[ -s "$tokens_file" ]]; then
    # shellcheck disable=1090
    . "$tokens_file"

    local token="${MICROBADGER_TOKENS[${DOCKER_REPO}]:-}"
    local url="https://hooks.microbadger.com/images/${DOCKER_REPO}/${token}"

    if [[ -n "$token" ]]; then
      echo "Notify MicroBadger: $(curl -sX POST "$url")"
    fi
  fi
}

# Tests
test_image(){
  export PATH="$PATH":~/bin
  # TODO dgoss run ...
}

# Logic
main(){
  export cmd="${1:-}"; shift || true
  case "$cmd" in
    build)
      build_image
      ;;
    push)
      push_image
      ;;
    tag)
      tag_image
      ;;
    notify)
      notify_microbadger
      ;;
    test)
      test_image
      ;;
    *)
      echo "'${cmd}' command is not implemented"
      ;;
  esac
}

# Run
main "${@:-}"
