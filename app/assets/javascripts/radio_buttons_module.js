'use strict';

window.moj.Modules.RadioButtonsModule = {
  init: function() {
    this.bindEvents();
    this.checkStateOnLoad();
  },

  bindEvents: function() {
    $('input.show-hide-section:radio').on('change', function() {
      var $section = $('#' + $(this).data('section') + '-only');
      $section.toggle($(this).data('show'));
      if(!$(this).data('show')) {
        $section.find('input[type="radio"]').prop('checked', false);
        $section.find('label.selected').removeClass('selected');
        $section.find('div[id$="-only"]').hide();
      }
    });

    $('input[type=radio]').on('change', function() {
      $("[name='" + $(this).attr('name') + "']").parents('label').removeClass("selected");
      $(this).parents('label').addClass('selected');
    });
  },

  checkStateOnLoad: function() {
    $('input.show-hide-section:radio').each(function() {
      if ($(this).is(':checked')) {
        $('#' + $(this).data('section') + '-only').toggle($(this).data('show'));
      }
    });

    $('input[type=radio]').each(function() {
      $(this).parents('label').toggleClass('selected', $(this).is(':checked'));
    });
  }
};
