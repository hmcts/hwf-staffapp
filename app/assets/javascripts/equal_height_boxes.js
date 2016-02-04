'use strict';

window.moj.Modules.equalHeightBoxes = {
  init: function() {
    var self = this;

    if($('.equal-heightboxes').length) {
      self.equaliseBoxes('.equal-heightboxes', '.panel');
    }
  },

  equaliseBoxes: function(wrapper, panel) {
    var panels = $(wrapper).find(panel),
        max = 0;

    panels.each(function(i, el) {
      var height = $(el).height();

      if(height >= max) {
        max = height;
      }
    });
    return panels.height(max);
  }
};
