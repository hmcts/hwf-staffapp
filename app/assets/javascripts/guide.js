var FR = {};

FR.equalHeightColumns = function() {
  var cols = $('.guide-cols');
  var max = 0;

  cols.each(function(i, el) {
    var height = Math.max($(el).height());
    if(height >= max) {
      max = height;
    }
  });
};

$(function(){
  if($('.guide-cols'.length)){
    FR.equalHeightColumns();
  }
});
