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
      .waitForElementVisible('body', 1000,
        '  - Page is ready')
      .assert.visible('footer.page-footer',
        '  - Page has footer')
      .pause(200)
    ;
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
