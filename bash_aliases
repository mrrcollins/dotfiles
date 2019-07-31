#git aliases
alias gc="git add . && git commit -am"
alias gp="git push"
alias gs="git status -s"

alias rst="sed -i 's/ *@done\(.*\)//g'"

alias nsync='cd ~/notes;. notesync.sh;cd -'
alias today='cat ~/notes/Lists/goztoday.taskpaper | grep @today |grep -v @done'
alias tl='vim ~/notes/Lists/goztoday.taskpaper'
alias dl='vim ~/notes/Lists/gozdaily.taskpaper'
alias dtl='vim -O ~/notes/Lists/gozdaily.taskpaper ~/notes/Lists/goztoday.taskpaper'
alias tips="vim -c "Toc" ~/notes/Notes/tips.markdown"
alias ideas="vim -c "Toc" ~/notes/Notes/ideas.markdown"
alias gn="cd ~/notes"

alias menu='~/notes/gozprod.sh'

alias gj="gozjournal"
alias j='echo -e "\n" >> ~/notes/Journal/`date +"%Y"`.markdown;vim + +startinsert ~/notes/Journal/`date +"%Y"`.markdown'

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

