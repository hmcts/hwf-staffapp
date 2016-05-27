'use strict';

window.moj.Modules.equalHeightBoxes = {
  init: function() {
    var self = this;

    if($('[data-equalheight="true"]').length) {
      self.getBoxGroups();
    }
  },

  getBoxGroups: function() {
    var self = this,
        groups = [];

    $('[data-equalheight="true"]').each(function(n, el) {
      var $el = $(el);

      if(groups.indexOf($el.data('heightgroup')) === -1) {
        groups[groups.length] = $el.data('heightgroup');
      }
    });

    if(groups.length) {
      self.equaliseBoxes(groups);
    }
  },

  equaliseBoxes: function(groups) {
    for(var x in groups) {
      var group = groups[x],
          $boxes = $('[data-heightgroup="' + group + '"]'),
          max = 0;

      $boxes.each(function(n, box) {
        var height = $(box).height();

        if(height >= max) {
          max = height;
        }
      });

      $boxes.height(max);
    }
  }
};
