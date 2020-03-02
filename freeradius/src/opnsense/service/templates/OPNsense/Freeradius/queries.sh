#!/bin/sh

{% if helpers.exists('OPNsense.freeradius.general.enabled') and OPNsense.freeradius.general.enabled == '1' %}

sqlite3 /usr/local/etc/raddb/freeradius.db <<QUERIES
    DELETE FROM radcheck;
    DELETE FROM radreply;
    DELETE FROM radusergroup;
    DELETE FROM radgroupcheck;
    DELETE FROM radgroupreply;

    DELETE FROM sqlite_sequence WHERE name='radcheck';
    DELETE FROM sqlite_sequence WHERE name='radreply';
    DELETE FROM sqlite_sequence WHERE name='radusergroup';
    DELETE FROM sqlite_sequence WHERE name='radgroupcheck';
    DELETE FROM sqlite_sequence WHERE name='radgroupreply';
QUERIES

sqlite3 /usr/local/etc/raddb/freeradius.db <<QUERIES
{%   if helpers.exists('OPNsense.freeradius.user.users.user') %}
{%     for user_list in helpers.toList('OPNsense.freeradius.user.users.user') %}
{%       if user_list.enabled == '1' %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Cleartext-Password', ':=', '{{ user_list.password }}');
{%       if user_list.groupname is defined %}
    INSERT OR REPLACE INTO radusergroup (username, groupname, priority) VALUES ('{{ user_list.username }}', '{{ helpers.getUUID(user_list.groupname)['groupname'] }}', '1'); 
{%       endif %} 
{%       if user_list.authtype is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Auth-Type', ':=', '{{ user_list.authtype }}');
{%       endif %}    
{%       if user_list.simultaneous is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Simultaneous-Use', ':=', '{{ user_list.simultaneous }}');
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.bandwidthlimit') and OPNsense.freeradius.general.bandwidthlimit == '1' %}
{%         if user_list.bandwidthlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Upload-Bandwidth', ':=', '{{ helpers.getUUID(user_list.bandwidthlimit)['uploadbandwidth'] }}');
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Upload-BandwidthMetric', ':=', '{{ helpers.getUUID(user_list.bandwidthlimit)['uploadmetric'] }}');
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Download-Bandwidth', ':=', '{{ helpers.getUUID(user_list.bandwidthlimit)['downloadbandwidth'] }}');
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Download-BandwidthMetric', ':=', '{{ helpers.getUUID(user_list.bandwidthlimit)['downloadmetric'] }}');
{%         endif %}
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.sessionlimit') and OPNsense.freeradius.general.sessionlimit == '1' %}
{%         if user_list.hourlysessionlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Hourly-Session', ':=', '{{ user_list.hourlysessionlimit }}');
{%         endif %}
{%         if user_list.dailysessionlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Daily-Session', ':=', '{{ user_list.dailysessionlimit }}');
{%         endif %}
{%         if user_list.weeklysessionlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Weekly-Session', ':=', '{{ user_list.weeklysessionlimit }}');
{%         endif %}
{%         if user_list.monthlysessionlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Monthly-Session', ':=', '{{ user_list.monthlysessionlimit }}');
{%         endif %}
{%         if helpers.exists('OPNsense.freeradius.general.logintime') and OPNsense.freeradius.general.logintime == '1' %} 
{%           if user_list.accountsessionlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Account-Session', ':=', '{{ user_list.accountsessionlimit }}');
{%           endif %}
{%         endif %}
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.trafficlimit') and OPNsense.freeradius.general.trafficlimit == '1' %}
{%         if user_list.hourlytrafficlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Hourly-Traffic', ':=', '{{ user_list.hourlytrafficlimit }}');
{%         endif %}
{%         if user_list.dailytrafficlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Daily-Traffic', ':=', '{{ user_list.dailytrafficlimit }}');
{%         endif %}
{%         if user_list.weeklytrafficlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Weekly-Traffic', ':=', '{{ user_list.weeklytrafficlimit }}');
{%         endif %}
{%         if user_list.monthlytrafficlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Monthly-Traffic', ':=', '{{ user_list.monthlytrafficlimit }}');
{%         endif %}
{%         if helpers.exists('OPNsense.freeradius.general.logintime') and OPNsense.freeradius.general.logintime == '1' %} 
{%           if user_list.accounttrafficlimit is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Max-Account-Traffic', ':=', '{{ user_list.accounttrafficlimit }}');
{%           endif %}
{%         endif %}
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.logintime') and OPNsense.freeradius.general.logintime == '1' %}
{%         if user_list.logintime_start_date is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Account-Start-Date', ':=', '{{ user_list.logintime_start_date }}');
{%         endif %}
{%         if user_list.logintime_end_date is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Account-End-Date', ':=', '{{ user_list.logintime_end_date }}');
{%         endif %}
{%         if user_list.logintime_value is defined %}
    INSERT OR REPLACE INTO radcheck (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Login-Time', ':=', '{{ user_list.logintime_value }}');
{%         endif %}
{%       endif %}

{%       if user_list.idletimeout is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Idle-Timeout', '=', '{{ user_list.idletimeout }}');       
{%       endif %}
{%       if user_list.replymessage is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Reply-Message', '=', '{{ user_list.replymessage }}');          
{%       endif %}
{%       if user_list.ip is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Framed-IP-Address', '=', '{{ user_list.ip }}');   
{%       endif %}
{%       if user_list.subnet is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Framed-IP-Netmask', '=', '{{ user_list.subnet }}');       
{%       endif %}
{%       if user_list.route is defined %}
{%         for network in user_list.route.split(',') %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Framed-Route', '+=', '{{ network }}'); 
{%         endfor %}
{%       endif %}
{%       if user_list.ip6 is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Framed-IPv6-Address', '=', '{{ user_list.ip6 }}');       
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.vlanassign') and OPNsense.freeradius.general.vlanassign == '1' %}
{%         if user_list.vlan is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Tunnel-Type', '=', 'VLAN');
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Tunnel-Medium-Type', '=', 'IEEE-802');   
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Tunnel-Private-Group-Id', '=', '{{ user_list.vlan }}');                     
{%         endif %}
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.mikrotik') and OPNsense.freeradius.general.mikrotik == '1' %}
{%         if user_list.mikrotik_vlan_id_number is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Mikrotik-Wireless-VLANID', '=', '{{ user_list.mikrotik_vlan_id_number }}');       
{%         endif %}
{%         if user_list.mikrotik_vlan_id_type is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Mikrotik-Wireless-VLANID-Type', '=', '{{ user_list.mikrotik_vlan_id_type }}');        
{%         endif %}
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.wispr') and OPNsense.freeradius.general.wispr == '1' %}
{%         if user_list.wispr_bw_min_up is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'WISPr-Bandwidth-Min-Up', '=', '{{ user_list.wispr_bw_min_up }}');        
{%         endif %}
{%         if user_list.wispr_bw_max_up is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'WISPr-Bandwidth-Max-Up', '=', '{{ user_list.wispr_bw_max_up }}');        
{%         endif %}
{%         if user_list.wispr_bw_min_down is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'WISPr-Bandwidth-Min-Down', '=', '{{ user_list.wispr_bw_min_down }}');       
{%         endif %}
{%         if user_list.wispr_bw_max_down is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'WISPr-Bandwidth-Max-Down', '=', '{{ user_list.wispr_bw_max_down }}');        
{%         endif %}
{%       endif %}
{%       if helpers.exists('OPNsense.freeradius.general.chillispot') and OPNsense.freeradius.general.chillispot == '1' %}
{%         if user_list.chillispot_bw_max_up is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'ChilliSpot-Bandwidth-Max-Up', '=', '{{ user_list.chillispot_bw_max_up }}');         
{%         endif %}
{%         if user_list.chillispot_bw_max_down is defined %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'ChilliSpot-Bandwidth-Max-Down', '=', '{{ user_list.chillispot_bw_max_down }}');       
{%         endif %}
{%       endif %}
    INSERT OR REPLACE INTO radreply (username, attribute, op, value) VALUES ('{{ user_list.username }}', 'Framed-Protocol', '=', 'PPP');          
{%       endif %}
{%     endfor %}
{%   endif %}
QUERIES

sqlite3 /usr/local/etc/raddb/freeradius.db <<QUERIES
{%   if helpers.exists('OPNsense.freeradius.usergroup.usergroups.usergroup') %}
{%     for group_list in helpers.toList('OPNsense.freeradius.usergroup.usergroups.usergroup') %}
{%       if group_list.enabled == '1' %} 
{%         if group_list.authtype is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Auth-Type', '=', '{{ group_list.authtype }}');                          
{%         endif %}
{%         if group_list.simultaneous is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Simultaneous-Use', '=', '{{ group_list.simultaneous }}');
{%         endif %}
{%         if helpers.exists('OPNsense.freeradius.general.bandwidthlimit') and OPNsense.freeradius.general.bandwidthlimit == '1' %}
{%           if group_list.bandwidthlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Upload-Bandwidth', '=', '{{ helpers.getUUID(group_list.bandwidthlimit)['uploadbandwidth'] }}');
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Upload-BandwidthMetric', '=', '{{ helpers.getUUID(group_list.bandwidthlimit)['uploadmetric'] }}');
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Download-Bandwidth', '=', '{{ helpers.getUUID(group_list.bandwidthlimit)['downloadbandwidth'] }}');
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Download-BandwidthMetric', '=', '{{ helpers.getUUID(group_list.bandwidthlimit)['downloadmetric'] }}');
{%           endif %}
{%         endif %}
{%         if helpers.exists('OPNsense.freeradius.general.sessionlimit') and OPNsense.freeradius.general.sessionlimit == '1' %}
{%           if group_list.hourlysessionlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Hourly-Session', '=', '{{ group_list.hourlysessionlimit }}');                         
{%           endif %}
{%           if group_list.dailysessionlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Daily-Session', '=', '{{ group_list.dailysessionlimit }}');                         
{%           endif %}
{%           if group_list.weeklysessionlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Weekly-Session', '=', '{{ group_list.weeklysessionlimit }}');                         
{%           endif %}
{%           if group_list.monthlysessionlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Monthly-Session', '=', '{{ group_list.monthlysessionlimit }}');                          
{%           endif %}
{%           if group_list.accountsessionlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Account-Session', '=', '{{ group_list.accountsessionlimit }}');                         
{%           endif %}
{%         endif %}
{%         if helpers.exists('OPNsense.freeradius.general.trafficlimit') and OPNsense.freeradius.general.trafficlimit == '1' %}
{%           if group_list.hourlytrafficlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Hourly-Traffic', '=', '{{ group_list.hourlytrafficlimit }}');                         
{%           endif %}
{%           if group_list.dailytrafficlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Daily-Traffic', '=', '{{ group_list.dailytrafficlimit }}');                            
{%           endif %}
{%           if group_list.weeklytrafficlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Weekly-Traffic', '=', '{{ group_list.weeklytrafficlimit }}');                        
{%           endif %}
{%           if group_list.monthlytrafficlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Monthly-Traffic', '=', '{{ group_list.monthlytrafficlimit }}');                         
{%           endif %}
{%           if group_list.accounttrafficlimit is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Max-Account-Traffic', '=', '{{ group_list.accounttrafficlimit }}');                              
{%           endif %}
{%         endif %}
{%         if helpers.exists('OPNsense.freeradius.general.logintime') and OPNsense.freeradius.general.logintime == '1' %}
{%           if group_list.logintime_start_date is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Account-Start-Date', '=', '{{ group_list.logintime_start_date }}');                          
{%           endif %}
{%           if group_list.logintime_end_date is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Account-End-Date', '=', '{{ group_list.logintime_end_date }}');                           
{%           endif %}
{%           if group_list.logintime_value is defined %}
    INSERT OR REPLACE INTO radgroupcheck (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Login-Time', '=', '{{ group_list.logintime_value }}');                           
{%           endif %}
{%         endif %}
  
{%         if group_list.idletimeout is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Idle-Timeout', '=', '{{ group_list.idletimeout }}');                 
{%         endif %}                                          
{%         if group_list.replymessage is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'Reply-Message', '=', '{{ group_list.replymessage }}');                 
{%         endif %}    
{%         if helpers.exists('OPNsense.freeradius.general.wispr') and OPNsense.freeradius.general.wispr == '1' %}
{%           if group_list.wispr_bw_min_up is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'WISPr-Bandwidth-Min-Up', '=', '{{ group_list.wispr_bw_min_up }}');                         
{%           endif %}
{%           if group_list.wispr_bw_max_up is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'WISPr-Bandwidth-Max-Up', '=', '{{ group_list.wispr_bw_max_up }}');                        
{%           endif %}
{%           if group_list.wispr_bw_min_down is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'WISPr-Bandwidth-Min-Down', '=', '{{ group_list.wispr_bw_min_down }}');                         
{%           endif %}
{%           if group_list.wispr_bw_max_down is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'WISPr-Bandwidth-Max-Down', '=', '{{ group_list.wispr_bw_max_down }}');                        
{%           endif %}
{%         endif %}
{%         if helpers.exists('OPNsense.freeradius.general.chillispot') and OPNsense.freeradius.general.chillispot == '1' %}
{%           if group_list.chillispot_bw_max_up is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'ChilliSpot-Bandwidth-Max-Up', '=', '{{ group_list.chillispot_bw_max_up }}');                         
{%           endif %}
{%           if group_list.chillispot_bw_max_down is defined %}
    INSERT OR REPLACE INTO radgroupreply (groupname, attribute, op, value) VALUES ('{{ group_list.groupname }}', 'ChilliSpot-Bandwidth-Max-Down', '=', '{{ group_list.chillispot_bw_max_down }}');                         
{%           endif %}
{%         endif %}  
{%       endif %}
{%     endfor %}
{%   endif %}
QUERIES

{% endif %}   