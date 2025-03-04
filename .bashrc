#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias grep='grep --color=auto'
alias cd='z'
alias cat="bat --paging=never"
alias ls="eza --git --icons=always"
alias clean='yay -Rns $(pacman -Qtdq)'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'
alias shutdown='systemctl poweroff'
alias wifi='nmtui'
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gst="git stash"
alias gsp="git stash; git pull"
alias gfo="git fetch origin"
alias gcheck="git checkout"
alias gcredential="git config credential.helper store"

# POSH
POSH=agnoster
eval "$(oh-my-posh init bash --config $HOME/.config/ohmyposh/EDM115-newline.omp.json)"

# PATH
export PATH="$PATH:/home/hellia/.local/bin/:/usr/lib/ccache/bin/"

# Defaults
export EDITOR="vim"
export VISUAL="vim"

# Fuzzy finder
eval "$(fzf --bash)"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
_fzf_compgen_path() {
	fd --hidden --exclude .git . "$1"
}
_fzf_compgen_dir() {
	fd --type=d --hidden --exclude .git . "$1"
}
source ~/Documents/git/fzf-git.sh/fzf-git.sh
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
_fzf_comprun() {
	local command=$1
	shift
	case "$command" in
		cd)		fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
		export|unset)	fzf --preview "eval 'echo \${}'" "$@" ;;
		ssh)		fzf --preview 'dig {}' "$@" ;;
		*)		fzf --preview "$show_file_or_dir_preview" "$@" ;;
	esac
}

# Thefuck
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# Zoxide
eval "$(zoxide init bash)"

# Autostart
if [[ $(tty) == *"pts"* ]]; then
	fastfetch --config examples/13
else
	echo
		if [ -f /bin/qtile ]; then
			echo "Start Qtile X11 with command Qtile"
		fi
		if [ -f /bin/hyprctl ]; then
			echo "Start Hyprland with command Hyprland"
		fi
fi
