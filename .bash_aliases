# terminal

function get-term-height () {
  stty -a | awk 'match($0, "\\<rows +([0-9]+)", m) {print m[1]}'
}



# Colours
## https://stackoverflow.com/a/28938235

## Reset
export CLR_Normal='\033[0m'          # Text Reset

## Regular Colors
export CLR_Black='\033[0;30m'        # Black
export CLR_Red='\033[0;31m'          # Red
export CLR_Green='\033[0;32m'        # Green
export CLR_Yellow='\033[0;33m'       # Yellow
export CLR_Blue='\033[0;34m'         # Blue
export CLR_Purple='\033[0;35m'       # Purple
export CLR_Cyan='\033[0;36m'         # Cyan
export CLR_White='\033[0;37m'        # White

## Bold
export CLR_BBlack='\033[1;30m'       # Black
export CLR_BRed='\033[1;31m'         # Red
export CLR_BGreen='\033[1;32m'       # Green
export CLR_BYellow='\033[1;33m'      # Yellow
export CLR_BBlue='\033[1;34m'        # Blue
export CLR_BPurple='\033[1;35m'      # Purple
export CLR_BCyan='\033[1;36m'        # Cyan
export CLR_BWhite='\033[1;37m'       # White

## Underline
export CLR_UBlack='\033[4;30m'       # Black
export CLR_URed='\033[4;31m'         # Red
export CLR_UGreen='\033[4;32m'       # Green
export CLR_UYellow='\033[4;33m'      # Yellow
export CLR_UBlue='\033[4;34m'        # Blue
export CLR_UPurple='\033[4;35m'      # Purple
export CLR_UCyan='\033[4;36m'        # Cyan
export CLR_UWhite='\033[4;37m'       # White

## Background
export CLR_On_Black='\033[40m'       # Black
export CLR_On_Red='\033[41m'         # Red
export CLR_On_Green='\033[42m'       # Green
export CLR_On_Yellow='\033[43m'      # Yellow
export CLR_On_Blue='\033[44m'        # Blue
export CLR_On_Purple='\033[45m'      # Purple
export CLR_On_Cyan='\033[46m'        # Cyan
export CLR_On_White='\033[47m'       # White

## High Intensity
export CLR_IBlack='\033[0;90m'       # Black
export CLR_IRed='\033[0;91m'         # Red



# ls

## enable colour support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export autocolour=' --color=auto'
fi

alias ll="'ls'$autocolour -alF"
alias la="'ls'$autocolour -A"
alias  l="'ls'$autocolour -CF"
alias ld="ll -d"
alias lt="ll -tr"



# grep

alias  grep="grep $autocolour"
alias fgrep="fgrep$autocolour"
alias egrep="egrep$autocolour"



# watching

function watch () {
  sleep="$1"
  shift

  (
    trap 'tput rmcup; tput cnorm' EXIT # restore terminal on exit
    tput smcup # alternatve buffer
    tput civis # hide cursor
    clear="$(tput clear)"
    cursor_home="$(tput cup 0 0)"
    clear_eol="$(tput el)" # clear cursor to end of line
    clear_eos="$(tput ed)" # clear cursor to end of screen
    while true; do
      buf="$(eval "$@" 2>&1)"
      echo -n "$cursor_home${buf//$'\n'/$clear_eol$'\n'}$clear_eos"
      sleep "$sleep"
    done
  )
}

clock () {
  # Continuously displays the time.  Takes on optional variable to set the total
  # width of the displayed right-aligned string.  This defaults to 0 (i.e.,
  # left-aligned).
  watch 0.9 printf '"$CLR_BCyan%*s$CLR_Normal"' ${1:-0} '"$(date)"'
}

## "alert" alias for long running commands.  Use like so:
##   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'



# tmux

tmux-pane-id () {
  tmux display-message -p '#{pane_id}'
}



# terraform

alias tffmt='terraform fmt -recursive $(git rev-parse --show-toplevel)'
alias tfdoc='find $(git rev-parse --show-toplevel) -type d -exec test -e {}/README.md \; -exec terraform-docs {} \;' # Only update existing README files



# git

.gbr-stack-file () {
  stack=$(git rev-parse --show-toplevel)/.git/branch-stack
  touch -a $stack
  echo $stack
}

gbr-current () {
    git rev-parse --abbrev-ref HEAD
}

gbr-stack () {
  stack=$(.gbr-stack-file)
  grep --color=always -n '^' $stack
  printf '\033[0;32m->\033[0m'; gbr-current
}

gbr-pop () {
  stack=$(.gbr-stack-file)
  old_branch=$(gbr-current)
  if ( [ -s "$stack" ] )
  then
    git checkout "$(tail -1 "$stack")"
    new_branch=$(gbr-current)
    if ( [ "$new_branch" != "$old_branch" ] )
    then
      sed -i '$ d' "$stack"
    fi
  fi
  gbr-stack
}

gbr-push () {
  stack=$(.gbr-stack-file)
  old_branch=$(gbr-current)
  git checkout "$1"
  new_branch=$(gbr-current)
  if ( [ "$new_branch" != "$old_branch" ] )
  then
    printf '%s\n' "$old_branch" >>"$stack"
  fi
  gbr-stack
}

gbr-create () {
  git branch -c "$@" &&
    gbr-push "${@: -1}"
}

alias gbra="git branch"                       ; alias gbr=gbra
alias gcom="tffmt && git commit"              ; alias gcm=gcom
alias gche="git checkout"                     ; alias gch=gche ; alias gco=gche
alias gdif="git diff"                         ; alias gdf=gdif
alias glog="git log"                          ; alias glg=glog
alias gmto="git mergetool"                    ; alias gmt=gmto
alias gpul="git pull"                         ; alias gpl=gpul
alias gpus="git push"                         ; alias gps=gpus
alias greb="git rebase -i --autosquash main"  ; alias grb=greb
alias gres="git reset --hard HEAD"            ; alias grs=gres
alias gsho="git show"                         ; alias gsh=gsho
alias gsta="git status"                       ; alias gst=gsta ; alias gss=gsta
alias gbr.c="gbr-create"
alias gbr.l="gbr -l"
alias gbr.po="gbr-pop"
alias gbr.pu="gbr-push"
alias gdf.c="gdf --cached"
alias gdf.no="gdf --name-only"
alias glg.1="glg --oneline"
alias glg.no="glg --name-only"
alias glg.me='glg --author="$(git config user.name)"' # "mine"
alias gpl.m='( GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD); git checkout main && git pull; git checkout $GIT_BRANCH; )'
alias grb.o="gpl.m && grb"
alias gsh.no="gsh --name-only"

## map x-y to x.y
for a in $(alias -p | perl -nle '/^alias (g\w+\.\w+)=/ and print $1')
do
  alias $(tr . - <<<$a)=$a
done


git-continuous-status () {
  watch 3 gbr-stack\; echo\; gss
}

git-continuous-fetch-and-diff () {
  nlines=${1:--0}
  diff_range=${2:-origin/main..}
  watch 9                                                         \
    printf "'diff $CLR_BPurple%s$CLR_Normal\\n'" "'$diff_range'"\;\
    git fetch \>/dev/null\;                                       \
    gdf --color "'$diff_range'"   \|                              \
    grep -Ev '[+-]\{3\}\ [ab]\\/' \|                              \
    head -n$nlines
}

# git-tmux

git-tmux-status-pane ()
{
  right_pane_width=72
  lower_pane_height=48

  current_directory=$(pwd)
  TMUX_original_pane=$(tmux-pane-id)
  tmux split-pane -h \; resize-pane -x$right_pane_width
  tmux select-pane -T clock
  TMUX_clock_pane=$(tmux-pane-id)
  tmux split-pane -v
  tmux select-pane -T git_status
  TMUX_git_status=$(tmux-pane-id)
  tmux select-pane -t$TMUX_clock_pane
  tmux resize-pane -y1
  tmux send-keys "clock $right_pane_width; "
  tmux send-keys Enter
  tmux select-pane -t$TMUX_git_status
  tmux send-keys "cd '$current_directory'; "
  tmux send-keys "git-continuous-status; "
  tmux send-keys Enter
  tmux split-pane -v \; resize-pane -y$lower_pane_height
  tmux select-pane -T git_diff
  tmux send-keys "cd '$current_directory'; "
  tmux send-keys "setterm -linewrap off; "
  tmux send-keys "git-continuous-fetch-and-diff $lower_pane_height; "
  tmux send-keys Enter
  tmux select-pane -t$TMUX_original_pane
}

