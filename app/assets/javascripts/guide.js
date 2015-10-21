var FR = {};

FR.equalHeightColumns = function() {
  var wrapper = $('.guide-cols-container');
  var cols = wrapper.find('.guide-cols');
  var max = 0;
  var arr = [];

  cols.each(function(i, el) {
    var height = Math.max($(el).outerHeight());
    if(height >= max) {
      max = height;
    }
  });
  cols.height(max);
};

$(function(){
  if($('.guide-cols-container'.length)){
    FR.equalHeightColumns();
  }
});
