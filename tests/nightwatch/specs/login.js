'use strict';

module.exports = {
  'Start': function(client) {
    client
      .startService()
    ;
  },

  'Check login is empty': function(client) {
    client
      .assert.value('form.new_user input#user_email', '')
    ;
  },

  'Log in as manager': function(client) {
    client
      .logInUser('manager')
    ;
  },

  'Log out': function(client) {
    client
      .click('.top-bar-section a[href="/users/sign_out"]')
      .pause(200)
      .ensureCorrectPage('form[action="/users/sign_in"]', '/users/sign_in', {
        'h2': 'Sign in'
      })
    ;
  },

  'Check email is remembered': function(client) {
    client
      .assert.value('form.new_user input#user_email', 'bristol.manager@hmcts.gsi.gov.uk')
    ;
  },

  'End': function(client) {
    client
      .end()
    ;
  }
};
