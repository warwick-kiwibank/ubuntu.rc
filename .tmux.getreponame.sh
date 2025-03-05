#!/usr/bin/bash

cd $1 # pane_current_path
basename -s .git `git config --get remote.origin.url` 2>/dev/null |
  sed -e's/^.*-//' -e's/\(.\)$/\1≫/'
