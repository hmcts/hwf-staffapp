'use strict';

window.moj.Modules.RadioButtonsModule = {
  init: function() {
    this.bindEvents();
    this.checkStateOnLoad();
  },

  bindEvents: function() {
    var self = this;

    $('input.show-hide-section:radio').on('change', function(e) {
      var $el = $(e.target),
          groupName = $el.attr('name'),
          group = $('[type="radio"][name="' + groupName + '"]');

      group.each(function(n, item) {
        self.radioHide($(item));
      });
      self.radioShow($el);
    });

    $('input[type=radio]').on('change', function(e) {
      var $el = $(e.target);

      $("[name='" + $el.attr('name') + "']").parents('label').removeClass("selected");
      $el.closest('label').addClass('selected');
    });
  },

  checkStateOnLoad: function() {
    $('input.show-hide-section:radio').each(function(e) {
      var $el = $(e.target);

      if ($el.is(':checked')) {
        $('#' + $el.data('section') + '-only').toggle($el.data('show'));
      }
    });

    $('input[type=radio]').each(function(e) {
      var $el = $(e.target);

      $el.closest('label').toggleClass('selected', $el.is(':checked'));
    });
  },

  radioHide: function($el) {
    var $section = $('#' + $el.data('section') + '-only');

    $section.hide();
    $section.find('input[type="radio"]').prop('checked', false);
    $section.find('input[type="text"], input[type="number"], textarea').val('');
    $section.find('label.selected').removeClass('selected');
    $section.find('div[id$="-only"]').hide();
  },

  radioShow: function($el) {
    $('#' + $el.data('section') + '-only').show();
  }
};
