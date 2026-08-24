#!/bin/sh
# ==============================================================================
# Purpose: Automatically manages WAN link availability based on CARP state 
#          transitions to prevent IP and MAC address conflicts on shared WAN hardware.
#
# Execution Hook Location: /usr/local/etc/rc.syshook.d/carp/50-wan-monitor
#
# Step-by-Step Process:
# 1. Define physical WAN interface, CARP VLAN interface, and logging parameters.
# 2. Query system networking status via `get_carp_state` to determine role.
# 3. If node transitions to MASTER:
#    a. Log state event to syslog.
#    b. Execute OPNsense backend command `interface linkup start` to initialize link and request IP.
#    c. Restart Tailscale daemon to rebind routing to active interface.
# 4. If node transitions to BACKUP:
#    a. Log state event to syslog.
#    b. Execute OPNsense backend command `interface linkup stop` to tear down link and strip IP.
# ==============================================================================

# Target physical WAN network interface identifier
IF="(replace with your WAN inteface)"

# Target VLAN interface monitoring CARP status
CARP_IF="(replace with one of your carp interfaces ex. vtnet0_vlan3)"

# Syslog identifier tag for tracking events in system log
LOGTAG="wan-carp-hook"

# ------------------------------------------------------------------------------
# Function: get_carp_state
# Description: Evaluates system CARP status by checking ifconfig output.
# Returns: "MASTER" if active primary, "BACKUP" for all other states.
# ------------------------------------------------------------------------------
get_carp_state() {
    # Inspect CARP VLAN interface while suppressing standard error.
    # Check if the string 'carp: MASTER' is active on the interface.
    if ifconfig "$CARP_IF" 2>/dev/null | grep -q 'carp: MASTER'; then
        echo "MASTER"
    else
        echo "BACKUP"
    fi
}

# ------------------------------------------------------------------------------
# Main Logic Execution
# ------------------------------------------------------------------------------

# Call function and store return value into STATE variable
STATE=$(get_carp_state)

# Evaluate state to execute appropriate interface action
if [ "$STATE" = "MASTER" ]; then
    # Write informational message to system log
    logger -p daemon.notice -t "$LOGTAG" "CARP event: Node is MASTER. Starting link for $IF."

    # Trigger OPNsense linkup start to bring up interface and request DHCP/IP
    /usr/local/sbin/configctl interface linkup start "$IF"

    # Restart Tailscale to rebind tunnel endpoints to active WAN IP
    /usr/local/sbin/configctl service restart tailscale

else
    # Write informational message to system log
    logger -p daemon.notice -t "$LOGTAG" "CARP event: Node is BACKUP. Stopping link for $IF."

    # Trigger OPNsense linkup stop to unassign IP, kill DHCP client, and drop link
    /usr/local/sbin/configctl interface linkup stop "$IF"
fi
