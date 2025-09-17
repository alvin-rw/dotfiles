# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

####
# Auto completion
####
# --- Pure zsh completion setup (no oh-my-zsh) ---
autoload -Uz compinit
zmodload -i zsh/complist         # enables the interactive menu UI
compinit

# Nicer completion behavior
setopt no_list_beep              # no bell on completion
setopt complete_in_word          # complete in the middle of a word
bindkey '^I' complete-word       # Tab triggers completion (default is fine too)

# Menu UI: start a selection menu on first Tab; navigate with arrows/Tab
zstyle ':completion:*' menu select=1
bindkey -M menuselect '^M' accept-line
bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift-Tab goes backward

# Grouping, colors, formatting
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Case-insensitive + smart matching (foo → Foo, f-b → foo_bar, etc.)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=**'

# --- cd-specific tweaks ---
# Show directories first, but also list files (like many themes do).
# NOTE: cd only works with directories; selecting a file inserts its name but cd will fail.
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories files
zstyle ':completion:*:cd:*' file-patterns '*(/):directories' '*:files'
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Optional: make .. and hidden dirs show up consistently
zstyle ':completion:*:default' list-dirs-first yes
####
# End of auto completion
####


####
# manual changes
####
# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh # --> uninstalled
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

bindkey -e # use emacs key bindings
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

export PATH=$PATH:/home/ecv/.dotnet
export PATH=$PATH:/home/ecv/apps
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/ecv/go/bin
# uv python tools
export PATH=$PATH:/home/ecv/.local/bin

alias ll='eza -l'
alias l='eza -la'

eval $(keychain --quiet --eval) # keychain for ssh-agent
source <(fzf --zsh) # fuzzy finder

# GPG signing
if [[ -o interactive ]]; then
  _set_gpg_tty() {
    [[ -t 1 ]] || return
    # Prefer zsh's $TTY (no subprocess). Fall back to `tty` if needed.
    local cur_tty="$TTY"
    [[ -n "$cur_tty" && "$cur_tty" != "not a tty" ]] || cur_tty="$(tty 2>/dev/null)" || return
    if [[ "$GPG_TTY" != "$cur_tty" ]]; then
      export GPG_TTY="$cur_tty"
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
    fi
  }
  autoload -U add-zsh-hook
  add-zsh-hook precmd _set_gpg_tty
fi

source <(COMPLETE=zsh jj) # jujutsu dynamic completion

# for dotfiles management
# source: https://www.atlassian.com/git/tutorials/dotfiles
# to add more files use "dotfiles add .zshrc"
alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

####
# End of manual changes
####

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
