#!/bin/sh


reindex_radacct() {
    original_table=$(sqlite3 /usr/local/etc/raddb/freeradius.db "SELECT sql FROM sqlite_master WHERE type='table' and tbl_name='radacct'")
    # original_index=$(sqlite3 /usr/local/etc/raddb/freeradius.db "SELECT sql FROM sqlite_master WHERE type='index' and tbl_name='radacct'")

    new_table=$(echo $original_table | sed -e "s/radacct/radacctnew/")

    sqlite3 /usr/local/etc/raddb/freeradius.db "DROP TABLE IF EXISTS radacctnew;"
    sqlite3 /usr/local/etc/raddb/freeradius.db "$new_table"
    sqlite3 /usr/local/etc/raddb/freeradius.db <<QUERIES
        INSERT INTO radacctnew
            (acctsessionid, acctuniqueid, username, realm, nasipaddress, nasportid, nasporttype, acctstarttime, acctupdatetime, acctstoptime, acctinterval, 
            acctsessiontime, acctauthentic, connectinfo_start, connectinfo_stop, acctinputoctets, acctoutputoctets, calledstationid, callingstationid, 
            acctterminatecause, servicetype, framedprotocol, framedipaddress) 
        SELECT 
            acctsessionid, acctuniqueid, username, realm, nasipaddress, nasportid, nasporttype, acctstarttime, acctupdatetime, acctstoptime, acctinterval, 
            acctsessiontime, acctauthentic, connectinfo_start, connectinfo_stop, acctinputoctets, acctoutputoctets, calledstationid, callingstationid, 
            acctterminatecause, servicetype, framedprotocol, framedipaddress
        FROM radacct;

        DROP TABLE IF EXISTS radacct;

        DROP INDEX IF EXISTS acctuniqueid;
        DROP INDEX IF EXISTS username;
        DROP INDEX IF EXISTS framedipaddress;
        DROP INDEX IF EXISTS acctsessiontime;
        DROP INDEX IF EXISTS acctstarttime;
        DROP INDEX IF EXISTS acctinterval;
        DROP INDEX IF EXISTS acctstoptime;
        DROP INDEX IF EXISTS nasipaddress;

        ALTER TABLE radacctnew RENAME TO radacct;

        CREATE UNIQUE INDEX acctuniqueid ON radacct(acctuniqueid);
        CREATE INDEX username ON radacct(username);
        CREATE INDEX framedipaddress ON radacct (framedipaddress);
        CREATE INDEX acctsessionid ON radacct(acctsessionid);
        CREATE INDEX acctsessiontime ON radacct(acctsessiontime);
        CREATE INDEX acctstarttime ON radacct(acctstarttime);
        CREATE INDEX acctinterval ON radacct(acctinterval);
        CREATE INDEX acctstoptime ON radacct(acctstoptime);
        CREATE INDEX nasipaddress ON radacct(nasipaddress);
        
QUERIES

    # sqlite3 /usr/local/etc/raddb/freeradius.db "$original_index" | while read index; do
    #     new_index=$(echo $index | sed -e "s/radacct/radacctnew/")
    #     sqlite3 /usr/local/etc/raddb/freeradius.db "$new_index"
    #     echo "$new_index"
    # done

    # columns=$(sqlite3 /usr/local/etc/raddb/freeradius.db "PRAGMA table_info(radacct);")
    # IFS='|' read -ra column <<< "$columns"                                          
    # echo "${column[1]}" 

    # ring=""                                                                         
    # while read line;  do                                                            
    #         #echo ${line[0]}                                                        
    #         IFS='|' read -ra column <<< "${line[0]}"                                
    #         #echo ${column[1]}                                                      
    #         ring+="${column[1]}, "                                                  
    # done < <(sqlite3 /usr/local/etc/raddb/freeradius.db "PRAGMA table_info(radacct);")
    # echo ${ring[@]}; 
}


reindex_radpostauth() {
    original_table=$(sqlite3 /usr/local/etc/raddb/freeradius.db "SELECT sql FROM sqlite_master WHERE type='table' and tbl_name='radpostauth'")
    new_table=$(echo $original_table | sed -e "s/radpostauth/radpostauthnew/")

    sqlite3 /usr/local/etc/raddb/freeradius.db "DROP TABLE IF EXISTS radpostauthnew;"
    sqlite3 /usr/local/etc/raddb/freeradius.db "$new_table"
    sqlite3 /usr/local/etc/raddb/freeradius.db <<QUERIES
        INSERT INTO radpostauthnew (username, pass, reply, authdate) SELECT username, pass, reply, authdate FROM radpostauth;
        DROP TABLE IF EXISTS radpostauth;
        ALTER TABLE radpostauthnew RENAME TO radpostauth; 
QUERIES
}

# 
# sqlite3 /usr/local/etc/raddb/freeradius.db <<QUERIES
# {%   set users = [] %}
# {%   if helpers.exists('OPNsense.freeradius.user.users.user') %}
# {%     for user_list in helpers.toList('OPNsense.freeradius.user.users.user') %}
# {%         do users.append(user_list.username) %}
# {%     endfor %}
# {%   endif %}
# 
# {%   if users %}
#     DELETE FROM radacct WHERE username NOT IN (
#         SELECT username FROM radacct WHERE 
#             (
# {%     set count = users | length %}
# {%     for user in users %}
#             username='{{user}}' 
# {%-      if loop.index < count %}            
#             OR
# {%       endif %}
# {%     endfor %}
# 
#             )
#         ) 
# {%   endif %}        
# QUERIES
# 
# sqlite3 /usr/local/etc/raddb/freeradius.db <<QUERIES
# {%   set users = [] %}
# {%   if helpers.exists('OPNsense.freeradius.user.users.user') %}
# {%     for user_list in helpers.toList('OPNsense.freeradius.user.users.user') %}
# {%         do users.append(user_list.username) %}
# {%     endfor %}
# {%   endif %}
# 
# {%   if users %}
#     DELETE FROM radpostauth WHERE username NOT IN (
#         SELECT username FROM radpostauth WHERE
#             (
# {%     set count = users | length %}
# {%     for user in users %}
#             username='{{user}}' 
# {%-      if loop.index < count %}            
#             OR
# {%       endif %}
# {%     endfor %}
# 
#             )
#         ) 
# {%   endif %}        
# QUERIES


help() {
    echo ""
    echo "Plugin scripts:"
    echo ""
    echo "commands:"
    echo "	help:			print commands help"
    echo "	radacct:		reindex radacct table"
    echo "	radpostauth:	reindex radpostauth table"
    echo ""   
}


case ${1} in
	radacct)
		reindex_radacct
		;;

	radpostauth)
		reindex_radpostauth
		;;

	help)
        help
        ;;   

	*)
        help
        ;;
esac