var FR = FR || {};

FR.login = {
  init: function() {
    var self = this,
        $form = $('form.new_user[action$="users/sign_in"]');

    if ($form.length) {
      self.checkLoginCookie();
      self.writeCookieOnSubmit($form);
    }
  },

  checkLoginCookie: function() {
    var u = FR.Cookies.get('fr_username');

    if (u) {
      $('#user_email').val(u);
    }
  },

  writeCookieOnSubmit: function($form) {
    $form.on('submit', function() {
      FR.Cookies.set('fr_username', $form.find('#user_email').val(), {days: 30});
    });
  }
};

$(function() {
  FR.login.init();
});
