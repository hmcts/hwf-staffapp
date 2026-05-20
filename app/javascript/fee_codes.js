'use strict';

window.moj.Modules.LoadCodesModule = (function() {
  // Private codes array - will be loaded from backend API
  let codes = null;
  let loading = false;

  function loadCodesFromBackend() {
    if (codes !== null) {
      return codes;
    }

    if (loading) {
      return [];
    }

    loading = true;

    // Synchronous AJAX call to maintain backward compatibility with existing code
    // that expects getCodes() to return data immediately
    $.ajax({
      url: '/api/fee_codes',
      method: 'GET',
      dataType: 'json',
      async: false, // Synchronous to ensure codes are available immediately
      success: function(response) {
        codes = response;
      },
      error: function(xhr, status, error) {
        codes = [];
      },
      complete: function() {
        loading = false;
      }
    });

    return codes || [];
  }

  return {
    getCodes: function() {
      return loadCodesFromBackend();
    }
  };
})();
