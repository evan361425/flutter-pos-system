#!/bin/bash

set -eo pipefail

# This script translates the changelog of a build to multiple languages.
# Using the Google Cloud API for text generation, model: gemini-1.5-pro.
#
# Example:
# bash -x android/fastlane/translate-changelog.sh \
#   "android/fastlane/metadata/android/%s/changelogs/${BUILD_CODE}.txt" \
#   "${GOOGLE_API_KEY}"
#
# Arguments:
# - $1: changelogFile: The path template to the changelog file to translate.
# - $2: googleApiKey: The Google Cloud API key, see https://aistudio.google.com/app/apikey
#
# Supported languages:
# - zh-TW Traditional Chinese

function main() {
  local changelogFile="$1" googleApiKey="$2" languages="
zh-TW Traditional Chinese
"
  
  changelog="$(cat "$(printf "$changelogFile" 'en-US')")"

  for lang in $languages; do
    local langCode langName prompt changelog
    langCode="$(echo "$lang" | cut -d' ' -f1)"
    langName="$(echo "$lang" | cut -d' ' -f2-)"

    prompt="$(printf "$(cat android/fastlane/translate-prompt.txt)" "$langName")"

    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$googleApiKey" \
      -H 'Content-Type: application/json' \
      -X POST \
      -s \
      -d "$(jq -n \
        --arg prompt "$prompt" \
        --arg changelog "$changelog" \
        '{contents: [
          {role: "user", parts: [{text: $prompt}]},
          {role: "model", parts: [{text: "ok"}]},
          {role: "user", parts: [{text: $changelog}]}
        ]}')" \
      | jq -r '.candidates[0].content.parts[0].text' \
      > "$(printf "$changelogFile" "$langCode")"
  done
}

main "$@"
