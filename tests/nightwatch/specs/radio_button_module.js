'use strict';

var util = require('util');

module.exports = {
  'Start': function(client) {
    client
      .startService()
    ;
  },

  'Log in as manager': function(client) {
    client
      .logInUser('manager')
    ;
  },

  'Start an application': function(client) {
    client
      .ensureCorrectPage('h3.icon-evidence', '', {
        'h3': 'Process application'
      })
      .click('a[href$="applications/create"]')
    ;
  },

  'Enter personal details': function(client) {
    client
      .enterPersonalDetails({
        isMarried: true
      })
    ;
  },

  'Enter application details': function(client) {
    client
      .enterApplicationDetails({
        fee: 500
      })
    ;
  },

  'Savings and investments': function(client) {
    client
      .assert.hidden('#over-61-only')
      .assert.hidden('#high-threshold-only')
      .enterSavingsDetails({
        thresholdExceeded: 'true',
        partnerOver61: 'true',
        highThresholdExceeded: 'true',
        submitForm: 'false'
      })
      .assert.visible('#over-61-only')
      .assert.visible('#high-threshold-only')
    ;
  },

  'Test show/hide button clearing': function(client) {
    client
      .radioSelect('application_threshold_exceeded', false)
      .assert.hidden('#over-61-only')
      .assert.hidden('#high-threshold-only')
    ;

    ['application_partner_over_61', 'application_high_threshold_exceeded'].forEach(function(group) {
      ['true', 'false'].forEach(function(option) {
        var buttonId = util.format('%s_%s', group, option);
        client
          .element('id', buttonId, function(response) {
            client.elementIdSelected(response.value.ELEMENT, function(result) {
              client.assert.ok(!result.value, util.format('Radio button #%s is not selected', buttonId));
            });
          });
      });
    });
  },

  'End': function(client) {
    client
      .end()
    ;
  }
};
