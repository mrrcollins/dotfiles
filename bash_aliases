#git aliases
alias gc="git add . && git commit -am"
alias gp="git push"
alias gs="git status -s"

alias rst="sed -i 's/ *@done\(.*\)//g'"
alias gj="gozjournal"

alias today='cat ~/Dropbox/Elements/notes/Lists/goztoday.taskpaper | grep @today |grep -v @done'
alias gt='vim ~/Dropbox/Elements/notes/Lists/goztoday.taskpaper'

alias gn="cd ~/Dropbox/Elements"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -N --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alFN'
alias la='ls -AN'
alias l='ls -CFN'

