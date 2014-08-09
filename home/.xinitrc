#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
#setxkbmap -layout es
xsetroot -cursor_name left_ptr
xsetroot -solid "#333333"
#nitrogen --restore
wallpaper &
urxvtd &
sxhkd &
export PANEL_FIFO="/tmp/panel-fifo"
export PATH=$PATH:$HOME/.scripts
export PATH=$PATH:/home/calarco/.gem/ruby/2.1.0/bin
mpDris2 &
compton --config .compton.conf -b

gsettings-data-convert &
xdg-user-dirs-gtk-update &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/gnome-settings-daemon/gnome-settings-daemon &
/usr/lib/gnome-user-share/gnome-user-share &
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
#exec cerbere
exec bspwm
#exec gnome-session
#exec enlightenment_start
#exec startdde
