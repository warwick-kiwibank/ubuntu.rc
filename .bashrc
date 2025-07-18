# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=5000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#HISTTIMEFORMAT="%Y%m%dT%H%M%S  "
HISTTIMEFORMAT="%s  "

# update and reload history after every command
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u: \w\a\]$PS1"
    ;;
*)
    ;;
esac

export PATH=$(<<HERE tr \\n :
/home/vagrant/ubuntu.rc/scripts
HERE
)$PATH

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Cursor colour and style
printf '%b' '\e]12;red\a'
cursor-style $VTE_CURSOR_STYLE_STEADY_BLOCK

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

gb() {
  git branch 2>/dev/null | awk '/^\*/{ORS=""; print $2}'
}
git_branch() {
  echo -n '(' && gb && echo -n ')'
}

# Add the functions from kube-ps1.sh to the current shell environment
source /home/vagrant/bin/kube-ps1.sh

# add completion of aws and kubectl
source <(kubectl completion bash)
complete -o default -o nospace -F __start_kubectl kubectl
complete -C $(type -p aws_completer) aws

# Update the PS1 / Prompt String 1 (a.k.a the bash prompt) with the git branch plus the
# Kubernetes context and namespace where appropriate
# e.g. vagrant:~/cip (main)(⎈ |apif_dev:default)$
PS1='\u:\w \[\e[32m\]$(git_branch)\[\e[0m\]$(kube_ps1)$ '

# Turn kube info off by default - turn it on by calling kubeon
kubeoff

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PYENV_ROOT="/home/vagrant/.pyenv"

export PATH=$(<<HERE tr \\n :
/home/vagrant/ubuntu.rc/scripts
$PYENV_ROOT/bin
/home/vagrant/.local/bin
/home/vagrant/bin
/home/vagrant/bin/adr-tools
/home/vagrant/.tfenv/bin
/usr/local/go/bin
/home/vagrant/go/bin
HERE
)$PATH

eval "$(pyenv init --path)"
export PIPX_DEFAULT_PYTHON="$(pyenv which python)"

if chage -l vagrant | grep -q 'password must be changed'
  then
    echo "Please change the vagrant user password from 'vagrant' before restarting the VM, or the restart will fail"
fi

# If user provided a personal login script then source it
if [[ -f ~/vm-personal-provisioning/personal_login.rc ]]
  then
    source ~/vm-personal-provisioning/personal_login.rc
fi
export PIPX_DEFAULT_PYTHON="$(pyenv which python)"
set -o vi

PATH="/home/vagrant/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/vagrant/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/vagrant/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/vagrant/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/vagrant/perl5"; export PERL_MM_OPT;



# Kiwibank repo symlinks
(
  for src in $(
      for x in tf aws azure
      do
        find * -maxdepth 0 -type d -exec [ -d "{}/.git" ] \; -name "kb-$x-*" -print
      done
    )
  do
    dst=$(cut -d- -f2- <<<$src)
    [ -e $dst ] || ln -sv $src $dst
    dst=$(cut -d- -f3- <<<$src)
    [ -e $dst ] || ln -sv $src $dst
  done
)
