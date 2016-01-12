var FR = FR || {};

FR.equalHeightBoxes = function(wrapper, panel) {
  var panels = $(wrapper).find(panel);
  var max = 0;

  panels.each(function(i, el) {
    var height = FR.getHeight($(el));
    if(height >= max) {
      max = height;
    }
  });
  return panels.height(max);
};

FR.getHeight = function(panel) {
  if(panel.hasClass('guide-cols')){
    return Math.max(panel.outerHeight());
  } else {
    return Math.max(panel.height());
  }
};

$(function(){
  if($('.equal-heightboxes').length) {
    FR.equalHeightBoxes('.equal-heightboxes', '.panel');
  }
});
