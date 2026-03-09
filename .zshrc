#!/usr/bin/env zsh

# ======================
# 0) Sicurezza e silenzio
# ======================
set -o noclobber
setopt no_beep

# ======================
# 1) Plugin (ORDINE IMPORTANTE!)
# ======================
# fzf prima
if [ -r /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
fi
if [ -r /usr/share/fzf/completion.zsh ]; then
  source /usr/share/fzf/completion.zsh
fi

# Poi autosuggestions
if [ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  
  # Configura strategia suggerimenti: cronologia + completamenti
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245"
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  # Accetta suggerimento con Freccia Destra o End
  bindkey '^[[C' autosuggest-accept
  bindkey '^E' autosuggest-accept
fi

# History substring search
if [ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# fzf-tab PRIMA di syntax-highlighting
if [ -r /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]; then
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
  
  # Configura fzf-tab per mostrare descrizioni comandi/opzioni
  zstyle ':fzf-tab:complete:*' fzf-preview ''
  zstyle ':fzf-tab:complete:*' fzf-flags '--height=40%'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'
  zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-):*' fzf-preview 'echo ${(P)word}'
fi

# Syntax highlighting ULTIMO
if [ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
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

# Rigenera se corrotto o vecchio
if [[ ! -s $ZSH_COMPDUMP || $(( $(date +%s) - $(stat -c %Y "$ZSH_COMPDUMP" 2>/dev/null || echo 0) )) -gt 86400 ]]; then
  compinit -i
else
  compinit -C -i
fi
bashcompinit 2>/dev/null

setopt auto_menu
setopt complete_in_word
setopt always_to_end

# Completamento fuzzy migliorato
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*' \
  'r:|?=**'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}nessun risultato%f'

# Completamento per opzioni comandi
zstyle ':completion:*' complete-options true
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'

# ======================
# 4) Prompt (INVARIATO)
# ======================
autoload -Uz colors && colors
PROMPT='%F{blue}%~%f %F{red}>%F{yellow}>%F{cyan}>%f '

# ======================
# 5) Key bindings extra
# ======================
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

# Tweak FZF per il Tema Nord ad alto contrasto
export FZF_DEFAULT_OPTS="--color=fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C --color=fg+:#2E3440,bg+:#8FBCBB,hl+:#EBCB8B --color=info:#81A1C1,prompt:#8FBCBB,pointer:#BF616A,marker:#A3BE8C --border=none"

export GEMINI_API_KEY="AIzaSyDZaPUqsx9A3r55iRk2HVGpr0zPukVrJ-M"

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
alias pomodoro='ssh pomo.sairashgautam.com.np'

# VPN UniPG
alias vpn='sudo openfortivpn'
alias vpn-stop='sudo pkill -2 openfortivpn'
alias vpn-status='pgrep -a openfortivpn'
