#!/bin/bash
# script to read screen size and work out
# number of workspaces for the Unity window manager
# and then start various programs in various workspaces.
#
# The Unity window manager doesn't really have multiple
# workspaces, just one very big window, so some maths
# is involved.
#
# requires wmctrl (sudo apt install wmctrl)
# and xrandr (which should be already installed)
#
# set the number of workspaces horizontally thus:
# gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 4
# set the number of workspaces vertically thus:
# gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 1

function checkint()
{
  xint=$1
  xname=$2
  if [[ $xint =~ ^-?[0-9]+$ ]]; then
    :
  else
    echo "$ME: var: '$xname' not an integer: '$xint'" >&2
    exit 1
  fi
}
function winid()
{
  xsearch=$1
  id=$($WMCTRL -l | sed -n "/.*${xsearch}.*/s/^\([0-9a-fx]\+\) .*$/\1/p")
  echo $id
}
function movewin()
{
  # -e takes a parameter of 
  #    Gravity, X, Y, W, H
  #    gravity=0 uses the default value
  #    x,y,w,h can be -1 to use current value
  xid=$(winid $1)
  xpos=$(( ( ( $2 * hsz ) - hsz ) + hmarg ))
  $WMCTRL -ir $xid -e 0,$xpos,-1,-1,-1
}

ME=${0##*/}

XRANDR=$(which xrandr)
: "${XRANDR:?$ME could not find xrandr in path}"
WMCTRL=$(which wmctrl)
: "${WMCTRL:?$ME could not find wmctrl in path}"

# read the screen dimensions from xrandr
read hsz vsz < <($XRANDR | sed -n 's/^Screen 0.*, current \([0-9]\+\) x \([0-9]\+\), .*$/\1 \2/p')
# read the desktop dimensions from wmctrl
read mhsz mvsz < <($WMCTRL -d | sed -n 's/^.*DG: \([0-9]\+\)x\([0-9]\+\) .*$/\1 \2/p')

# the checkint function ensures that the integer arithmetic below works without error
checkint $hsz hsz
checkint $vsz vsz
checkint $mhsz mhsz
checkint $mvsz mvsz

whsz=$(( mhsz / hsz ))
wvsz=$(( mvsz / vsz ))

# start firefox and slack, wait for a bit, as they take a while to showup
firefox &
slack &
gvim &
sleep 20

# gvim on desk 2, firefox on 3 and slack on 4
# the Unity program launcher is about 65 pixels wide
# on my screen.
hmarg=65
movewin GVIM 2
movewin Firefox 3
movewin Slack 4
