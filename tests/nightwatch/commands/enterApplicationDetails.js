'use strict';

var log = require('../modules/log'),
    moment = require('moment');

exports.command = function(options, callback) {
  var client = this,
      fee = options.fee || 250,
      today = moment().format('DD/MM/YYYY');

  this.perform(function() {
    log.command('Fill in application details...');

    client
      .ensureCorrectPage('form#new_application', '/application_details', {
        'h2': 'Application details'
      })
      .setValue('#application_fee', fee)
      .click('.options .option:last-child input[name="application[jurisdiction_id]"]')
      .setValue('#application_date_received', today)

      .submitForm('#new_application')
    ;
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
