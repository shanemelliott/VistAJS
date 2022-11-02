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
//VistaJS.callRpc(logger, configuration, 'SDES GET USER PROFILE BY DUZ', [VistaJS.RpcParameter.literal('1')],printJsonResult);
 VistaJS.callRpc(logger, configuration, 'RPC ORWDX SAVE', [
     100022,
     10000000226,
     11,
     'PSH OERR',
     48,
     389,
     '', {
        '("WP",15,1,1,0)': '\"this comment\"',
         '(0,1)': '',
         '("WP",1615,1,1,0)': '',
         '(385,1)': 'ORDIALOG("WP",385,1)',
         '(4,1)': 1349,
         '(136,1)': '500MG',
         '(138,1)': 639,
         '(386,1)': '500&MG&1&CAPSULE&500MG&639&500&MG',
         '(384,1)': '500MG',
         '(137,1)': 1,
         '(170,1)': 'NOW',
         
     },
     '',
     '',
     '',
     0
 ], printResult);
 //VistaJS.callRpc(logger, configuration, 'SDES GET APPTS BY CLINIC LIST', [{ type: 'list', value: '12,13,14' }],printJsonResult)