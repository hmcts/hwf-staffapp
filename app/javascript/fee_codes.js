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
      console.warn('[LoadCodesModule] Already loading fee codes...');
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
        console.log('[LoadCodesModule] Successfully loaded', codes.length, 'fee codes from backend');
      },
      error: function(xhr, status, error) {
        console.error('[LoadCodesModule] Failed to load fee codes:', error);
        console.error('[LoadCodesModule] Status:', status, 'Response:', xhr.responseText);
        codes = []; // Return empty array on error
        alert('Failed to load fee codes. Please refresh the page.');
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
