'use strict';

var log = require('../modules/log'),
    util = require('util');

exports.command = function(userType, callback) {
  var client = this;

  this.perform(function() {
    log.command(util.format('Logging in %s...', userType));

    client
      .setValue('#user_email', util.format('bristol.%s@hmcts.gsi.gov.uk', userType))
      .setValue('#user_password', '987654321')
      .submitForm('#new_user')
      .pause(200)
      .ensureCorrectPage('h3.icon-evidence', '', {
        'h3': 'Process application'
      })
    ;
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
