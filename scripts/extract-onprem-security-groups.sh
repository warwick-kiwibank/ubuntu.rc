#!/usr/bin/bash

if [ ! -e kb-tf-repos.json ]
then
  repos-local | grep ^kb-tf- | xargs hcl2json >kb-tf-repos.json
fi

if [ ! -e aws-security-groups.json ]
then
  <kb-tf-repos.json jq -f extract-aws-security-groups.jq >aws-security-groups.json
fi

# Extract Security Groups that have CIDR blocks containing on-prem CIDRs.
onprem_prefix=10.37.
<aws-security-groups.json jq '
  map(
    select(has("ingress"))
    | .ingress |= (
        map(
          .cidr_blocks.values |= map(select(startswith("'$onprem_prefix'")))
        )
        | map(
            select(.cidr_blocks.values | length > 0)
          )
      )
    | select(.ingress | length > 0)
  )
' |
  jq -s 'add | unique' >onprem-security-groups.json

# Select names of Security Groups having CIDR blocks that do not already contain
# the Zscaler CIDR.
zscaler_cidr=10.134.135.0/24
<onprem-security-groups.json jq '
  map(
    .file as $file
    | .ingress[]
    | select(.cidr_blocks.values | map(select(. == "'$zscaler_cidr'")) | length == 0)
    | {
        "description": .description,
        "file":        $file,
        "reference":   .cidr_blocks.reference,
        "cidrs":       .cidr_blocks.values,
    }
  )
  | select(length > 0)
' |
  tee onprem-security-groups-needing-zscaler-cidr.json |
  jq
