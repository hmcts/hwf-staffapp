'use strict';

var log = require('../modules/log');

exports.command = function(callback) {
  var client = this;

  this.perform(function() {
    log.command('Starting the service...');

    client
      .deleteCookies()
      .init()
      .maximizeWindow()
      .ensureCorrectPage('form[action="/users/sign_in"]', '/users/sign_in', {
        'h2': 'Sign in'
      })
      .clearValue('#user_email')
      .pause(200)
    ;
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
