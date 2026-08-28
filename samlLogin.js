/*jslint node: true */
/*jshint -W098 */
'use strict';

var util = require('util');
var _ = require('underscore');
var clc = require('cli-color');
var http = require('http');
var VistaJS = require('./VistaJS');
const configuration = require('./config');
var logger = require('bunyan').createLogger({
    name: 'RpcClient-SAML',
    level: 'info'
});

function inspect(obj) {
    return obj ? util.inspect(obj, {
        depth: null
    }) : '';
}

function printResult(error, result) {
    console.log(clc.red(inspect(error)));
    console.log(clc.cyan(inspect(result)));
}

function printJsonResult(error, result) {
    console.log(clc.red(inspect(error)));
    var output = result;
    try {
        output = JSON.parse(result);
    } catch (err) {
        // use default
    }
    console.log(clc.cyan(inspect(output)));
}

function fetchSamlToken(callback) {
    console.log('Fetching SAML token from token server...');
    
    http.get('http://localhost:3000', (res) => {
        let data = '';
        
        res.on('data', (chunk) => {
            data += chunk;
        });
        
        res.on('end', () => {
            try {
                const response = JSON.parse(data);
                if (response.saml) {
                    console.log('SAML token received from token server');
                    console.log('Environment:', response.environment);
                    callback(null, response.saml);
                } else {
                    callback(new Error('No SAML token in response'));
                }
            } catch (err) {
                callback(err);
            }
        });
    }).on('error', (err) => {
        callback(err);
    });
}

// Main execution
fetchSamlToken(function(error, samlToken) {
    if (error) {
        console.error(clc.red('Error fetching SAML token:'), error);
        process.exit(1);
    }
    
    // Update configuration with SAML token
    configuration.samlToken = samlToken;
    configuration.context = 'CDSP RPC CONTEXT';
    
    console.log('Executing RPC with SAML authentication...');
    
    // Make the RPC call using BSE/SAML authentication
    VistaJS.callRpcBSE(
        logger, 
        configuration, 
        'ORWPT SELECT', 
        [VistaJS.RpcParameter.literal('237')],
        printJsonResult
    );
});
