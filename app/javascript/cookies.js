'use strict';

window.moj.Modules.Cookies = {
  set: function (name, value, options){
    var cookieString = name + '=' + value + '; path=/',
        date;

    if (typeof options === 'undefined') {
      options = {};
    }
    if (options.days) {
      date = new Date();
      date.setTime(date.getTime() + (options.days * 24 * 60 * 60 * 1000));
      cookieString = cookieString + '; expires=' + date.toGMTString();
    }
    if (document.location.protocol === 'https:') {
      cookieString = cookieString + '; Secure';
    }
    document.cookie = cookieString;
  },

  get: function (name){
    var nameEQ = name + '=',
        cookies = document.cookie.split(';'),
        i, len, cookie;

    for (i = 0, len = cookies.length; i < len;) {
      cookie = cookies[i];
      while (cookie.charAt(0) === ' ') {
        cookie = cookie.substring(1, cookie.length);
      }
      if (cookie.indexOf(nameEQ) === 0) {
        return decodeURIComponent(cookie.substring(nameEQ.length));
      }
      i += 1;
    }
    return null;
  },

  remove: function (name){
    var self = this;

    if (self.get(name) === undefined) {
      return false;
    }
    self.set(name, '', { days: -1 });
    return !self.get(name);
  }
};
