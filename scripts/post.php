<?php
//
// A very simple PHP example that sends a HTTP POST to a remote site
//

$ch = curl_init();

$payload = json_encode(array( "sessionId" => "g+x09CDSz7W69zOQWgRu+g=="));
$headers = array(
    'Content-Type: application/json',
    'Accept: application/json',
    'Access-Control-Allow-Origin: *',
    'Access-Control-Allow-Methods: OPTIONS, GET, POST'
);

curl_setopt($ch, CURLOPT_URL,"https://192.168.50.1/api/captiveportal/session/list");
//curl_setopt($ch, CURLOPT_POST, 1);
//curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_VERBOSE, 1);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
// Receive server response ...
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$server_output = curl_exec($ch);
curl_close ($ch);

var_dump($server_output);
?>