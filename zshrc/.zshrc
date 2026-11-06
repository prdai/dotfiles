#!/bin/zsh

# Modular Initialization
[[ $- != *i* ]] && return # Exit if not interactive

# ────────────────────────────── PATH ────────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/anaconda3/bin:$PATH"
export PATH="$HOME/.nvm/versions/node/current/bin:$PATH"
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# ────────────────────────── Environment ────────────────────────────
export EDITOR='nvim'
export VISUAL='code'
export TERMINAL='wezterm'
export BROWSER='open'
export LANG='en_US.UTF-8'
export TERM='xterm-256color'

# ───────────────────────── Shell Options ───────────────────────────
setopt AUTO_CD           # Type directory to cd
setopt CORRECT           # Autocorrect commands
setopt CORRECT_ALL       # Spelling correction for arguments
setopt CHECK_JOBS        # Check jobs on exit
setopt GLOB_STAR_SHORT   # Recursive globbing with **
setopt APPEND_HISTORY    # Append to history
setopt VI                # Vi mode in zsh
setopt PROMPT_SUBST      # Allow command substitution in prompt

# Directory navigation
setopt AUTO_PUSHD        # Push directories onto stack
setopt PUSHD_IGNORE_DUPS # Don't push duplicates
setopt PUSHD_SILENT      # Don't print directory stack

# ────────────────────────── Color Setup ────────────────────────────
if [[ -x /opt/homebrew/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
elif [[ -x /usr/local/bin/gdircolors ]]; then
    test -r ~/.dircolors && eval "$(gdircolors -b ~/.dircolors)" || eval "$(gdircolors -b)"
fi

# Enable colors
autoload -U colors && colors

# ────────────────────────── Load Environment Variables ────────────────────────────
load_env() {
    local env_file="${1:-.env}"
    if [[ -f "$env_file" ]]; then
        while IFS='=' read -r key value || [[ -n "$key" ]]; do
            # Skip comments and empty lines
            [[ $key =~ ^#.*$ ]] || [[ -z "$key" ]] && continue
            # Remove surrounding quotes from value if present
            value=$(echo "$value" | sed -e 's/^[[:space:]"'"'"']*//g' -e 's/[[:space:]"'"'"']*$//g')
            # Export the variable
            export "$key"="$value"
        done <"$env_file"
        echo "Loaded environment variables from $env_file"
    else
        echo "No $env_file file found"
    fi
}

# ────────────────────────── MongoDB Setup ────────────────────────────
run_mongo_container() {
    local container_name="mongo-container"

    # Check if container exists, stop and remove it
    if docker ps -a --filter "name=^/${container_name}$" --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo "Container ${container_name} already exists. Stopping and removing it..."
        docker stop ${container_name} >/dev/null 2>&1
        docker rm ${container_name} >/dev/null 2>&1
    fi

    # Run the MongoDB container in detached mode
    echo "Creating new MongoDB container..."
    docker run -d --name ${container_name} -p 27017:27017 mongo:latest

    # Output the connection string
    echo "mongodb://admin:password@localhost:27017/"
    echo "Container started successfully."
}

# ────────────────────────── Prompt Setup ────────────────────────────
__git_status() {
    local git_status=$(git status -s 2>/dev/null)
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)

    if [[ -n "$branch" ]]; then
        local status_indicators=""

        # Check for uncommitted changes
        if [[ -n "$git_status" ]]; then
            # Count different types of changes
            local untracked=$(echo "$git_status" | grep -c "??")
            local modified=$(echo "$git_status" | grep -c "M")
            local staged=$(echo "$git_status" | grep -c "A")
            local deleted=$(echo "$git_status" | grep -c "D")

            # Build status indicators
            [[ $untracked -gt 0 ]] && status_indicators+="?"
            [[ $modified -gt 0 ]] && status_indicators+="*"
            [[ $staged -gt 0 ]] && status_indicators+="+"
            [[ $deleted -gt 0 ]] && status_indicators+="-"
        fi

        # Display branch with status indicators
        if [[ -z "$status_indicators" ]]; then
            echo " %F{${PROMPT_DECO_COLOR}}(${branch})%f"
        else
            echo " %F{${PROMPT_DECO_COLOR}}(${branch}${status_indicators})%f"
        fi
    fi
}

# Zsh prompt function
precmd() {
    local EXIT="$?"
    local LIGHTNING='⚡'
    local VENV_COLOR="141"

    PROMPT="%F{${PROMPT_DECO_COLOR}}╭%f "
    PROMPT+="%F{${USER_COLOR}}%n%f%F{${PROMPT_DECO_COLOR}}@%f%F{${HOST_COLOR}}%m%f"

    # Show Python environment (venv or conda)
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        PROMPT+=" %F{${PROMPT_DECO_COLOR}}(%f%F{${VENV_COLOR}}venv:${venv_name}%f%F{${PROMPT_DECO_COLOR}})%f"
    elif [ -n "$CONDA_DEFAULT_ENV" ]; then
        PROMPT+=" %F{${PROMPT_DECO_COLOR}}(%f%F{${VENV_COLOR}}conda:${CONDA_DEFAULT_ENV}%f%F{${PROMPT_DECO_COLOR}})%f"
    fi

    PROMPT+=" %F{${PROMPT_DECO_COLOR}}▸%f%F{${PATH_COLOR}} %~%f"
    PROMPT+="%F{${PROMPT_DECO_COLOR}}$(__git_status)%f"

    if [[ $EXIT != 0 ]]; then
        PROMPT+="%F{${PROMPT_DECO_COLOR}}╰%f %F{${PROMPT_DECO_COLOR}}${LIGHTNING}%f "
    else
        PROMPT+="%F{${PROMPT_DECO_COLOR}}╰%f %F{${PROMPT_DECO_COLOR}}>%f "
    fi
}

# ────────────────────────── Prompt Color Configuration ────────────────────────────
PROMPT_DECO_COLOR="240"
USER_COLOR="142"
HOST_COLOR="166"
PATH_COLOR="109"

# ────────────────────────── History Config ────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=200000
# Removed invalid HIST_IGNORE_BOTH option
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ────────────────────────── Aliases ────────────────────────────────
# Safety & Enhanced Defaults
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias pi='command pi --approve'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listing (prefer exa if available, fallback to ls)
if command -v exa &> /dev/null; then
    alias ls='exa --color=always'
    alias ll='exa -lhgF --git --color=always'
    alias la='exa -lahgF --git --color=always'
    alias l='exa -lhgF --git --color=always'
    alias tree='exa --tree --level=2 --color=always'
    alias treeb='exa --tree --level=1 --color=always'
else
    alias ls='ls -G'
    alias ll='ls -alFG'
    alias la='ls -AG'
    alias l='ls -lFG'
    alias tree='find . -type d -name .git -prune -o -print | sed -e "s;[^/]*/;|____;g;s;____|; |;g"'
fi

# System
alias df='df -h'
alias free='vm_stat'
alias top='htop'

# Configuration Shortcuts
alias cvc='nvim ~/.config/nvim/'
alias czc='nvim ~/.zshrc'

# Git
alias g='git'
alias ga='git add'
alias gs='git status'
alias gd='git diff'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gcb='git checkout -b'
alias gb='git branch'
alias gl='git log'
alias gpl='git pull'
alias gpr='git push origin'
alias gf='git fetch'

# Python
alias py='python'
alias py3='python3'
alias pipi='pip install'

## Ruff
alias rc='ruff check'
alias rcf='ruff check --fix'
alias rf='ruff format'

# Directory
alias mkd='mkdir -p'
alias rmf='rm -rf'

# Zsh
alias reload='source ~/.zshrc'

# General
alias c='clear'
alias e='exit'
alias cl='clear && ls'
alias update='brew update && brew upgrade'
alias openapps='open -a "Google Chrome" & open -a "Spotify" & open -a "GitHub Desktop" & open -a "Visual Studio Code" &'

# macOS specific
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# ────────────────────────── Special Functions ────────────────────────────
extract() {
    for archive in $*; do
        if [ -f $archive ]; then
            case $archive in
            *.tar.bz2) tar xvjf $archive ;;
            *.tar.gz) tar xvzf $archive ;;
            *.bz2) bunzip2 $archive ;;
            *.rar) unrar e $archive ;;
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

# ────────────────────────── Audio Transcription ────────────────────────────
transcribe_audio() {
    local input_file=""
    local model="medium"
    local language="en"
    local task="transcribe"
    local output_format="txt"
    local show_help=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        -i | --input)
            input_file="$2"
            shift 2
            ;;
        -m | --model)
            model="$2"
            shift 2
            ;;
        -l | --language)
            language="$2"
            shift 2
            ;;
        -t | --task)
            task="$2"
            shift 2
            ;;
        -f | --format)
            output_format="$2"
            shift 2
            ;;
        -h | --help)
            show_help=true
            shift
            ;;
        *)
            if [[ -z "$input_file" ]]; then
                input_file="$1"
            fi
            shift
            ;;
        esac
    done

    # Show help if requested
    if [[ "$show_help" == true ]]; then
        echo "Usage: transcribe_audio [OPTIONS] INPUT_FILE"
        echo ""
        echo "Transcribe audio files using FFmpeg and Whisper"
        echo ""
        echo "Options:"
        echo "  -i, --input FILE     Input audio file (required)"
        echo "  -m, --model MODEL    Whisper model (tiny, base, small, medium, large)"
        echo "                       Default: medium"
        echo "  -l, --language LANG  Language code (en, es, fr, de, etc.)"
        echo "                       Default: en"
        echo "  -t, --task TASK      Task type (transcribe, translate)"
        echo "                       Default: transcribe"
        echo "  -f, --format FORMAT  Output format (txt, json, srt, vtt, tsv)"
        echo "                       Default: txt"
        echo "  -h, --help           Show this help message"
        echo ""
        echo "Examples:"
        echo "  transcribe_audio audio.ogg"
        echo "  transcribe_audio -m large -l es audio.mp3"
        echo "  transcribe_audio --model base --format srt audio.wav"
        return 0
    fi

    # Check if input file is provided
    if [[ -z "$input_file" ]]; then
        echo "Error: Input file is required"
        echo "Use 'transcribe_audio --help' for usage information"
        return 1
    fi

    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found"
        return 1
    fi

    # Check if required tools are available
    if ! command -v ffmpeg &>/dev/null; then
        echo "Error: ffmpeg is not installed"
        echo "Install with: brew install ffmpeg"
        return 1
    fi

    if ! command -v whisper &>/dev/null; then
        echo "Error: whisper is not installed"
        echo "Install with: pip install openai-whisper"
        return 1
    fi

    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local temp_audio="$temp_dir/audio.wav"
    local temp_output="$temp_dir/audio"

    echo "Processing audio file: $input_file"
    echo "Model: $model | Language: $language | Task: $task | Format: $output_format"
    echo ""

    # Convert audio to the format expected by Whisper
    echo "Converting audio format..."
    if ! ffmpeg -i "$input_file" -ar 16000 -ac 1 "$temp_audio" -loglevel error; then
        echo "Error: Failed to convert audio file"
        rm -rf "$temp_dir"
        return 1
    fi

    echo "Transcribing audio..."
    # Run Whisper transcription
    if ! whisper "$temp_audio" \
        --model "$model" \
        --language "$language" \
        --task "$task" \
        --output_format "$output_format" \
        --output_dir "$temp_dir"; then
        echo "Error: Whisper transcription failed"
        rm -rf "$temp_dir"
        return 1
    fi

    # Display the result
    echo ""
    echo "Transcription result:"
    echo "────────────────────────────────────────"

    local result_file="$temp_output.$output_format"
    if [[ -f "$result_file" ]]; then
        cat "$result_file"
    else
        echo "Error: Output file not found"
        rm -rf "$temp_dir"
        return 1
    fi

    echo ""
    echo "────────────────────────────────────────"

    # Cleanup
    rm -rf "$temp_dir"
    echo "Temporary files cleaned up"
}

# Alias for convenience
alias transcribe='transcribe_audio'

# ────────────────────────── Completions ────────────────────────────
# Load zsh completions
autoload -Uz compinit
compinit

# Completion settings
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# Load fzf if available
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ────────────────────────── Tool Initializations ────────────────────

# Conda
if [[ -f "$HOME/anaconda3/bin/conda" ]]; then
    __conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        [[ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]] && source "$HOME/anaconda3/etc/profile.d/conda.sh"
    fi
    unset __conda_setup
fi

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/nvm.sh.completion" ]] && source "$NVM_DIR/nvm.sh.completion"

# ────────────────────────── Environment Files ────────────────────────────

# Load global environment variables
[[ -f "$HOME/.env" ]] && load_env "$HOME/.env"
# Load project-specific environment variables
[[ -f "$(pwd)/.env" ]] && load_env "$(pwd)/.env"

# ────────────────────────── Local Overrides ────────────────────────

[[ -f ~/.zsh_local ]] && source ~/.zsh_local
[[ -f ~/.zsh_private ]] && source ~/.zsh_private
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ────────────────────────── macOS Specific ──────────────────────────────

# Homebrew completion
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

# ────────────────────────── Launchers ──────────────────────────────
#
# pnpm (adjust path for macOS)
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Google Cloud SDK (adjust for macOS installation)
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Go
export PATH="$(go env GOPATH)/bin:$PATH"

# bun completions
[ -s "/Users/ranugadisansa/.bun/_bun" ] && source "/Users/ranugadisansa/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/ranugadisansa/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions


[[ $- != *i* ]] && return

# Only run once even if you start a subshell (zsh inside zsh)
if command -v fastfetch >/dev/null 2>&1 && [[ -z "$FASTFETCH_RAN" ]]; then
  export FASTFETCH_RAN=1
  fastfetch 
fi

eval "$(zoxide init zsh)"

# Vim motions on the command line
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk          # `jk` exits insert mode
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT       # start each prompt in insert mode
ZVM_VI_HIGHLIGHT_BACKGROUND=cyan          # visible visual-mode highlight
[[ -f ~/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]] && \
  source ~/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

tmux-git-autofetch() {

(/home/prdai/dotfiles/tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --current &)

}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd tmux-git-autofetch
    

# pnpm
export PNPM_HOME="/home/prdai/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

. "$HOME/.local/share/../bin/env"

# speedrunner: warm tool daemons while typing
command -v speedrunner >/dev/null && eval "$(speedrunner init zsh)"
