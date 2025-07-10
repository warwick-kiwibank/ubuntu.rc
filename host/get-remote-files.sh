#!/bin/bash

clip() {
  tee >(head) >(sed -z s/\\n$// | clip.exe) >/dev/null
  sync
  </dev/tty read -sp $'\nPress enter...'
  echo -en '\033[1K\r'
}
for f in $(
  ssh -t kb_ubuntu_dev "find * -wholename '$1' -print0" |
    xargs -0 echo
)
do
  g=$(<<<$f sed s,.*/,,)
  ssh -t kb_ubuntu_dev "cat '$f'" >$g
  <<<$g clip
  <$g clip
done
