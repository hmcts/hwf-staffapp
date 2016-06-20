'use strict';

window.moj.Modules.RadioAndCheckboxModule = {
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

    $('input:checkbox').on('change', function(e) {
      self.setBoxState($(e.target));
    });
  },

  checkStateOnLoad: function() {
    var self = this;

    $('input.show-hide-section:radio').each(function(n, el) {
      var $el = $(el);

      if ($el.is(':checked')) {
        $('#' + $el.data('section') + '-only').show();
      }
    });

    $('input[type="radio"]').each(function(n, el) {
      var $el = $(el);

      $el.closest('label').toggleClass('selected', $el.is(':checked'));
    });

    $('input:checkbox').each(function(n, checkbox) {
      self.setBoxState($(checkbox));
    });
  },

  setBoxState: function($el) {
    $el.closest('label').toggleClass('selected', $el.is(':checked'));
    if($el.hasClass('show-hide-checkbox')) {
      $('#' + $el.data('section') + '-only').toggle($el.is(':checked'));
    }
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
