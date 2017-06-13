#!/bin/bash
#
# script to start a program and automatically place it on the
# required unity desktop
# see unity-startup-windows.sh for a baked in version

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
function checkstr()
{
  xstr=$1
  xname=$2
  if [ ${#xstr} -lt 1 ]; then
    echo "Empty string: $xname" >&2
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
  xpos=$(( ( ( $2 * hsz ) - hsz ) + hmargin ))
  $WMCTRL -ir $xid -e 0,$xpos,-1,-1,-1
}

ME=${0##*/}

if [ "$1" = "-h" ]; then
  echo "$ME <program> <title> <desktop no.>"
  echo
  echo "  Places the <program> with the (partial) window
  title <title> on desktop <desktop no.>"
  echo
  echo "  i.e. $ME gvim GVIM 2 
    will place the gvim window on desk 2"
  echo
  exit 0
fi

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

xtimeout=20

hmargin=65

prog=$1
checkstr $prog prog
title=$2
checkstr $title title
desk=$3
checkint $desk desk
if ! which prog >/dev/null 2>&1; then
  echo "cannot start $prog, not found in path" >&2
  exit 1
fi
# start program
$prog &
# wait for it to appear
xwinid=
iter=0
while [ ${#xwinid} -eq 0 ]; do
  sleep 1
  xwinid=$(winid $title)
  iter=$(( iter + 1 ))
  if [ $iter -gt $xtimeout ]; then
    break
  fi
done
if [ ${#xwinid} -eq 0 ]; then
  echo "Timed out waiting for $prog to start" >&2
  exit 1
fi
movewin $title $desk
