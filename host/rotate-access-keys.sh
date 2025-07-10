#!/bin/bash

DRYRUN=true

run() {
  logfile=$1
  shift
  pipe=$(mktemp -u)
  mkfifo $pipe
  (<$pipe tee -a "$logfile" &)
  echo $@ >&2
  $($DRYRUN) || "$@" >$pipe
  retval=$?
  rm $pipe
  return $retval
}
iam() {
  run rotate-access-keys.log aws iam $@ --output json
}
for user_key in $(. get-old-access-keys.sh || exit $?); do
  IFS=: read -r user key <<<"$user_key"
  iam create-access-key --user-name "$user" &&
  iam delete-access-key --access-key-id "$key"
done
