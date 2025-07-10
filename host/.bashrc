export SSL_CERT_FILE=/c/Users/wallen01/full-trust-bundle.pem
export SSL_CERT_FILE=/c/Users/wallen01/full-trust-bundle.pem

alias l='ls'
alias ls='ls -ls'
alias ll='ls -ls'
alias la='ls -lsa'
alias lt='ls -lstra'

export vm_target=kb_ubuntu_dev
function vm_ssh() {
  ssh -t "$vm_target" "$@"
}
function tm () {
  if [ "$1" == "-l" ] || [ "$1" == "--list" ]
  then
    vm_ssh "tmux list-sessions"
  else
    name="${1:-vagrant}"
    echo -ne "\e]0;$name@$vm_target\a"
    vm_ssh "
      export DISPLAY=:0              ;
      tmux start-server   2>/dev/null;
      tmux has-session    -t '$name' ||
      tmux new-session    -ds'$name' ;
      tmux attach-session -t '$name' ;
    "
  fi
}

set -o vi

cd ~
export SSL_CERT_FILE=/c/Users/wallen01/full-trust-bundle.pem
