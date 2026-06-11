#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
#alias grep='grep4 --color=auto'
PS1='[\u@\h \W]\$ '

[[ -f ~/.bash_alias ]] && . ~/.bash_alias
[[ -f ~/.bash_starship ]] && . ~/.bash_starship

