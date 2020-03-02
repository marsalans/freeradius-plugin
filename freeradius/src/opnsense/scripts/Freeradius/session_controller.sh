#!/bin/sh

# curl -v --insecure \
#     -H "Content-Type: application/json" \
#     -d '{"sessionId":"g+x09CDSz7W69zOQWgRu+g=="}' \
#     https://192.168.50.1/api/captiveportal/session/disconnect/0

# curl -v --insecure \
#     --request POST \
#     --data 'usernamefld=root&passwordfld=opnsense' \
#     --header "Content-Type: application/x-www-form-urlencoded" \
#     https://192.168.50.1/index.php

# curl --compressed --insecure \
#     -H 'Accept-Encoding: gzip, deflate, sdch, br' \
#     -H 'Accept-Language: en-US,en;q=0.8' \
#     -H 'Upgrade-Insecure-Requests: 1' \
#     -H 'User-Agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36' \
#     -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
#     -H 'Cache-Control: max-age=0' \
#     -H 'Cookie: cookie_test=1546501236; PHPSESSID=8a104fc900cf64bb592401ea9574a584' \
#     -H 'Connection: keep-alive' \
#     'https://192.168.50.1/api/captiveportal/session/list' 


listAction() {
    curl "http://$ip_address/api/captiveportal/radius/list"
}

disconnectAction() {
# cat >/tmp/data.json <<EOF
#     {
#       "sessionId": "$session_id"
#     }
# EOF	 
    
	#curl -H 'Content-Type: application/json'  -d '{"sessionId":"'"$session_id"'"}' "http://$ip_address/api/captiveportal/radius/disconnect/"
	#curl -H 'Content-Type: application/json' -d '@/tmp/data.json' "http://$ip_address/api/captiveportal/radius/disconnect/"
	curl -H 'Content-Type: application/json' -d '{"sessionId":"'"$session_id"'"}' "http://$ip_address/api/captiveportal/radius/disconnect/" | python2.7 -c 'import json,sys;ret=json.load(sys.stdin);print ret.get("terminateCause");'
}

case ${1} in
	list)
		ip_address=$2
		listAction
		;;
		
	disconnect)
		ip_address=$2
		session_id=$3
		#session_id=$(echo "$3" | sed 's/\\//g')
		disconnectAction
		;;
esac
