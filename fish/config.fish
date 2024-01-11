alias duf='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'

alias ls="exa"
alias ll="exa -l"
alias tma="tmux new -ADs"

alias .="ls"
alias ..="cd .. && ls"
alias ...="cd ../.. && ls"
alias ....="cd ../../.. && ls"

# Vim
#alias v='vim $(fzf)'

#git aliases
alias gc="git add . && git commit -am"
alias gp="git push"
alias gs="git status -s"
alias gl="git log --stat"
alias rst="sed -i 's/ *@done\(.*\)//g'"

set fish_greeting

source /usr/local/share/fish/functions/fzf-key-bindings.fish
