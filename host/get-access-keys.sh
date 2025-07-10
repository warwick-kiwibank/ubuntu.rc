#!/bin/bash

(
  aws iam list-users |
  jq -r .Users[] |
  jq .UserName |
  xargs -tL1 aws iam list-access-keys --user-name |
  jq .AccessKeyMetadata[] |
  tee >(
    jq -r .AccessKeyId |
    xargs -tI{} sh -c '
      aws iam get-access-key-last-used --access-key-id {} |
      jq ".AccessKeyId = \"{}\"" '
  )
) |
jq -s '
  group_by(.UserName) |
  map({(.[0].UserName): group_by(.AccessKeyId) |
  map(add) |
  sort_by(.AccessKeyLastUsed.LastUsedDate)}) |
  add | add
' >iam-access-keys.$(date +%Y%m%d-%H%M).json
