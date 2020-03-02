
// var request = require('request');
// request.options.secureProtocol = 'SSLv3_method';

// request.post(
//     "https://192.168.50.1/api/captiveportal/session/disconnect/0/", 
//     {
//         json: true, 
//         body: {'sessionId': 'g+x09CDSz7W69zOQWgRu+g=='}
//     }, 
//     function(err, res, body) {
//         console.log(err, res, body);
//     }
// );

const https = require('https');
const { constants } = require('crypto');

var postData = JSON.stringify({
    sessionId: 'g+x09CDSz7W69zOQWgRu+g=='
})

var options = {
    hostname: '192.168.50.1',
    port: 443,
    path: '/api/captiveportal/session/disconnect/0/',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': postData.length
    },
    rejectUnauthorized: false,
    requestCert: false
};

var req = https.request(options, (res) => {
    console.log('statusCode:', res.statusCode);
    console.log('headers:', res.headers);

    res.on('data', (d) => {
        process.stdout.write(d);
    });
});

req.on('error', (e) => {
    console.error(e);
});

req.write(postData);
req.end();

