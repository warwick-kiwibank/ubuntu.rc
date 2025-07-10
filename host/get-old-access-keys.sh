#!/bin/bash

find-infile() {
  find . -type f -size +1 -name iam-access-keys.\*.json -mmin -60 |
    tail -1
}
infile=$(find-infile)
if [ -z "$infile" ]; then
  . get-access-keys.sh && infile=$(find-infile) || exit $?
fi
<"$infile" \
  jq -r '
  map(
    select(                              # Only select keys
      .AccessKeyLastUsed.LastUsedDate |  # that are at least
      sub("\\+00:00$"; "Z") |            # 20 days old.
      (now - fromdate)/86400 > 19
    ) |
    select(       # Only select access keys
      length > 1  # from users who have at
    ) |           # least two keys.
    "\(.UserName):\(.AccessKeyId)"
  ) | join("\n")
'
