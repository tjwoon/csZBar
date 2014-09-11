var argscheck = require('cordova/argscheck'),
    exec      = require('cordova/exec');

function ZBar () {};

ZBar.prototype = {

    scan: function (params, success, failure)
    {
        argscheck.checkArgs('*fF', 'CsZBar.scan', arguments);
        exec(success, failure, 'CsZBar', 'scan', [params]);
    },

};

module.exports = new ZBar;
