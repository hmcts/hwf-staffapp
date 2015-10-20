var FR = {};

FR.equalHeightColumns = function() {
  var cols = $('.guide-cols');
  var max = 0;

  cols.each(function(i, el) {
    var height = Math.max($(el).height());
    max = (height >= max) ? height : max;
    cols.height(max);
  });
};

$(function(){
  if($('.guide-cols'.length)){
    // FR.equalHeightColumns();
  }
});
