'use strict';

var log = require('../modules/log');

exports.command = function(options, callback) {
  var client = this,
      thresholdExceeded = options.thresholdExceeded || 'false',
      submitForm = options.submitForm || 'true';

  this.perform(function() {
    log.command('Fill in savings and investments details...');

    client
      .ensureCorrectPage('form#new_application', '/savings_investments', {
        'h2': 'Savings and investments'
      })
      .assert.hidden('#over-61-only')
      .radioSelect('application_threshold_exceeded', thresholdExceeded.toString())
      .assert.visible('#over-61-only')
    ;

    if(options.partnerOver61) {
      client.radioSelect('application_partner_over_61', options.partnerOver61.toString());
    }

    if(options.highThresholdExceeded) {
      client.radioSelect('application_high_threshold_exceeded', options.highThresholdExceeded.toString());
    }

    if(submitForm.toString() === 'true') {
      client.submitForm('#new_application');
    }
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
