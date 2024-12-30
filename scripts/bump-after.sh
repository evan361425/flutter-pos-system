#!/bin/bash

set -euo pipefail

repository=evan361425/flutter-pos-system

function trim_last_newline() {
  printf '%s' "$1"
}

function find_release() {
  local tag=$1
  
  gh api "repos/$repository/releases" \
    | jq -c '.[] | select( .name | contains("'"$tag"'"))'
}

function get_key() {
  local key
  set +e
  key="$(cat .gen-ai.key 2> /dev/null)"
  set -e

  if [ -z "$key" ]; then
    echo "Please create a file named .gen-ai.key with your Google Gemini API key."
    exit 1
  fi

  trim_last_newline "$key"
}

function main() {
  local tag=$1 buildCode=$2 release tmpl
  tmpl="android/fastlane/metadata/android/%s/changelogs/$buildCode.txt"
  
  release=$(find_release "$tag")

  trim_last_newline "$(echo "$release" | jq -r .body)" \
    | tr -d '\r' \
    | sed 's/## //g' \
    > "$(printf "$tmpl" "en-US")"

  bash android/fastlane/translate-changelog.sh "$tmpl" "$(get_key)"
}

main "$@"
