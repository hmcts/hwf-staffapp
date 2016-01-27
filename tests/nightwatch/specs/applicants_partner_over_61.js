'use strict';

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
      .enterSavingsDetails({
        thresholdExceeded: 'true',
        submitForm: 'false'
      })
    ;
  },

  'Test radio buttons': function(client) {
    client
      .radioSelect('application_partner_over_61', false)
      .radioSelect('application_threshold_exceeded', false)
      .assert.hidden('#over-61-only')
      // test that #application_partner_over_61_false is not checked
      // TODO: make this into a custom assertion (tried but failed)
      .element('id', 'application_partner_over_61_false', function(response) {
        client.elementIdSelected(response.value.ELEMENT, function(result) {
          client.assert.ok(!result.value, 'Radio button #application_partner_over_61_false is not selected');
        });
      })
      .element('id', 'application_partner_over_61_true', function(response) {
        client.elementIdSelected(response.value.ELEMENT, function(result) {
          client.assert.ok(!result.value, 'Radio button #application_partner_over_61_true is not selected');
        });
      })
    ;
  },

  'End': function(client) {
    client
      .end()
    ;
  }
};
