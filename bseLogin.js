/*jslint node: true */
/*jshint -W098 */
'use strict';

var util = require('util');
var _ = require('underscore');
var clc = require('cli-color');
var VistaJS = require('./VistaJS');
const configuration = require('./config');
var logger = require('bunyan').createLogger({
    name: 'RpcClient',
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
console.log('Executing RPC...')
configuration.context = 'CDSP RPC CONTEXT';
VistaJS.callRpcBSE(logger, configuration, 'ORWPT SELECT', [VistaJS.RpcParameter.literal('237')],printJsonResult);

