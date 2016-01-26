'use strict';

exports.command = function() {
  var args = Array.prototype.slice.call(arguments);
  args.unshift(' -->');

  console.log.apply(console, args);
};
