#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CACHE_HOME="$HOME/.local/share"

# This forces hyprland to start even when plasma is selected on the SDDM
#if [[ $(tty) == /dev/tty1 ]]; then
#	exec dbus-run-session Hyprland
#fi
