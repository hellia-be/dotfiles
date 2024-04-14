#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Import colorscheme from wal asynchronously
(cat ~/.cache/wal/sequences &)
# Add support for TTYs
source ~/.cache/wal/colors-tty.sh

export PATH="$PATH:/home/hellia/.local/bin"

neofetch