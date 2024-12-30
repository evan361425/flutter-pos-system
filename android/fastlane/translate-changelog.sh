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

#######################################
# Trim leading and trailing whitespace
# Usage:
#   trim_string "   example   string    "
# Arguments:
#   $1: The string to trim
# Outputs:
#   The trimmed string
#######################################
function trim_string() {
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s' "$_"
}

function main() {
  local changelogFile="$1" googleApiKey="$2" changelog languages="
zh-TW Traditional Chinese
"
  
  changelog="$(cat "$(printf "$changelogFile" 'en-US')")"

  while IFS= read -r lang; do
    lang="$(trim_string "$lang")"
    if [ -z "$lang" ]; then
      continue
    fi

    local langCode langName prompt body resp
    langCode="$(echo "$lang" | cut -d' ' -f1)"
    langName="$(echo "$lang" | cut -d' ' -f2-)"
    echo "===== Translating changelog to $langName ($langCode)..."

    prompt="$(printf "$(cat android/fastlane/translate-prompt.txt)" "$langName" "$changelog")"
    body="$(jq -n \
        --arg prompt "$prompt" \
        '{contents: [
          {parts: [{text: $prompt}]}
        ]}')"

    resp="$(curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-8b:generateContent?key=$googleApiKey" \
      -H 'Content-Type: application/json' \
      -X POST \
      -s \
      -d "$body" \
      | jq -r '.candidates[0].content.parts[0].text' \
      | tr -d '\r')"
    
    echo "$resp"
    printf "%s" "$resp" > "$(printf "$changelogFile" "$langCode")"
  done <<< "$languages"
}

main "$@"
