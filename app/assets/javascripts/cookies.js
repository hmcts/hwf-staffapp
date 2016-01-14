var FR = FR || {};

FR.Cookies = {
  set: function (name, value, options){
    if (typeof options === 'undefined') {
      options = {};
    }
    var cookieString = name + '=' + value + '; path=/',
        date;
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
    // moj.log(cookies);
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
    if (FR.Cookies.get(name) === undefined) {
      return false;
    }

    FR.Cookies.set(name, '', { days: -1 });
    return !FR.Cookies.get(name);
  }
};
