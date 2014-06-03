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

setxkbmap -layout es
xsetroot -cursor_name left_ptr
xsetroot -solid "#333333"
nitrogen --restore
sxhkd &
urxvtd &
/usr/lib/lxpolkit/lxpolkit &
export PANEL_FIFO="/tmp/panel-fifo"
export PATH=$PATH:$HOME/.scripts
mpDris2 &
compton --config .compton.conf -b
exec bspwm
#exec gnome-session
