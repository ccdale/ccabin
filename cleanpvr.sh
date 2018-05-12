#!/bin/bash

# set -ex
set -e

# gipd=${HOME}/tmp/.get_iplayer
gipd=${HOME}/.get_iplayer
pvrd=${gipd}/pvr
bakd=${gipd}/backup
defaultd=${gipd}/defaults
tmpd=${gipd}/tmp
keep=7 # keep upto 7 backups of each file

function cleanUp()
{
    rm -rf ${tmpd}
}
function mkpathIfNotExist()
{
    local xpath=$1
    if [[ ${#xpath} -gt 0 ]]
    then
        if [ ! -e "${xpath}" ]
        then
            mkdir -p "${xpath}"
        fi
    fi
}
function moveUpOne()
{
    local fn=$1
    # sensible default just in case
    keep=${keep:=7}

    # is parameter set
    if [[ ${#fn} -gt 0 ]]
    then
        local iter=$keep
        while [[ $iter -gt 0 ]]
        do
            local tfn=${bakd}/${fn}.${iter}
            if [[ -e ${tfn} ]]
            then
                if [[ $iter -eq $keep ]]
                then
                    rm $tfn
                else
                    local titer=$(( iter + 1 ))
                    local utfn=${bakd}/${fn}.$titer
                    mv $tfn $utfn
                fi
            fi
            iter=$(( iter - 1 ))
        done
    fi
}
function rotateIfNecessary()
{
    local fn=`basename $1`
    # is parameter set
    if [[ ${#fn} -gt 0 ]]
    then
        # does .1 backup file exist
        local bak1=${bakd}/${fn}.1
        if [[ -e $bak1 ]]
        then
            # are there differences
            if diff -q $bak1 ${pvrd}/$fn >/dev/null 2>&1
            then
                # there are so rotate the backups
                moveUpOne $fn
                cp ${pvrd}/$fn $bak1
            fi
        else
            # backup doesn't yet exist so create it
            cp ${pvrd}/$fn $bak1
        fi
    fi
}
function getAllTypeSearchesFromFile()
{
    local localifs="$IFS"
    local fn=$1
    local xtype=
    if [[ ${#fn} -gt 0 ]]
    then
        if [ -e $fn ]
        then
            if grep -q "type " $fn 2>/dev/null
            then
                xtype=`grep "type " $fn|cut -d" " -f2`
                IFS='
'
                for sn in `grep search $fn|cut -d" " -f2-|sed 's/\(.*\): Series.*/\1/'|tr -d [$^]`
                do
                    echo "${sn}" >>${tmpd}/${xtype}-searches
                done
            fi
        fi
    fi
    IFS="$localifs"
}
function getSingleSearchStringFromFile()
{
    # grep search _Live_at_the_Apollo_Series_9_name_tv |cut -d" " -f2-|sed 's/\(.*\): Series.*/\1/'|tr -d [$^]
    local fn=$1
    local op=
    # is parameter set
    if [[ ${#fn} -gt 0 ]]
    then
        if [[ -e $fn ]]
        then
            # find the first search string
            # the head -n 1 stops any other search strings from being returned
            # cos that then puts them all on one line which would break stuff
            # cut off the first word (search0 ^programme name: Series 34$ - becomes - ^programme name: Series 34$)
            # remove any reference to Series number (if necessary)
            # remove any regex start and end pointers (if necessary)
            op=`grep search $fn|head -n 1|cut -d" " -f2-|sed 's/\(.*\): Series.*/\1/'|tr -d [$^]`
            # op should now just be "programme name"
        fi
    fi
    echo $op
}
function findTypeSearches()
{
    local xtype=$1
    local fns=()
    if [[ ${#xtype} -gt 0 ]]; then
        if grep -q "type ${xtype}" ${pvrd}/_* 2>/dev/null; then
            for fn in `grep -l "type ${xtype}" ${pvrd}/_*`; do
                search=`getSingleSearchStringFromFile ${fn}`
                if [[ ${#search} -gt 0 ]]; then
                    echo "${search}" >>${tmpd}/${xtype}-searches
                    echo "found search: ${search}"
                    fns=(${fns[@]} $fn)
                    # mv ${fn} ${tmpd}/
                fi
            done
        fi
    fi
    if [[ ${#fns[@]} -gt 0 ]]; then
        mv ${fns[@]} ${tmpd}/
    fi
}
function buildNewList()
{
    local xtype=$1
    local iter=0
    if [[ ${#xtype} -gt 0 ]]
    then
        if [ -e "${tmpd}/${xtype}-searches" ]; then
            sort -u "${tmpd}/${xtype}-searches" >"${tmpd}/${xtype}-sorted"
            if [ -e "${defaultd}/${xtype}" ]; then
                cp "${defaultd}/${xtype}" "${pvrd}/${xtype}"
                while read -r sch; do
                    echo "search${iter} ${sch}" >>"${pvrd}/${xtype}"
                    iter=$(( iter + 1 ))
                done <"${tmpd}/${xtype}-sorted"
                # cat "${defaultd}/${xtype}" "${tmpd}/${xtype}-sorted" >"${pvrd}/${xtype}"
            fi
        fi
    fi
}

mkpathIfNotExist $defaultd
mkpathIfNotExist $bakd
mkpathIfNotExist $tmpd # this directory gets deleted after each run if cleanup is called

keep=7
stypes=("tv" "radio")
numtypes=${#stypes[@]}
num=0
while [ $num -lt $numtypes ]
do
    # backup the current list if necessary
    rotateIfNecessary ${pvrd}/${stypes[$num]}
    # get the current list of searches
    getAllTypeSearchesFromFile ${pvrd}/${stypes[$num]}
    # add any new ones
    findTypeSearches ${stypes[$num]}
    # save the new list
    buildNewList ${stypes[$num]}
    # clean up tmp files
    rm ${tmpd}/${stypes[$num]}-*
    # and on to the next type
    num=$(( num + 1 ))
done
