# System aliases
alias duf='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'
alias ls='ls -FX'

#git aliases
alias gc="git add . && git commit -am"
alias gp="git push"
alias gs="git status -s"

alias rst="sed -i 's/ *@done\(.*\)//g'"

alias nsync='cd ~/notes;. notesync.sh;cd -'
alias tl='vim ~/notes/Lists/goztoday.taskpaper'
alias dl='vim ~/notes/Lists/gozdaily.taskpaper'
alias dtl='vim -O ~/notes/Lists/gozdaily.taskpaper ~/notes/Lists/goztoday.taskpaper'
alias tips="vim -c "Toc" ~/notes/Notes/tips.markdown"
alias ideas="vim -c "Toc" ~/notes/Notes/ideas.markdown"
alias gn="cd ~/notes"
alias jt="tac ~/notes/Journal/`date +%Y`.markdown |awk '!flag; /^\#/{flag=1};' | tac"
alias menu='~/notes/gozprod.sh'

alias gj="gozjournal"
alias j='echo -e "\n" >> ~/notes/Journal/`date +"%Y"`.markdown;vim + +startinsert ~/notes/Journal/`date +"%Y"`.markdown'

#brantley aliases
alias b='brantley'
alias ba='brantley add'
alias bl='brantley ls'
alias blt='brantley ls today'
alias today='brantley ls today'

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
#alias l='ls -CFN'

