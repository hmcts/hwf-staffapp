var FR = {};

FR.equalHeightBoxes = function(wrapper, panel) {
  var panels = $(wrapper).find(panel);
  var max = 0;
  var arr = [];

  panels.each(function(i, el) {
    var height = Math.max($(el).outerHeight());
    if(height >= max) {
      max = height;
    }
  });
  return panels.height(max);
};

$(function(){
  if($('.equal-heightboxes').length){
    FR.equalHeightBoxes('.equal-heightboxes', '.panel');
  }
});
