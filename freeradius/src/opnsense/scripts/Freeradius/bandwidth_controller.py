#!/usr/local/bin/python2.7

import requests
import json
import sys
import ipfw_controller

def create_traffic_pipe(traffictype, nas_ipaddr, bandwidth, bandwidthMetric):
    payload = {
        "traffictype": traffictype,
        "bandwidth": bandwidth,
        "bandwidthMetric": bandwidthMetric
    }
    url = "http://{0}/api/captiveportal/bandwidth/addPipe/".format(nas_ipaddr)
    r = requests.post(
        url, 
        data=json.dumps(payload), 
        headers={"Content-Type": "application/json"}
        )
    print r.status_code, r.reason, r.text    


def delete_traffic_pipe(traffictype, nas_ipaddr, bandwidth, bandwidthMetric):
    payload = {
        "traffictype": traffictype,
        "bandwidth": bandwidth,
        "bandwidthMetric": bandwidthMetric
    }
    url = "http://{0}/api/captiveportal/bandwidth/delPipe/".format(nas_ipaddr)
    r = requests.post(
        url, 
        data=json.dumps(payload), 
        headers={"Content-Type": "application/json"}
        )
    print r.status_code, r.reason, r.text   


def create_traffic_rule(traffictype, nas_ipaddr, sessionId, username, bandwidth, bandwidthMetric):
    payload = {
        "traffictype": traffictype,
        "sessionId": sessionId,
        "username": username,
        "bandwidth": bandwidth,
        "bandwidthMetric": bandwidthMetric
    }
    url = "http://{0}/api/captiveportal/bandwidth/addRule/".format(nas_ipaddr)
    r = requests.post(
        url, 
        data=json.dumps(payload), 
        headers={"Content-Type": "application/json"}
    )
    print r.status_code, r.reason, r.text  

def delete_traffic_rule(traffictype, nas_ipaddr, sessionId, username, useripaddr, bandwidth, bandwidthMetric):
    payload = {
        "traffictype": traffictype,
        "sessionId": sessionId,
        "username": username,
        "useripaddr": useripaddr,
        "bandwidth": bandwidth,
        "bandwidthMetric": bandwidthMetric
    }
    url = "http://{0}/api/captiveportal/bandwidth/delRule/".format(nas_ipaddr)
    r = requests.post(
        url, 
        data=json.dumps(payload), 
        headers={"Content-Type": "application/json"}
        )
    print r.status_code, r.reason, r.text    

# def set_traffic_rule(traffictype, nas_ipaddr, sessionId, username, useripaddr, bandwidth, bandwidthMetric):
#     payload = {
#         "enabled":"1",
#         "sequence":"1",
#         "interface":"opt1",
#         "interface2":"",
#         "proto":"ip",
#         "source":"192.168.80.100,192.168.150.100,192.168.150.120",
#         "source_not":"0",
#         "src_port":"any",
#         "destination":"any",
#         "destination_not":"0",
#         "dst_port":"any",
#         "direction":"",
#         "target":"8f44f44f-6ba0-495b-afbc-8e4d068ff440",
#         "description":"cp-256Kbit-uplink"
#     }
#     url = "http://{0}/api/captiveportal/bandwidth/delRule/".format(nas_ipaddr)
#     r = requests.post(
#         url, 
#         data=json.dumps(payload), 
#         headers={"Content-Type": "application/json"}
#         )
#     print r.status_code, r.reason, r.text                


def main(argv):
    command         = argv[1]
    traffictype     = argv[2]  
    nas_ipaddr      = argv[3]
    sessionId       = argv[4]
    username        = argv[5]         

    if traffictype == "uplink" or traffictype == "downlink":
        if command == "create":   
            bandwidth       = argv[6]
            bandwidthMetric = argv[7]                                    
            create_traffic_pipe(traffictype, nas_ipaddr, bandwidth, bandwidthMetric)
            create_traffic_rule(traffictype, nas_ipaddr, sessionId, username, bandwidth, bandwidthMetric)
        elif command == "delete":   
            useripaddr      = argv[6]
            bandwidth       = argv[7]
            bandwidthMetric = argv[8]                                         
            delete_traffic_rule(traffictype, nas_ipaddr, sessionId, username, useripaddr, bandwidth, bandwidthMetric)  
            delete_traffic_pipe(traffictype, nas_ipaddr, bandwidth, bandwidthMetric) 
        ipfw_controller.reconfigure_ipfw(nas_ipaddr)
        ipfw_controller.flushreload_ipfw(nas_ipaddr)  
                

if __name__ == "__main__":
    main(sys.argv)     

