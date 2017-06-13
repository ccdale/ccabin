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
