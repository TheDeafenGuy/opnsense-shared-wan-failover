# opnsense-shared-wan-failover
Script for WAN to be used by a secondary (BACKUP) OPNsense firewall in a HA setup when a single WAN connection is shared between two firewalls.

<h2>This has been tested as working on OPNsense 26.1.6</h2>


<p>This script will be placed in the /usr/local/etc/rc.syshook.d/carp/ folder as when a change happens to CARP state all the scripts in this folder get triggered. For example, /usr/local/etc/rc.syshook.d/carp/50-wan-monitor </p>

<p>If the state is MASTER, then the script will run configctl interface linkup stop [WAN interface name]</p>
<p>If the state is BACKUP, then the script will run configctl interface linkup start [WAN interface name]</p>
<p>Once done, the script will terminate and will not run again until another CARP event in which depending on the CARP state the script will perform enable/disable WAN</p>
<p>As for logging, the script uses the built in logger and will log to /var/log/system/ </p>
<p>This also means that you can search for these logs in the web dashboard under General. Events are logged at the NOTICE level.</p>

