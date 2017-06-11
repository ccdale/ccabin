#!/bin/bash
# script to read screen size and work out
# number of workspaces for the unity window manager
# and then start various programs in various workspaces
#
# requires wmctrl (sudo apt install wmctrl)
# and xrandr (which should be already installed)
#
# set the number of workspaces horizontally thus:
# gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 4
# set the number of workspaces vertically thus:
# gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 1

read hsz vsz < <(xrandr | sed -n 's/^Screen 0.*, current \([0-9]\+\) x \([0-9]\+\), .*$/\1 \2/p')
read mhsz mvsz < <(wmctrl -d|sed -n 's/^.*DG: \([0-9]\+\)x\([0-9]\+\) .*$/\1 \2/p')
whsz=$(( mhsz / hsz ))
wvsz=$(( mvsz / vsz ))
echo "h: $whsz, v: $wvsz"
