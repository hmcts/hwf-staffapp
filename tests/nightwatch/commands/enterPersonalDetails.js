'use strict';

var log = require('../modules/log'),
    util = require('util');

exports.command = function(options, callback) {
  var client = this,
      isMarried = options.isMarried || 'false';

  this.perform(function() {
    log.command(util.format('Fill in personal details, marital status: %s...', (isMarried ? 'married' : 'single')));

    client
      .ensureCorrectPage('form#new_application', '/personal_information', {
        'h2': 'Personal details'
      })
      .setValue('#application_first_name', 'Test')
      .setValue('#application_last_name', 'Tester')
      .setValue('#application_date_of_birth', '01/01/1990')
      .setValue('#application_ni_number', 'AB123456C')
      .radioSelect('application_married', isMarried.toString())

      .submitForm('#new_application')
    ;
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
