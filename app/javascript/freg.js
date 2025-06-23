'use strict';

window.moj.Modules.JsonSearcherModule = (function() {
  // Make codes accessible to both init and findMatches
  let codes = [];

  // Ideally search for fee (amount), jurisdictions, service type and event type.
  return {
    init: function() {
      console.log('JsonSearcherModule initialized');
      codes = window.moj.Modules.LoadCodesModule.getCodes();
    },
    findMatches: function (term) {
      return codes.filter(item =>
      (item.code && item.code.toLowerCase().includes(term.toLowerCase())) ||
      (item.jurisdiction2 && item.jurisdiction2.name && item.jurisdiction2.name.toLowerCase().includes(term.toLowerCase())) ||
      (item.current_version && item.current_version.flat_amount && typeof item.current_version.flat_amount.amount === 'number' && item.current_version.flat_amount.amount.toString().includes(term))
      );
    }
  };
})();


// window.moj.Modules.JsonSearcherModule.findMatches('fee0424')
// this is how you call it