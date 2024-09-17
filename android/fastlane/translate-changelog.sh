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
  local changelogFile="$1" googleApiKey="$2" languages="
zh-TW Traditional Chinese
"
  
  changelog="$(cat "$(printf "$changelogFile" 'en-US')")"

  while IFS= read -r lang; do
    lang="$(trim_string "$lang")"
    if [ -z "$lang" ]; then
      continue
    fi

    local langCode langName prompt changelog response
    langCode="$(echo "$lang" | cut -d' ' -f1)"
    langName="$(echo "$lang" | cut -d' ' -f2-)"
    echo "Translating changelog to $langName ($langCode)..."

    prompt="$(printf "$(cat android/fastlane/translate-prompt.txt)" "$langName")"
    echo "Prompt: $prompt"
    response="$(printf "## **Prompt:**\n* Translate the following product changelog from English to %s.\n* Ensure that each bullet point maintains the same prefix.\n* You should not give me any other information or anything prefix.\n\n**Please provide the English product changelog.**\n\nOnce you provide the English text, I can begin the translation process and ensure that the bullet points maintain their original prefix.\n" "$langName")"
    echo "Fixed response: $response"

    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$googleApiKey" \
      -H 'Content-Type: application/json' \
      -X POST \
      -s \
      -d "$(jq -n \
        --arg prompt "$prompt" \
        --arg response "$response" \
        --arg changelog "$changelog" \
        '{contents: [
          {role: "user", parts: [{text: $prompt}]},
          {role: "model", parts: [{text: $response}]},
          {role: "user", parts: [{text: $changelog}]}
        ]}')" \
      | jq -r '.candidates[0].content.parts[0].text' \
      > "$(printf "$changelogFile" "$langCode")"
  done <<< "$languages"
}

main "$@"
