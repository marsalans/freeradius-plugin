<?php
/**
 *    Copyright (C) 2015 Deciso B.V.
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

use \OPNsense\Base\ApiControllerBase;
use \OPNsense\Core\Backend;
use \OPNsense\CaptivePortal\CaptivePortal;

/**
 * Class RadiusController
 * @package OPNsense\CaptivePortal
 */
class RadiusController extends ApiControllerBase
{
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
        $this->response->setHeader("Access-Control-Allow-Methods", "GET");
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
            if ($sessions != null) {
                foreach ($sessions as $session) {
                    if ($session['sessionId'] === $sessionid) {
                        return $session;
                    }
                }
            }
        }
        return null;
    }       

    /**
     * disconnect a client
     * @param string|int $zoneid zoneid
     * @return array|mixed
     */
    public function disconnectAction()
    {
        if ($this->request->isPost()) {  
            $contents = file_get_contents('php://input');
            $data = json_decode($contents, true);
            if ($data != null && isset($data['sessionId'])) {
                $session = $this->getSessionByID($data['sessionId']);
                
                if ($session != null) {
                    $backend = new Backend();
                    $zoneid = $session['zoneid'];
                    $sessionid = $session['sessionId'];
    
                    $statusRAW = $backend->configdpRun(
                        "captiveportal disconnect",
                        array($zoneid, $sessionid, 'json')
                    );
    
                    $status = json_decode($statusRAW, true);
                    if ($status != null) {
                        return $status;
                    } else {
                        return array(
                            "result" => "failed", 
                            "error" => "Illegal response"
                        );                        
                    }
                } else {
                    return array(
                        "result" => "failed", 
                        "error" => "Illegal zone"
                    );
                }                
            }            
        }
        return array(
            "result" => "failed", 
            "error" => json_last_error()
        );
    }    
}