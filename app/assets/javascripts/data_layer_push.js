var googleDataLayerPush = function(){
  var googleDataLayerPush = {};

  function bindLinks(){
    $('a[data-section-name]').click(function(target){
      sectionName = $(target.currentTarget).data('section-name');
      pushDataLayerEvent(sectionName);
    });
  }

  function pushDataLayerEvent(sectionName){
    dataLayer.push({'event': 'summary_page', 'sectionName': sectionName});
  }

  googleDataLayerPush.init = function(value) {
    bindLinks()
  };
  return googleDataLayerPush;

}();
