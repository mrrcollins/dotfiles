# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# save history for multiple terminals

if [ ! -d "${HOME}/.bash_history_log" ]; then
    mkdir "${HOME}/.bash_history_log"
fi

HISTSUFFIX=`tty | sed 's/\///g;s/^dev//g'`
HISTFILE="$HOME/.bash_history_log/bash_history_$HISTSUFFIX"
HISTTIMEFORMAT="%y-%m-%d %H:%M:%S "
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=1000
HISTFILESIZE=5000
shopt -s histappend
PROMPT_COMMAND='history -a'

PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007";history -a'

# Search history
function searchhistory() {
    grep -ri "${1}" ~/.bash_history_log/*
}
alias shistory=searchhistory



# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

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
    xterm-color) color_prompt=yes;;
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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Import local aliases
if [ -f ~/.bash_aliases.local ]; then
    source ~/.bash_aliases.local
fi


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

# Adds the current branch to the bash prompt when the working directory is
# part of a Git repository. Includes color-coding and indicators to quickly
# indicate the status of working directory.
#
# To use: Copy into ~/.bashrc and tweak if desired.
#
# Based upon the following gists:
# <https://gist.github.com/henrik/31631>
# <https://gist.github.com/srguiwiz/de87bf6355717f0eede5>
# Modified by me, using ideas from comments on those gists.
#
# License: MIT, unless the authors of those two gists object :)

git_branch() {
    # -- Finds and outputs the current branch name by parsing the list of
    #    all branches
    # -- Current branch is identified by an asterisk at the beginning
    # -- If not in a Git repository, error message goes to /dev/null and
    #    no output is produced
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

git_status() {
    # Outputs a series of indicators based on the status of the
    # working directory:
    # + changes are staged and ready to commit
    # ! unstaged changes are present
    # ? untracked files are present
    # S changes have been stashed
    # P local commits need to be pushed to the remote
    local status="$(git status --porcelain 2>/dev/null)"
    local output=''
    [[ -n $(egrep '^[MADRC]' <<<"$status") ]] && output="$output+"
    [[ -n $(egrep '^.[MD]' <<<"$status") ]] && output="$output!"
    [[ -n $(egrep '^\?\?' <<<"$status") ]] && output="$output?"
    [[ -n $(git stash list) ]] && output="${output}S"
    [[ -n $(git log --branches --not --remotes) ]] && output="${output}P"
    [[ -n $output ]] && output="|$output"  # separate from branch name
    echo $output
}

git_color() {
    # Receives output of git_status as argument; produces appropriate color
    # code based on status of working directory:
    # - White if everything is clean
    # - Green if all changes are staged
    # - Red if there are uncommitted changes with nothing staged
    # - Yellow if there are both staged and unstaged changes
    # - Blue if there are unpushed commits
    local staged=$([[ $1 =~ \+ ]] && echo yes)
    local dirty=$([[ $1 =~ [!\?] ]] && echo yes)
    local needs_push=$([[ $1 =~ P ]] && echo yes)
    if [[ -n $staged ]] && [[ -n $dirty ]]; then
        echo -e '\033[1;33m'  # bold yellow
    elif [[ -n $staged ]]; then
        echo -e '\033[1;32m'  # bold green
    elif [[ -n $dirty ]]; then
        echo -e '\033[1;31m'  # bold red
    elif [[ -n $needs_push ]]; then
        echo -e '\033[1;34m' # bold blue
    else
        echo -e '\033[1;37m'  # bold white
    fi
}

git_prompt() {
    # First, get the branch name...
    local branch=$(git_branch)
    # Empty output? Then we're not in a Git repository, so bypass the rest
    # of the function, producing no output
    if [[ -n $branch ]]; then
        local state=$(git_status)
        local color=$(git_color $state)
        # Now output the actual code to insert the branch and status
        echo -e "\x01$color\x02[$branch$state]\x01\033[00m\x02"  # last bit resets color
    fi
}

# Sample prompt declaration. Tweak as you see fit, or just stick
# "$(git_prompt)" into your favorite prompt.
PS1='\u@\h:\w$(git_prompt)\[\033[00m\]\$ '


PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(git_prompt)\$ ' 

# wp-cli functions
getdrafts() {
    MONTH=$1
    if [[ -z ${MONTH} ]]; then MONTH=$(date +"%m"); fi

    YEAR=$2
    if [[ -z ${YEAR} ]]; then YEAR=$(date +"%Y"); fi

    wp @e post list --year=${YEAR} --monthnum=${MONTH} --post_status=draft --order=asc
}

getpending() {
    MONTH=$1
    if [[ -z ${MONTH} ]]; then MONTH=$(date +"%m"); fi
    wp @e post list --year=$(date +"%Y") --monthnum=${MONTH} --post_status=pending --order=asc
}

editpost() {
    wp @e post edit $1
}

setpending() {
    POST=$1
    if [[ ! -z ${POST} ]]; then
        wp @e post update ${POST} --post_status=pending
    else
        echo "No post id"
    fi
}

post() {
    MSG=$1
    wp @r post create --format=status --post_content="${MSG}" --post_title="${MSG}" --post_category=355
}

,je() {
    ENTRY=$1
    echo -e "\n`date  +\"%Y/%m/%d %R\"` - ${1}" >> ~/notes/Journal/`date +"%Y"`.md
}

,uz() {
    file="${1%.zip}"

    mkdir ${file}
    cd ${file}
    unzip ../${1}
    
}

,findnote() {
    searchfor=$(echo "${*}" | sed 's/[]\/$*.^|#[]/\\&/g')
    echo "Searching all notes for ${searchfor}..."
    grep -riH --include "*.md" "${searchfor}" "${HOME}/notes"
}

# set PATH so it includes the scripts folder  if it exists
if [ -d "$HOME/.config/dotfiles/scripts" ] ; then
        PATH="$HOME/.config/dotfiles/scripts:$PATH"
fi

# Bashmarks
#unalias l
source bashmarks.sh

# Fix ls
export QUOTING_STYLE=literal

# Import local bash settings
# include `PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"` if on a Mac with coreutils provided by brew
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
