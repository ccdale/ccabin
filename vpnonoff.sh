#!/bin/bash

vpnname="AirVPN_United-Kingdom_UDP-443"
conname="Wired connection 1"

function isActive()
{
    xcon="$1"
    active=$(nmcli c show --active)
    if echo $active|grep -q "$xcon" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
function Activate()
{
    xcon="$1"
    nmcli c up "$xcon"
}
function deActivate()
{
    xcon="$1"
    nmcli c down "$xcon"
}
function toggleVPN()
{
    if isActive "$vpnname"; then
        stopVPN
    else
        startVPN
    fi
}
function stopVPN()
{
    echo "Deactivating VPN"
    iter=0
    while isActive "$vpnname"; do
        sleep 1
        deActivate "$vpnname"
        : $(( ++iter ))
        if [[ $iter -gt 2 ]]; then
            echo "Failed to deactivate VPN after 3 attempts."
            break
        fi
    done
}
function startVPN()
{
    echo "Activating VPN"
    iter=0
    while ! isActive "$vpnname"; do
        sleep 1
        Activate "$vpnname"
        # try 3 times
        : $(( ++iter ))
        if [[ $iter -gt 2 ]]; then
            echo "failed to activate VPN after 3 attempts."
            break
        fi
    done
}

ME=$(basename $0)
case $ME in
    togglevpn) toggleVPN;;
    vpnstart) startVPN;;
    vpnstop) stopVPN;;
    *) toggleVPN;;
esac
