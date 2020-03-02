#!/usr/local/bin/python2.7

import sys
import requests
import json


def disconnect(ip_address, session_id):
    payload = {
        "sessionId": session_id,
    }
    url = "http://{0}/api/captiveportal/radius/disconnect/".format(ip_address)
    r = requests.post(
        url, 
        data=json.dumps(payload), 
        headers={"Content-Type": "application/json"}
        )
    print r.json().get("terminateCause")

def main(argv):
    if len(argv) > 2:
        ip_address = argv[1]
        session_id = argv[2]
        disconnect(ip_address, session_id)

if __name__ == "__main__":
    main(sys.argv)