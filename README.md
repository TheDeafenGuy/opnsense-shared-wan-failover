# opnsense-shared-wan-failover
Script for WAN to be used by a secondary (BACKUP) OPNsense firewall in a HA setup when a single WAN connection is shared between two firewalls.

<h2>This has been tested as working on OPNsense 26.1.6</h2>


<p>This script will be placed in the /usr/local/etc/rc.syshook.d/carp/ folder as when a change happens to CARP state all the scripts in this folder get triggered. For example, /usr/local/etc/rc.syshook.d/carp/50-wan-monitor is where I have my script </p>

<p>If the state is MASTER, then the script will run configctl interface linkup stop [WAN interface name]</p>
<p>If the state is BACKUP, then the script will run configctl interface linkup start [WAN interface name]</p>
<p>Once done, the script will terminate and will not run again until another CARP event in which depending on the CARP state the script will perform enable/disable WAN</p>
<p>As for logging, the script uses the built in logger and will log to /var/log/system/ </p>
<p>This also means that you can search for these logs in the web dashboard under General. Events are logged at the NOTICE level.</p>
<p>By default this script will also restart tailscale when the CARP state is MASTER. If you either don't have tailscale installed or do not want this behavior then you can comment out or remove that line in the script.</p>
<p>Another default behavior of this script is that you will need to configure it based on your setup. Specifically, you need to tell the script what your WAN interface name is and the interface name of one of your CARP VIPS. These are at the beginning of the file. I have put placeholders in where they should be. For WAN, you want to replace the placeholder with your own interface name at "IF=" near the beginning of the file and for the CARP VIP interface replace the placeholder at "CARP_IF=". </p>

<p>Another issue is that since this script runs only when there is a carp event it won't run on boot. So, if you reboot the firewall it will already have a WAN ip since the script has not run because there was no CARP change event. I have provided a script that will be put in the /usr/local/etc/rc.syshook.d/start/ directory. For example, I have my script set up as /usr/local/etc/rc.syshook.d/start/50-wan-monitor
 </p>
 <p>As with the other script, you will have to update the placeholders with your interface names, and you have the option to remove the part of the script that restarts tailscale.</p>
