'use strict';

var util = require('util');

exports.command = function(fields, value, callback) {
  var client = this;

  this.perform(function() {
    function clickOption(field, value) {
      var el = util.format('input#%s_%s', field, value);
      client.click(el, function() {
        console.log('     * Setting "' + field + '"' + ' to "' + value + '"');
      });
    }

    if(fields.constructor === Array) {
      fields.forEach(function(field) {
        clickOption(field, value);
      });
    } else {
      clickOption(fields, value);
    }
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
