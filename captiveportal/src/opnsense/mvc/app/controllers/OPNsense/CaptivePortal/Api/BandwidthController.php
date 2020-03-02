<?php
/**
 *    Copyright (C) 2015-2017 Deciso B.V.
 *
 *    All rights reserved.
 *
 *    Redistribution and use in source and binary forms, with or without
 *    modification, are permitted provided that the following conditions are met:
 *
 *    1. Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *
 *    2. Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 *    THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 *    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *    AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 *    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *    POSSIBILITY OF SUCH DAMAGE.
 *
 */

namespace OPNsense\CaptivePortal\Api;

use \OPNsense\Base\ApiMutableModelControllerBase;
use \OPNsense\Core\Backend;
use \OPNsense\CaptivePortal\CaptivePortal;
use \OPNsense\TrafficShaper\TrafficShaper;
use \OPNsense\Core\Config;

/**
 * Class BandwidthController Handles settings related API actions for the Traffic Shaper
 * @package OPNsense\CaptivePortal
 */
class BandwidthController extends ApiMutableModelControllerBase
{
    static protected $internalModelName = 'ts';
    static protected $internalModelClass = '\OPNsense\TrafficShaper\TrafficShaper';

    /**
     * before routing event
     * @param Dispatcher $dispatcher
     * @return void
     */
    public function beforeExecuteRoute($dispatcher)
    {
        // disable standard authentication in CaptivePortal Access API calls.
        // set CORS headers
        $this->response->setHeader("Access-Control-Allow-Origin", "*");
        $this->response->setHeader("Access-Control-Allow-Methods", "GET,POST");
    }    

    private function getSessions($zoneid)
    {
        $backend = new Backend();
        $allClientsRaw = $backend->configdpRun(
            "captiveportal list_clients",
            array($zoneid, 'json')
        );  
        $allClients = json_decode($allClientsRaw, true);   
        return $allClients;        
    }

    private function getSessionByID($sessionid)
    {
        $mdlCP = new CaptivePortal();
        $backend = new Backend();
        $sessionid = str_replace('\\', '', $sessionid);

        foreach ($mdlCP->zones->zone->iterateItems() as $zone) {
            $sessions = $this->getSessions($zone->zoneid);  
            foreach ($sessions as $session) {
                if ($session['sessionId'] === $sessionid) {
                    return $session;
                }
            }
        }
        return null;
    }  

    private function getZoneById($zoneid)
    {
        $response = null;
        $mdlCP = new CaptivePortal();
        foreach ($mdlCP->zones->zone->iterateItems() as $zone) {
            if ((string)$zone->zoneid === (string)$zoneid) {
                $response = array(
                    "enabled" => (string)$zone->enabled,
                    "zoneid" => (string)$zone->zoneid,
                    "interfaces" => (string)$zone->interfaces,
                );
            }
        }
        return $response;
    }   
    
    private function getRuleData()
    {
        if ($this->request->isPost()) {
            $data = json_decode(file_get_contents('php://input'), true);
            if ($data != null) {
                $response = array();

                $response['traffictype'] = $data['traffictype'];  
                $response['username'] = $data['username'];
                

                $session = $this->getSessionByID($data['sessionId']);
                $zone = $this->getZoneById($session['zoneid']);
                $response['zoneid'] = $zone['zoneid'];
                $response['interfaces'] = $zone['interfaces'];   
                
                if (isset($data['useripaddr'])) {
                    $response['useripaddr'] = $data['useripaddr']; 
                } elseif (isset($session['ipAddress'])) {
                    $response['useripaddr'] = $session['ipAddress']; 
                }

                $response['pipedescription'] = "cp-" . $data['bandwidth'] . $data['bandwidthMetric'] . "-" . $data['traffictype'];
                $response['description'] = "cp-" . $response['username'] . "-" . $data['bandwidth'] . $data['bandwidthMetric'] . "-" . $data['traffictype'];

                $pipes = $this->searchBase(
                    "pipes.pipe",
                    array("enabled","number", "bandwidth","bandwidthMetric","description","mask","origin"),
                    "number"
                );
                foreach ($pipes['rows'] as $pipe) {
                    if ($pipe['origin'] === "CaptivePortal" && $pipe['description'] === $response['pipedescription']) {
                        $response['pipeuuid'] = $pipe['uuid'];
                        break;
                    }
                } 
                
                return $response;
            }
        }
        return array("status" => "failed");
    }

    /**
     * validate and save model after update or insertion.
     * Use the reference node and tag to rename validation output for a specific node to a new offset, which makes
     * it easier to reference specific uuids without having to use them in the frontend descriptions.
     * @param $mdlShaper
     * @param $node reference node, to use as relative offset
     * @param $reference reference for validation output, used to rename the validation output keys
     * @return array result / validation output
     */
    private function validateSave($mdlShaper, $node = null, $reference = null)
    {
        $result = array("result"=>"failed","validations" => array());
        // perform validation
        $valMsgs = $mdlShaper->performValidation();
        foreach ($valMsgs as $field => $msg) {
            // replace absolute path to attribute for relative one at uuid.
            if ($node != null) {
                $fieldnm = str_replace($node->__reference, $reference, $msg->getField());
                $result["validations"][$fieldnm] = $msg->getMessage();
            } else {
                $result["validations"][$msg->getField()] = $msg->getMessage();
            }
        }
        // serialize model to config and save when there are no validation errors
        if (count($result['validations']) == 0) {
            // save config if validated correctly
            $mdlShaper->serializeToConfig();
            Config::getInstance()->save();
            $result = array("result" => "saved");
        }
        return $result;
    }


    /**
     * reconfigure ipfw, generate config and reload
     */
    public function reconfigureAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            $backend->configdRun('template reload OPNsense/IPFW');
            $bckresult = trim($backend->configdRun("ipfw reload"));
            if ($bckresult == "OK") {
                $status = "ok";
            } else {
                $status = "error reloading shaper (".$bckresult.")";
            }
            return array("status" => $status);
        } else {
            return array("status" => "failed");
        }
    }
    
    /**
     * flush all ipfw rules
     */
    public function flushreloadAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            $status = trim($backend->configdRun("ipfw flush"));
            $status = trim($backend->configdRun("ipfw reload"));
            return array("status" => $status);
        } else {
            return array("status" => "failed");
        }
    }    

    /**
     * Retrieve pipe settings or return defaults
     * @param $uuid item unique id
     * @return array traffic shaper pipe content
     * @throws \ReflectionException when not bound to model
     */
    public function getPipeAction($uuid = null)
    {
        return $this->getBase("pipe", "pipes.pipe", $uuid);
    }

    /**
     * Update  pipe with given properties
     * @param string $uuid internal id
     * @return array save result + validation output
     * @throws \Phalcon\Validation\Exception when field validations fail
     * @throws \ReflectionException when not bound to model
     */
    public function setPipeAction($uuid)
    {
        return $this->setBase("pipe", "pipes.pipe", $uuid);
    }

    /**
     * Add new pipe and set with attributes from post
     * @return array save result + validation output
     * @throws \OPNsense\Base\ModelException when not bound to model
     * @throws \Phalcon\Validation\Exception when field validations fail
     */
    public function addPipeAction()
    {
        $result = array("result"=>"failed");
        if ($this->request->isPost()) {
            $data = json_decode(file_get_contents('php://input'), true);
            if ($data != null) {
                $description = "cp-" . $data['bandwidth'] . $data['bandwidthMetric'] . "-" . $data['traffictype'];
                
                $pipes = $this->searchBase(
                    "pipes.pipe",
                    array("enabled","number", "bandwidth","bandwidthMetric","description","mask","origin"),
                    "number"
                );
                foreach ($pipes['rows'] as $pipe) {
                    if ($pipe['origin'] === "CaptivePortal" && $pipe['description'] === $description) {
                        return array("result"=>"pipe already exists");
                    }
                }
                
                $pipe = array(
                    "enabled" => "1",
                    "bandwidth" => $data['bandwidth'],
                    "bandwidthMetric" => $data['bandwidthMetric'],
                    "queue" => "",
                    "mask" => "none",
                    "buckets" => "",
                    "scheduler" => "",
                    "codel_enable" => "0",
                    "codel_target" => "",
                    "codel_interval" => "",
                    "codel_ecn_enable" => "0",
                    "fqcodel_quantum" => "",
                    "fqcodel_limit" => "",
                    "fqcodel_flows" => "",
                    "pie_enable" => "0",
                    "delay" => "",
                    "description" => $description                
                );

                $mdlShaper = new TrafficShaper();
                $node = $mdlShaper->addPipe();
                $node->setNodes($pipe);
                $node->origin = "CaptivePortal"; // set origin to this component. [default: TrafficShaper]
                return $this->validateSave($mdlShaper, $node, "pipe");  
            }
        }
        return $result;
    }

    /**
     * Delete pipe by uuid
     * @param string $uuid internal id
     * @return array save status
     * @throws \Phalcon\Validation\Exception when field validations fail
     * @throws \ReflectionException when not bound to model
     */
    public function delPipeAction()
    {
        $result = array("result"=>"failed");
        if ($this->request->isPost()) {
            $data = json_decode(file_get_contents('php://input'), true);
            if ($data != null) {   
                $uuid = null;     
                $description = "cp-" . $data['bandwidth'] . $data['bandwidthMetric'] . "-" . $data['traffictype'];

                $pipes = $this->searchBase(
                    "pipes.pipe",
                    array("enabled","number", "bandwidth","bandwidthMetric","description","mask","origin"),
                    "number"
                );
                foreach ($pipes['rows'] as $pipe) {
                    if ($pipe['origin'] === "CaptivePortal" && $pipe['description'] === $description) {

                        $rules = $this->searchBase(
                            "rules.rule",
                            array("enabled", "interface", "proto", "source_not","source", "destination_not",
                                  "destination", "description", "origin", "sequence", "target"),
                            "sequence"
                        );
                        $referencecount = 0;
                        foreach ($rules['rows'] as $rule) {
                            if ($rule['target'] === $pipe['description']) {
                                $referencecount++;
                            }
                        }  
                        $result["referencecount"] = $referencecount;
                        if ($referencecount < 2) {
                            $result["result"] = $this->delBase("pipes.pipe", $pipe['uuid']);
                        }
                    }
                }
            }
        }
        return $result;
    }


    /**
     * Toggle pipe defined by uuid (enable/disable)
     * @param $uuid user defined rule internal id
     * @param $enabled desired state enabled(1)/disabled(1), leave empty for toggle
     * @return array save result
     * @throws \Phalcon\Validation\Exception when field validations fail
     * @throws \ReflectionException when not bound to model
     */
    public function togglePipeAction($uuid, $enabled = null)
    {
        return $this->toggleBase("pipes.pipe", $uuid, $enabled);
    }

    /**
     * Search traffic shaper pipes
     * @return array list of found pipes
     * @throws \ReflectionException when not bound to model
     */
    public function searchPipesAction()
    {
        return $this->searchBase(
            "pipes.pipe",
            array("enabled","number", "bandwidth","bandwidthMetric","description","mask","origin"),
            "number"
        );
    }


    /**
     * Search traffic shaper rules
     * @return array list of found rules
     * @throws \ReflectionException when not bound to model
     */
    public function searchRulesAction()
    {
        return $this->searchBase(
            "rules.rule",
            array("enabled", "interface", "proto", "source_not","source", "destination_not",
                  "destination", "description", "origin", "sequence", "target"),
            "sequence"
        );
    }

    /**
     * Retrieve rule settings or return defaults for new rule
     * @param $uuid item unique id
     * @return array traffic shaper rule content
     * @throws \ReflectionException when not bound to model
     */
    public function getRuleAction($uuid = null)
    {
        return $this->getBase("rule", "rules.rule", $uuid);
    }

    /**
     * Update rule with given properties
     * @param string $uuid internal id
     * @return array save result + validation output
     * @throws \Phalcon\Validation\Exception when field validations fail
     * @throws \ReflectionException when not bound to model
     */
    public function setRuleAction($uuid)
    {
        return $this->setBase("rule", "rules.rule", $uuid);
    }

    /**
     * Add new rule and set with attributes from post
     * @return array save result + validation output
     * @throws \OPNsense\Base\ModelException when not bound to model
     * @throws \Phalcon\Validation\Exception when field validations fail
     */
    public function addRuleAction()
    {
        $result = array("result"=>"failed");
        $data = $this->getRuleData();
        if ($data != null && !(isset($data['status']) && $data['status'] != "failed")) {
            $rules = $this->searchBase(
                "rules.rule",
                array("enabled", "interface", "proto", "source_not","source", "destination_not",
                      "destination", "description", "origin", "sequence", "target"),
                "sequence"
            );
            
            foreach ($rules['rows'] as $rule) {
                if ($data['traffictype'] === "uplink") {
                    if ($rule['origin'] === "CaptivePortal" && $rule['source'] === $data['useripaddr'] && $rule['description'] === $data['description']) {
                        return array("result"=>"rule already exists");
                    }
                } else if ($data['traffictype'] === "downlink") {
                    if ($rule['origin'] === "CaptivePortal" && $rule['destination'] === $data['useripaddr'] && $rule['description'] === $data['description']) {
                        return array("result"=>"rule already exists");
                    }
                }
            } 
            
            if (!isset($data['pipeuuid'])) {
                $result["result"] = "failed: pipe uuid is not set.";
                return $result;
            }

            $rule = array(
                "enabled" => "1",
                "sequence" => "1",
                "interface" => $data['interfaces'], #captiveportal
                "interface2" => "",
                "proto" => "ip",
                "source" => "any", #session
                "source_not" => "0",
                "src_port" => "any",
                "destination" => "any", #session
                "destination_not" => "0",
                "dst_port" => "any",
                "direction" => "",
                "target" => $data['pipeuuid'], #trafficshaper
                "description" => $data['description']
            );

            if (isset($data['useripaddr'])) {
                if ($data['traffictype'] === "uplink") {
                    $rule['source'] = $data['useripaddr'];
                } else if ($data['traffictype'] === "downlink") {
                    $rule['destination'] = $data['useripaddr'];
                }   
            }

            $mdlShaper = new TrafficShaper();
            $node = $mdlShaper->rules->rule->add();
            $node->setNodes($rule);
            $node->origin = "CaptivePortal"; // set origin to this component. [default: TrafficShaper]
            return $this->validateSave($mdlShaper, $node, "rule"); 
        }
        return $result;        
    }
    /**
     * Delete rule by uuid
     * @param string $uuid internal id
     * @return array save status
     * @throws \Phalcon\Validation\Exception when field validations fail
     * @throws \ReflectionException when not bound to model
     */
    public function delRuleAction()
    {
        $result = array("result"=>"failed");
        $data = $this->getRuleData();
        if ($data != null && !(isset($data['status']) && $data['status'] != "failed")) {
            $rules = $this->searchBase(
                "rules.rule",
                array("enabled", "interface", "proto", "source_not","source", "destination_not",
                      "destination", "description", "origin", "sequence", "target"),
                "sequence"
            );
            foreach ($rules['rows'] as $rule) {                
                if ($data['traffictype'] === "uplink") {                 
                    if ($rule['origin'] === "CaptivePortal" && $rule['source'] === $data['useripaddr'] && $rule['description'] === $data['description']) {
                        $result["result"] = $this->delBase("rules.rule", $rule['uuid']);
                    }
                } else if ($data['traffictype'] === "downlink") {                
                    if ($rule['origin'] === "CaptivePortal" && $rule['destination'] === $data['useripaddr'] && $rule['description'] === $data['description']) {
                        $result["result"] = $this->delBase("rules.rule", $rule['uuid']);
                    }
                }
            }
        }
        return $result;
    }

    /**
     * Toggle rule defined by uuid (enable/disable)
     * @param $uuid user defined rule internal id
     * @param $enabled desired state enabled(1)/disabled(1), leave empty for toggle
     * @return array save result
     * @throws \Phalcon\Validation\Exception when field validations fail
     * @throws \ReflectionException when not bound to model
     */
    public function toggleRuleAction($uuid, $enabled = null)
    {
        return $this->toggleBase("rules.rule", $uuid, $enabled);
    }
}
