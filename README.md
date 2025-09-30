# opnsense-shared-wan-failover
Scripts for WAN to be used by the secondary (BACKUP) OPNsense firewall in a HA setup when a single WAN connection is shared between two firewalls.

<h2>Note that these instructions were written for OPNsense community 25.7</h2>

<h1>How it works</h1>

<p>When started, the script will check the CARP Status via ifconfig [interface name that has CARP VIPS] | grep -p MASTER.</p>
<p>If the state is MASTER, then the script will run configctl interface linkup stop [WAN interface name]</p>
<p>If the state is BACKUP, then the script will run configctl interface linkup start [WAN interface name]</p>
<p>After this initial check, every 5 seconds the script will check the status again, and if it is the same as before, it will do nothing, but if it changes, it will run configctl interface linkup start/stop [WAN interface name] depending on what the state changes to</p>

<h1>Getting the script working</h1>

<p>The provided script will not work in its current state. In order to get it to work, you will have to replace the IF and CARP_IF values in the script. Placeholders are currently in the place of the values by default.</p>

<p>I reccomend also making this script run on boot. This can be done by putting a script in /usr/local/etc/rc.syshook.d/start/ that runs the wan-carp-monitor script (thats how I did it).</p>
