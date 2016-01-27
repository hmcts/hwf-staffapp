'use strict';

var log = require('../modules/log'),
    util = require('util');

exports.command = function(userType, callback) {
  var client = this;

  this.perform(function() {
    log.command(util.format('Logging in %s...', userType));

    client
      .clearValue('#user_email')
      .clearValue('#user_password')

      .setValue('#user_email', util.format('bristol.%s@hmcts.gsi.gov.uk', userType))
      .setValue('#user_password', '987654321')
      .submitForm('#new_user')
    ;
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
