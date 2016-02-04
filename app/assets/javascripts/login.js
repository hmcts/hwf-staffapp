'use strict';

window.moj.Modules.Login = {
  userCookie: 'fr_username',
  emailField: '#user_email',

  init: function() {
    var self = this,
        $form = $('form.new_user[action$="users/sign_in"]');

    if ($form.length) {
      self.checkLoginCookie();
      self.writeCookieOnSubmit($form);
    }
  },

  checkLoginCookie: function() {
    var self = this,
        storedUser = window.moj.Modules.Cookies.get(self.userCookie);

    if (storedUser) {
      $(self.emailField).val(storedUser);
    }
  },

  writeCookieOnSubmit: function($form) {
    var self = this;

    $form.on('submit', function() {
      window.moj.Modules.Cookies.set(self.userCookie, $form.find(self.emailField).val(), {days: 30});
    });
  }
};
