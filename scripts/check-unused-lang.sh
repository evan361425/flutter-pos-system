#!/bin/bash

dst_file=docs/unused.txt
tmp_file=tmp_unused

# reset destination file
true > $dst_file

echo "Start check unused lang"

char='a'

printf 'Finish process char...'

while read -r key; do
  rm -f $tmp_file

  # shellcheck disable=SC2038
  find ./lib -type f -name '*.dart' \
    | xargs -I '{}' -P 8 bash -c "\
        test ! -f $tmp_file && grep -i -q $key {} && touch $tmp_file
      "

  if test ! -f "$tmp_file"; then
    echo "$key" | tee -a $dst_file
  fi

  first_char=${key:0:1}
  if test ! "$first_char" = "$char"; then
    printf "%s" "$char"
    char=$first_char
  fi
done <<< "$(jq -r 'keys[]' lib/l10n/app_zh.arb | grep -v '^@')"

rm -f $tmp_file

printf "\nDone!\n"
