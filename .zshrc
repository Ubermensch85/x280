#!/usr/bin/env zsh

# ======================
# 0) Sicurezza e silenzio
# ======================
set -o noclobber
setopt no_beep

# ======================
# 1) Plugin
# ======================
# fzf (keybindings + completion) se presenti
if [ -r /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
fi
if [ -r /usr/share/fzf/completion.zsh ]; then
  source /usr/share/fzf/completion.zsh
fi

# autosuggestions
[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# history substring search (freccia su/giù)
[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] && \
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null

# syntax highlighting (ultimo tra i plugin)
[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# opzionale: fzf-tab
if [ -r /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]; then
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
fi

# ======================
# 2) History avanzata
# ======================
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt appendhistory
setopt incappendhistory
setopt sharehistory
setopt extended_history
setopt histignorealldups
setopt histignorespace
setopt histreduceblanks
setopt histverify

# Bindings history: frecce + Ctrl-R
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^R' history-incremental-search-backward

# ======================
# 3) Completamento potente
# ======================
autoload -Uz compinit bashcompinit
ZSH_COMPDUMP=${ZSH_COMPDUMP:-$HOME/.zcompdump}
if [[ ! -s $ZSH_COMPDUMP || $(( $(date +%s) - $(stat -c %Y "$ZSH_COMPDUMP" 2>/dev/null || echo 0) )) -gt 86400 ]]; then
  compinit -i
else
  compinit -C -i
fi
bashcompinit 2>/dev/null

setopt auto_menu
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}%d%f'

# ======================
# 4) Prompt
# ======================
autoload -Uz colors && colors
PROMPT='%F{blue}%~%f %F{red}>%F{yellow}>%F{cyan}>%f '

# ======================
# 5) Key bindings extra
# ======================
bindkey '^I' complete-word
bindkey '^[f' forward-word
bindkey '^[b' backward-word

# ======================
# 6) Alias
# ======================
if command -v exa &>/dev/null; then
  alias ls='exa -lgh --icons --group-directories-first'
  alias ll='exa -lgha --icons --group-directories-first'
else
  alias ls='ls --color=auto'
  alias ll='ls -la'
fi
alias update='sudo pacman -Syu'

# ======================
# 7) Env
# ======================
export EDITOR='micro'
export VISUAL='micro'
export TERM='xterm-256color'
export PATH="$PATH:$HOME/.local/bin"

# Tweak FZF per il Tema Nord ad alto contrasto (risolve problemi di visibilità)
export FZF_DEFAULT_OPTS="--color=fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C --color=fg+:#2E3440,bg+:#8FBCBB,hl+:#EBCB8B --color=info:#81A1C1,prompt:#8FBCBB,pointer:#BF616A,marker:#A3BE8C --border=none $FZF_DEFAULT_OPTS"

export GEMINI_API_KEY='AIzaSyAWKQ3BpJAhI8pmQFzTzYN7A_z6OzPas8U'

# ======================
# 8) Qualità di vita
# ======================
setopt autocd
setopt correct

# Mount helper
alias mountntfs='sudo mount -t ntfs-3g -o big_writes,uid=1000,gid=1000,umask=022'
alias mountfat='sudo mount -t vfat -o uid=1000,gid=1000,umask=022'
alias mountexfat='sudo mount -t exfat -o uid=1000,gid=1000,umask=022'
alias feh='feh --scale-down'
alias pomodoro='ssh aim.ftp.sh'
