#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
	xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
	xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
	xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
	xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
	for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

setxkbmap -layout us -variant altgr-intl
#xinput set-prop 11 283 -1 -1 -1
xsetroot -cursor_name left_ptr
xsetroot -solid "#646464"
export PATH=$PATH:$HOME/.scripts
export PATH=$PATH:$HOME/.gem/ruby/2.2.0/bin
nitrogen --restore
#wallpaper &
urxvtd &
sxhkd &
mpDris2 &
compton &
float &

#gsettings-data-convert &
xdg-user-dirs-gtk-update &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/gnome-settings-daemon/gnome-settings-daemon &
#/usr/lib/gnome-user-share/gnome-user-share &
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
export DE=gnome
export DESKTOP_SESSION=gnome
exec bspwm
#killall notify-osd
#exec cerbere
#exec gala
#exec openbox-session
#exec startkde
#exec budgie-session
#exec gnome-session
#exec gnome-session --session gnome-wayland
