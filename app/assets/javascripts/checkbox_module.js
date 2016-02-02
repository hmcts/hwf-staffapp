'use strict';

window.moj.Modules.CheckboxModule = {
  init: function() {
    this.bindEvents();
    this.checkStateOnLoad();
  },

  bindEvents: function() {
    var self = this;

    $('input:checkbox').on('change', function(e) {
      self.setBoxState($(e.target));
    });
  },

  setBoxState: function($el) {
    $el.closest('label').toggleClass('selected', $el.is(':checked'));
    if($el.hasClass('show-hide-checkbox')) {
      $('#' + $el.data('section') + '-only').toggle($el.is(':checked'));
    }
  },

  checkStateOnLoad: function() {
    var self = this;

    $('input:checkbox').each(function(n, checkbox) {
      self.setBoxState($(checkbox));
    });
  }
};
