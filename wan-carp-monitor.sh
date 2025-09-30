#!/bin/sh
# WAN CARP monitor for backup firewall
# Only runs linkup start/stop when CARP state changes

IF="[replace with your WAN interface]"
CARP_IF="[replace with interface that has CARP VIPS]"   # interface carrying VIP
LOGTAG="carp-wan-monitor"
PREV_STATE=""

while true; do
    # Get current CARP state
    if ifconfig $CARP_IF | grep -q 'MASTER'; then
        CUR_STATE="MASTER"
    else
        CUR_STATE="BACKUP"
    fi

    # Only act if state has changed
    if [ "$CUR_STATE" != "$PREV_STATE" ]; then
        if [ "$CUR_STATE" = "MASTER" ]; then
            logger -t $LOGTAG "CARP MASTER: enabling $IF"
            /usr/local/sbin/configctl interface linkup start $IF
        else
            logger -t $LOGTAG "CARP BACKUP: disabling $IF"
            /usr/local/sbin/configctl interface linkup stop $IF
        fi
        PREV_STATE="$CUR_STATE"
    fi

    sleep 5
done
