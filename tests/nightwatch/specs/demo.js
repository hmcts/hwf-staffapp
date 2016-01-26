'use strict';

module.exports = {
  'Test': function(client) {
    client.startService();
    client.logInUser('manager');

    client.end();
  }
};
