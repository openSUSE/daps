/* http://stackoverflow.com/questions/5489869/is-there-a-plugin-that-makes-the-jquery-id-selector-dot-safe
   We use lots of .'s in our IDs. The following "helps". Note that you can't use
   selectors like #id.class any more, unless the ID starts with an underscore.
*/

(function($){
 $.fn._init = $.fn.init;
 $.fn.init = function ( selector, context, rootjQuery ) {
  if (typeof selector == 'string' && selector.match(/^#(?!_)/)) {
   if (/\./.test(selector)) {
       var reconstructed = '#';
       selector = selector.replace(/\#/, '');
       var bar = selector.match(/\./g).length + 1;
       for (var i=0; i < bar; ++i) {
           reconstructed = reconstructed.concat(selector.match(/[^\s\.]*/));
           if (i < bar-1) reconstructed = reconstructed.concat('\\.');
           selector = selector.replace(/[^\s\.\\]*\./, '');
       }
       selector = reconstructed;
   }
  }
  return new $.fn._init(selector,context,rootjQuery);
}
})(jQuery);


$(document).ready(function() {
    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').append('<span class="arrow">&nbsp;</span>');
    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').click(function(e) {
        $('#_bubble-toc > ol > li').removeClass('active');
        $('#_bubble-toc > ol > li').addClass('inactive');
        $(this).parent('li').removeClass('inactive');
        $(this).parent('li').addClass('active');
        e.preventDefault();
        return false;
    });
    $('#bubble-toc a').click(function(e) {
        e.stopPropagation();
        return true;
    });
    
  // http://css-tricks.com/snippets/jquery/smooth-scrolling/
  function filterPath(string) {
  return string
    .replace(/^\//,'')
    .replace(/(index|default).[a-zA-Z]{3,4}$/,'')
    .replace(/\/$/,'');
  }
  var locationPath = filterPath(location.pathname);
  
  $('a[href*=#]').each(function() {
    $(this).click(function(event) {
    var thisPath = filterPath(this.pathname) || locationPath;
    if (  locationPath == thisPath
    && (location.hostname == this.hostname || !this.hostname)) {
      if ( this.hash.replace(/#/,'') ) {
      var $target = $(this.hash), target = this.hash;
      if ($target.length != 0) {
        var targetOffset = $target.offset().top;
          event.preventDefault();
          $('html').animate({scrollTop: targetOffset}, 400, function() {
            location.hash = target;
          });
      }
      }
      else {
          event.preventDefault();
          $('html').animate({scrollTop: 0}, 400);
      }
    }
   });	
  });
});

           var deactivatePosition = -1;
           
           function init() {
               if( window.addEventListener ) {
                   window.addEventListener("scroll", scrollDeactivator, false);
               }
               if ( document.getElementById('_share-print') ) {
                 document.getElementById('_share-print').style.display = 'block';
               }
               
               if ((document.URL.lastIndexOf('http', 0) === 0) || (document.URL.lastIndexOf('spdy', 0) === 0)) {
                     toggleClass('body', 'offline', 'online');
               }
               labelInputFind();
               return false;
            }
            
            function activate( elm ) {
                var element = elm;
                if ((element == '_toc-area') || (element == '_find-area') || (element == '_language-picker' || element == '_format-picker')) {
                    deactivate();
                    if ( document.getElementById(element) ) {
                      toggleClass( element , 'inactive', 'active' );
                      if ((element == '_find-area')) {
                          document.getElementById('_find-input').focus();
                      }
                      else if ((element == '_toc-area')) {
                          toggleClass( '_find-area', 'active', 'inactive' );
                      }
                      document.getElementById(element + '-button').onclick = function() {deactivate(); return false;};
                    }

                }
                else {
                    alert('Eek! The element '+ element +' can\'t be activated.');
                }
                deactivatePosition = currentYPosition();
            }


            function scrollDeactivator() {
                if (deactivatePosition != -1) {
                    var diffPosition = currentYPosition() - deactivatePosition;
                        if ((diffPosition < -300) || (diffPosition > 300)) {
                            deactivate();
                        }
                }
            }
            
            function deactivate() {
                var changeClass = new Array('_toc-area','_language-picker','_format-picker');
                
                for (var i = 0; i < changeClass.length; ++i) {
                    if ( document.getElementById( changeClass[i] ) ) {
                        toggleClass( changeClass[i] , 'active', 'inactive');
                    }
                }
                
                if ( document.getElementById('_toc-area-button') ) {
                    document.getElementById('_toc-area-button').onclick = function() {activate('_toc-area'); return false;};
                }
                if ( document.getElementById('_find-area-button') ) {
                    document.getElementById('_find-area-button').onclick = function() {activate('_find-area'); return false;};
                }
                if ( document.getElementById('_language-picker-button') ) {
                    document.getElementById('_language-picker-button').onclick = function() {activate('_language-picker'); return false;};
                }
                if ( document.getElementById('_format-picker-button') ) {
                    document.getElementById('_format-picker-button').onclick = function() {activate('_format-picker'); return false;};
                }

                if ( document.getElementById('_find-area') && document.getElementById('_find-area-button') ) {
                    toggleClass( '_find-area', 'inactive', 'active' );
                    document.getElementById('_find-area-button').onclick = function() {activate('_find-area'); return false;};
                }
                
                return false;
            }
            
            function share( service ) {
                u = encodeURIComponent( document.URL );
                t = encodeURIComponent( document.title );
                if ( service == 'fb' ) {
                    shareURL = 'http://www.facebook.com/sharer.php?u=' + u + '&amp;t=' + t;
                    window.open(shareURL,'sharer','toolbar=0,status=0,width=626,height=436');
                }
                else if ( service == 'tw' ) {
                    shareURL = 'http://twitter.com/share?text=' + t + '&amp;url=' + u;
                    window.open(shareURL, 'sharer', 'toolbar=0,status=0,width=340,height=360');
                }
                else if ( service == 'gp' ) {
                    shareURL = 'https://plus.google.com/share?url=' + u;
                    window.open(shareURL, 'sharer', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
                }
                
                else if ( service == 'mail' ) {
                    shareURL = 'https://www.suse.com/company/contact/sendemail.php?url=' + u;
                    window.open(shareURL, 'sharer', 'toolbar=0,status=0,width=535,height=650');
                }
                else {
                    alert('Eek! The sharing service '+ service +' is new to me.');
                }
                
            }
           
           function currentYPosition() {
               // Firefox, Chrome, Opera, Safari
               if (self.pageYOffset) return self.pageYOffset;
               // Internet Explorer 6 - standards mode
               if (document.documentElement && document.documentElement.scrollTop)
               return document.documentElement.scrollTop;
               // Internet Explorer 6, 7 and 8
               if (document.body.scrollTop) return document.body.scrollTop;
               return 0;
           }
            
            function unlabelInputFind() {
                if ( document.getElementById('_find-input-label') ) {
                    document.getElementById('_find-input-label').style.display = 'none';
                }
                return false;
            }
            
            function labelInputFind() {
                if ( document.getElementById('_find-input') && document.getElementById('_find-input-label') ) {
                    if (document.getElementById('_find-input').value == '') {
                        document.getElementById('_find-input-label').style.display = 'block';
                    }
                }
                return false;
            }
            
            function addClass(elm, cls) {
                var matchable = new RegExp ('(?:^|\\s)' + cls + '(?!\\S)', 'g');
                if ( elm == 'body') {
                    if ( !(document.body.className.match( matchable )) ) {
                        document.body.className += ' ' + cls;
                    }
                }
                if ( document.getElementById( elm ) ) {
                    if ( !(document.getElementById( elm ).className.match( matchable )) ) {
                        document.getElementById( elm ).className += ' ' + cls;
                    }
                }
            }
            
            function rmClass(elm, cls) {
                var replaceable = new RegExp ('(?:^|\\s)' + cls + '(?!\\S)', 'g');
                if ( elm == 'body') {
                    document.body.className = document.body.className.replace( replaceable , '' );
                }
                if ( document.getElementById( elm ) ) {
                    document.getElementById( elm ).className = document.getElementById( elm ).className.replace( replaceable , '' );
                }
            }
            
            function toggleClass(elm, clsOld, clsNew) {
                rmClass(elm, clsOld);
                addClass(elm, clsNew);
            }
