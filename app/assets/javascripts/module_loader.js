(function(){
  "use strict";

  var moj = {

    Modules: {},

    Utilities: {},

    Events: $({}),

    init: function(){
      var x;

      for( x in moj.Modules ) {
        if(moj.Modules.hasOwnProperty(x)){
          if(typeof moj.Modules[x].init === 'function') {
            moj.Modules[x].init();
          }
        }
      }
    },

    // safe logging
    log: function( msg ) {
      if( window && window.console ) {
        window.console.log( msg );
      }
    },
    dir: function( obj ) {
      if( window && window.console ) {
        window.console.dir( obj );
      }
    }
  };

  window.moj = moj;
}());
