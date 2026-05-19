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
  
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245"
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  # Freccia destra: accetta suggerimento solo se cursore è a fine riga
_autosuggest_or_forward() {
  if [[ $CURSOR -eq ${#BUFFER} ]]; then
    zle autosuggest-accept
  else
    zle forward-char
  fi
}
zle -N _autosuggest_or_forward
bindkey '^[[C' _autosuggest_or_forward
  bindkey '^E' autosuggest-accept
fi

# History substring search
if [ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# fzf-tab PRIMA di syntax-highlighting
if [ -r /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]; then
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
  
  # Preview avanzate con bat/eza
  zstyle ':fzf-tab:complete:*' fzf-preview ''
  zstyle ':fzf-tab:complete:*' fzf-flags '--height=60% --layout=reverse'
  
  # Directory: eza con icone
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null || ls -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null || ls -1 --color=always $realpath'
  
  # File: bat per syntax highlight
  zstyle ':fzf-tab:complete:(cat|less|nvim|vim|micro|code):*' fzf-preview 'bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || cat $realpath'
  
  # Systemd
  zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'
  
  # Variabili
  zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-):*' fzf-preview 'echo ${(P)word}'
  
  # Processi
  zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o pid,ppid,cmd,etime,%mem,%cpu --no-headers'
  zstyle ':fzf-tab:complete:kill:*' fzf-flags '--preview-window=down:3:wrap'
  
  # Environment
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
HISTSIZE=100000
SAVEHIST=100000

setopt appendhistory
setopt incappendhistory
setopt sharehistory
setopt extended_history
setopt histignorealldups
setopt histignorespace
setopt histreduceblanks
setopt histverify

# Bindings history
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5A' history-beginning-search-backward  # Ctrl+Up
bindkey '^[[1;5B' history-beginning-search-forward   # Ctrl+Down
bindkey '^R' history-incremental-search-backward

# ======================
# 3) Completamento potenziato
# ======================
autoload -Uz compinit bashcompinit
ZSH_COMPDUMP=${ZSH_COMPDUMP:-$HOME/.zcompdump}

# Compinit veloce con cache giornaliero
if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
  compinit -i -d "${ZSH_COMPDUMP}"
else
  compinit -C -i -d "${ZSH_COMPDUMP}"
fi
bashcompinit 2>/dev/null

setopt auto_menu
setopt complete_in_word
setopt always_to_end

# Completamento fuzzy
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*' \
  'r:|?=**'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{#81A1C1}%d%f'
zstyle ':completion:*:warnings' format '%F{#BF616A}nessun risultato%f'
zstyle ':completion:*' complete-options true
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'


# ======================
# 4) Prompt Nord-Arch con Git
# ======================
autoload -Uz colors vcs_info && colors

# Configurazione vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{#A3BE8C}●%f'
zstyle ':vcs_info:git:*' unstagedstr '%F{#EBCB8B}●%f'
zstyle ':vcs_info:git:*' formats '%F{#81A1C1}[%b]%f %c%u '
zstyle ':vcs_info:git:*' actionformats '%F{#BF616A}[%b|%a]%f %c%u '

# Funzione precmd che aggiorna vcs_info e titolo
precmd() {
  vcs_info
  print -Pn "\e]0;%~\a"
}

# PROMPT con singoli apici per espansione differita!
# Usa %v per vcs_info_msg_0_ invece della variabile diretta
setopt prompt_subst
PROMPT='%F{#3281EA}%~%f ${vcs_info_msg_0_}%F{#88C0D0}>%F{#81A1C1}>%F{#3281EA}>%f '

# ======================
# 5) Key bindings extra
# ======================
bindkey '^[f' forward-word
bindkey '^[b' backward-word
bindkey '^T' fzf-file-widget        # Ctrl+T: file finder
bindkey '^[c' fzf-cd-widget         # Alt+C: cd interattivo

# ======================
# 6) Alias moderni
# ======================
# ls → eza (sostituisce exa deprecato)
if command -v eza &>/dev/null; then
  alias ls='eza -lgh --icons --group-directories-first'
  alias ll='eza -lgha --icons --group-directories-first'
  alias lt='eza --tree --icons --level=2'
  alias lta='eza --tree --icons --level=2 -a'
else
  alias ls='ls --color=auto'
  alias ll='ls -la'
fi

# Cat → bat
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias less='bat --paging=always'
fi

# System
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Sc && yay -Sc'

# Mount helpers
alias mountntfs='sudo mount -t ntfs-3g -o big_writes,uid=1000,gid=1000,umask=022'
alias mountfat='sudo mount -t vfat -o uid=1000,gid=1000,umask=022'
alias mountexfat='sudo mount -t exfat -o uid=1000,gid=1000,umask=022'

# Apps
alias feh='feh --scale-down'
alias pomodoro='ssh pomo.sairashgautam.com.np'
alias tesiunipg='cd /home/ubermensch/.gemini/antigravity/scratch/tesi-perugia-formatter && source venv/bin/activate && streamlit run app.py
'

# VPN UniPG
alias vpn='sudo openfortivpn'
alias vpn-stop='sudo pkill -2 openfortivpn'
alias vpn-status='pgrep -a openfortivpn'
alias skytg24='bash ~/skytg24.sh'
alias orbita="cd ~/.gemini/antigravity/scratch/server-dashboard && npm run dev"
alias mpvhdmi='mpv --profile=hdmi'
alias telemia='mpv https://playerssl.telemia.tv/fileadmin/hls/TelemiaHD/telemia85_mediachunks.m3u8'
alias tmatrix='tmatrix -C blue -c default'
alias bugalalla='cwitch c bugalalla -s '

# ======================
# 7) Environment
# ======================
export EDITOR='micro'
export VISUAL='micro'
export TERM='xterm-kitty'
export COLORTERM='truecolor'
export PATH="$PATH:$HOME/.local/bin"

# FZF Nord theme + preview
export FZF_DEFAULT_OPTS="\
  --color=fg:#D8DEE9,bg:#2C2C2C,hl:#3281EA \
  --color=fg+:#2C2C2C,bg+:#3281EA,hl+:#EBCB8B \
  --color=info:#81A1C1,prompt:#3281EA,pointer:#BF616A,marker:#A3BE8C \
  --color=spinner:#88C0D0,header:#81A1C1,gutter:#2C2C2C \
  --height=60% --layout=reverse --border=rounded \
  --preview-window=right:50%:wrap \
  --bind='ctrl-/:toggle-preview' \
  --bind='ctrl-y:preview-up' \
  --bind='ctrl-e:preview-down'"

export FZF_CTRL_T_OPTS="\
  --preview 'bat --color=always --style=numbers --line-range=:50 {} 2>/dev/null || eza --tree --icons --level=1 {} 2>/dev/null || cat {}'"

export FZF_ALT_C_OPTS="\
  --preview 'eza --tree --icons --level=2 --color=always {}'"

# API Keys
export GEMINI_API_KEY="AIzaSyDZaPUqsx9A3r55iRk2HVGpr0zPukVrJ-M"

# ======================
# 8) Zoxide (smart cd)
# ======================
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
  alias cdi='zi'  # Interactive selection
fi

# ======================
# 9) Qualità di vita
# ======================
setopt autocd
setopt correct
setopt nocheckjobs
setopt nohup

# ======================
# 10) Funzioni utili
# ======================
# Extract archive
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz) tar xzf $1 ;;
      *.tar.xz) tar xf $1 ;;
      *.bz2) bunzip2 $1 ;;
      *.rar) unrar x $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar xf $1 ;;
      *.tbz2) tar xjf $1 ;;
      *.tgz) tar xzf $1 ;;
      *.zip) unzip $1 ;;
      *.Z) uncompress $1 ;;
      *.7z) 7z x $1 ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Mkcd: mkdir + cd
mkcd() {
  mkdir -p "$1" && cd "$1"
}
