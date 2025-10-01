#!/bin/bash

alacritty \
  --class floating_term \
  --title "Arch Info" \
  -e bash -c '
    clear
    neofetch
    echo
    cowsay -C -r "$(printf "%-30s\n%-30s\n%-30s\n%-30s" \
      "Welcome $(lsb_release -ds)" \
      "$(uname -r)" \
      "Boot $(systemd-analyze | awk -F "=" "{print \$2}" | awk "{print \$1}") sec" \
      "Online $(ip -4 a show wlan0 | awk "/inet / {print \$2}" | cut -d"/" -f1)")"
    echo
    echo -e "\nPremi [q] per uscire o [h] per visualizzare i keybindings di Hyprland"
    while :; do 
      read -n1 k
      case $k in
        q) break ;;
        h) 
          clear
          echo -e "\n\033[1mHYPRLAND KEYBINDINGS\033[0m"
          echo -e "\033[1m-------------------\033[0m"
          awk '\''
            /^bind/ {
              gsub(/[ \t]*[#;].*$/, "");
              if (match($0, /bind[em]?[ =]+([^,]*),[ \t]*(.*)/, arr)) {
                key = arr[1]; cmd = arr[2];
                gsub(/\$mainMod/, "SUPER", key);
                printf "\033[33m%-25s\033[0m → \033[36m%s\033[0m\n", key, cmd;
              }
            }'\'' ~/.config/hypr/hyprland.conf | sort
          echo -e "\nPremi [q] per uscire"
          ;;
      esac
    done'
