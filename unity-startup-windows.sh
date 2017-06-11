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
ME=${0##*/}

XRANDR=$(which xrandr)
: "${XRANDR:?$ME could not find xrandr in path}"
WMCTRL=$(which wmctrl)
: "${WMCTRL:?$ME could not find wmctrl in path}"

read hsz vsz < <($XRANDR | sed -n 's/^Screen 0.*, current \([0-9]\+\) x \([0-9]\+\), .*$/\1 \2/p')
read mhsz mvsz < <($WMCTRL -d | sed -n 's/^.*DG: \([0-9]\+\)x\([0-9]\+\) .*$/\1 \2/p')

checkint $hsz hsz
checkint $vsz vsz
checkint $mhsz mhsz
checkint $mvsz mvsz
# the checkint function ensures that the integer arithmetic below works without error
whsz=$(( mhsz / hsz ))
wvsz=$(( mvsz / vsz ))

echo "h: $whsz, v: $wvsz"
