function date2stamp () 
{
    date --utc --date "$1" +%s
}

function stamp2date ()
{
    date --utc --date "1970-01-01 $1 sec" "+%Y-%m-%d %T"
}

function dateDiff ()
{
    case $1 in
        -s)   sec=1;      shift;;
        -m)   sec=60;     shift;;
        -h)   sec=3600;   shift;;
        -d)   sec=86400;  shift;;
        *)    sec=86400;;
    esac
    dte1=$(date2stamp $1)
    dte2=$(date2stamp $2)
    diffSec=$((dte2-dte1))
    if ((diffSec < 0)); then abs=-1; else abs=1; fi
    echo $((diffSec/sec*abs))
}
function secTohms ()
{
    num=$1
    # if the 2nd arg is set show days as well
    if [ "X$2" = "X" ]
    then
        showday=0
    else
        showday=1
    fi
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((showday>0));then
                if((num>23));then
                    ((hour=num%24))
                    ((day=num/24))
                else
                    ((hour=num))
                fi
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    # echo "$day"d "$hour"h "$min"m "$sec"s
    if((showday>0));then
        # echo "$day:$hour:$min:$sec"
        printf "%02d:%02d:%02d:%02d" $day $hour $min $sec
    else
        printf "%02d:%02d:%02d" $hour $min $sec
        # echo "$hour:$min:$sec"
    fi
}
function hmsTosec ()
{
    hms=$1
    if [ "X$hms" != "X" ]
    then
        day=`echo $hms|cut -d: -f1`
        hour=`echo $hms|cut -d: -f2`
        min=`echo $hms|cut -d: -f3`
        sec=`echo $hms|cut -d: -f4`

        # echo "$day:$hour:$min:$sec"
        while [ "X$sec" = "X" ]
        do
            sec=$min;
            min=$hour;
            hour=$day;
            day=
        done
        # echo "$day:$hour:$min:$sec"
        if [ "X$min" = "X" ]
        then
            msec=0
        else
            ((msec=min*60))
        fi
        if [ "X$hour" = "X" ]
        then
            hsec=0
        else
            ((hsec=hour*60*60))
        fi
        if [ "X$day" = "X" ]
        then
            dsec=0
        else
            ((dsec=day*24*60*60))
        fi
        ((tsec=sec+msec+hsec+dsec))
        echo $tsec
    fi
}
function videodurationsec ()
{
    t=`videodurationhms $1`
    if [ "$t" = "-1" ]
    then
        echo $t
    else
        hmsTosec $t
    fi
}
function videodurationhms ()
{
    fn=$1
    if [ "X$fn" = "X" ]
    then
        echo -1
    else
        ffprobe $fn 2>&1|grep Duration|sed -e 's/^[ \t]*//'|cut -d" " -f2|cut -d. -f1
    fi
}
function mplayerpos ()
{
    fn=$1
    if [ "X$fn" = "X" ]
    then
        echo 0
    else
        if [ -e $fn ]
        then
            grep -o "A: \+[0-9]\+" $fn|grep -o "[0-9]\+" |tail -n 1
        else
            echo 0
        fi
    fi
}
