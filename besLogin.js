/*jslint node: true */
/*jshint -W098 */
'use strict';

var util = require('util');
var _ = require('underscore');
var clc = require('cli-color');
var moment = require('moment');
var VistaJS = require('./VistaJS');
const configuration = require('./config');
var logger = require('bunyan').createLogger({
    name: 'RpcClient',
    level: 'debug'
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
console.log('Executing RPC...')
VistaJS.callRpcBSE(logger, configuration, 'SDES GET USER PROFILE BY DUZ', [VistaJS.RpcParameter.literal('1')],printJsonResult);
/*
function splitTokenIntoChunks(token) {
    const mult = {}; // This is like Param[0].Mult
    const chunkSize = 200;
    let i = 0;
    for (let iStart = 0; iStart < token.length; iStart += chunkSize) {
      const chunk = token.substr(iStart, chunkSize); // get 200 characters
      mult[i.toString()] = chunk; // store it under key '0', '1', '2', etc.
      i++;
    }
    return mult;
}
const mult = splitTokenIntoChunks(configuration.samlToken);
//console.log('mult', mult);
configuration.context = 'CDSP RPC UTILSS';
//XOBV TEST GLOBAL ARRAY
VistaJS.callRpc(logger, configuration, 'XUS ESSO VALIDATE', [mult],printJsonResult);
VistaJS.callRpc(logger, configuration, 'XOBV TEST GLOBAL ARRAY', [param],printJsonResult);
*/
