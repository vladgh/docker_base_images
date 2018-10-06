#!/usr/bin/env bash
# Release script

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
GIT_TAG="$(git describe --always --tags)"
WRITE_CHANGELOG="${WRITE_CHANGELOG:-false}"
BUG_LABELS="${BUG_LABELS:-bug}"
ENHANCEMENT_LABELS="${ENHANCEMENT_LABELS:-enhancement}"

# Check if command exists
is_cmd() { command -v "$@" >/dev/null 2>&1 ;}

# Check if the repository is clean
git_clean_repo(){
  git diff --quiet HEAD || (
    echo 'ERROR: Commit your changes first'
    return 1
  )
}

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

  export MAJOR="${semver[0]}"
  export MINOR="${semver[1]}"
  export PATCH="${semver[2]}"
}

# Increment Semantic Version
increment(){
  generate_semantic_version

  case "${1:-patch}" in
    major)
      export MAJOR=$((MAJOR+1))
      ;;
    minor)
      export MINOR=$((MINOR+1))
      ;;
    patch)
      export PATCH=$((PATCH+1))
      ;;
    *)
      export PATCH=$((PATCH+1))
      ;;
  esac
}

# Generate log
generate_log(){
  GCG_CMD="--bug-labels ${BUG_LABELS} --enhancement-labels ${ENHANCEMENT_LABELS}"

  if is_cmd github_changelog_generator; then
    # If release is empty is the same as `unreleased`
    eval "github_changelog_generator $GCG_CMD --future-release ${RELEASE:-}"
  else
    echo 'ERROR: github_changelog_generator is not installed!'
    exit 1
  fi
}

# logic
main(){
  case "${1:-}" in
    major)
      increment major
      ;;
    minor)
      increment minor
      ;;
    patch)
      increment patch
      ;;
    unreleased)
      generate_log; exit 0
      ;;
    *)
      generate_log; exit 0
      ;;
  esac

  if ! is_cmd git; then echo 'ERROR: Git is not installed!'; exit 1; fi

  git_clean_repo

  RELEASE="v${MAJOR}.${MINOR}.${PATCH}"

  if [[ "$WRITE_CHANGELOG" == 'true' ]]; then
    generate_log

    git diff --quiet HEAD || (
      echo 'Commit CHANGELOG'
      git add CHANGELOG.md
      git commit --gpg-sign --message "Update change log for ${RELEASE}" CHANGELOG.md
    )
  fi

  echo "Tag  ${RELEASE}"
  git tag --sign "${RELEASE}" --message "Release ${RELEASE}"
  git push --follow-tags
}

# Run
main "${@:-}"
