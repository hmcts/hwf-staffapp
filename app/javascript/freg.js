'use strict';

window.moj.Modules.JsonSearcherModule = (function() {
  // Make codes accessible to both init and findMatches
  let codes = [];

  return {
    init: function() {
      console.log('JsonSearcherModule initialized');
      codes = window.moj.Modules.LoadCodesModule.getCodes();
    },
    findMatches: function (term) {
      return codes.filter(item =>
        (item.code && item.code.toLowerCase().includes(term.toLowerCase())) ||
        (item.jurisdiction2 && item.jurisdiction2.name && item.jurisdiction2.name.toLowerCase().includes(term.toLowerCase()))
      );
    }
  };
})();


// window.moj.Modules.JsonSearcherModule.findMatches('fee0424')
// this is how you call it