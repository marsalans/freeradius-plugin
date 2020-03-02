#!/usr/local/bin/python2.7

import requests
import json
import sys

def reconfigure_ipfw(nas_ipaddr):
    payload = {}
    url = "http://{0}/api/captiveportal/bandwidth/reconfigure/".format(nas_ipaddr)
    r = requests.post(
        url, 
        data=json.dumps(payload), 
        headers={"Content-Type": "application/json"}
        )
    print r.status_code, r.reason, r.text    


def flushreload_ipfw(nas_ipaddr):
    payload = {}
    url = "http://{0}/api/captiveportal/bandwidth/flushreload/".format(nas_ipaddr)
    r = requests.post(
        url, 
        data=json.dumps(payload), 
        headers={"Content-Type": "application/json"}
        )
    print r.status_code, r.reason, r.text        


# def main(argv):
#     command = argv[1]  
#     nas_ipaddr = argv[2] 

#     if command == "reconfigure":   
#         reconfigure_ipfw(nas_ipaddr)  
#     elif command == "flushreload":      
#         flushreload_ipfw(nas_ipaddr)      
            

# if __name__ == "__main__":
#     main(sys.argv)     

