# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$PATH:$HOME/dotfiles/scripts"
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T | "
export EDITOR=nvim
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=river

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# set up XDG folders
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# GPG
export GPG_TTY=$(tty)

# Alias's to modified commands
alias yt-mp3='yt-dlp -f bestaudio --extract-audio --audio-quality 0 --audio-format mp3 -o "%(playlist_index)02d - %(title)s.%(ext)s"'
alias update-all='sudo xbps-install -Su && flatpak update'
alias ls='ls --color=auto'
alias sudovim='sudo -E vim'
PS1='\u\[\e[1;36m\]@\h❄ \w\ $ \[\e[0m\]'
alias espshell='previous_dir=$(pwd) && cd /home/$USER/esp-idf/ && . ./export.sh && cd "$previous_dir"'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias clr='clear'
alias apt-get='sudo apt-get'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'
alias record='wf-recorder && ffmpeg -i input.mp4 -c:v libx264 -preset veryslow -pix_fmt yuv420p -vf scale=-2:<height> -pass 1 -b:v <bitrate> -an -f null NUL'

extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

function check_update() {
	local SCRIPT_TO_RUN="update.sh"

	local LAST_RUN_FILE="$HOME/.update_script_last_run"

	local CURRENT_DATE=$(date +%s)

	local INTERVAL=$((2 * 24 * 60 * 60))
	local BLUE=$'\033[1;36m'   
	local RESET=$'\033[0m'

	local LAST_RUN_DATE=0

	if [[ -f "$LAST_RUN_FILE" ]]; then
	LAST_RUN_DATE=$(cat "$LAST_RUN_FILE")
	fi

	local TIME_DIFF=$((CURRENT_DATE - LAST_RUN_DATE))

	if (( TIME_DIFF >= INTERVAL )); then
		local PROMPT="${BLUE}❄ Do you want to update? (y/n):${RESET} "
		read -p "$PROMPT" response
		if [[ "$response" =~ ^[Yy]$ ]]; then
		    sudo "$SCRIPT_TO_RUN"
		    echo "$CURRENT_DATE" > "$LAST_RUN_FILE"
	else
	    echo "${BLUE}❄ Update skipped.${RESET} "
		fi
	fi
}

function check_terminal_size_and_run() {
    local width=$(tput cols)

    local min_width=120

    if [[ "$width" -ge "$min_width" ]]; then
        fastfetch

    fi
}
sleep 0.02 && check_terminal_size_and_run && check_update


