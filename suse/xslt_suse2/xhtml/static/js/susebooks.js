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
            
            
            // Smooth scrolling thanks to Andrew Johnson
            
           
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
           
           function elmYPosition(element) {
               var elm = document.getElementById(element);
               var y = elm.offsetTop;
               var node = elm;
               while (node.offsetParent && node.offsetParent != document.body) {
               node = node.offsetParent;
               y += node.offsetTop;
               } return y;
           }
           
           function scroll(element) {
               var startY = currentYPosition();
               var stopY = elmYPosition(element);
               var distance = stopY > startY ? stopY - startY : startY - stopY;
               if (distance < 100) {
                   scrollTo(0, stopY);
               }
               else {
                   var speed = Math.round(distance / 100);
                   if (speed >= 20) speed = 20;
                   var step = Math.round(distance / 25);
                   var leapY = stopY > startY ? startY + step : startY - step;
                   var timer = 0;
                   if (stopY > startY) {
                       for ( var i=startY; i<stopY; i+=step ) {
                           setTimeout('window.scrollTo(0, '+leapY+')', timer * speed);
                           leapY += step; if (leapY > stopY) leapY = stopY; timer++;
                       }
                   }
                   else {
                       for ( var i=startY; i>stopY; i-=step ) {
                       setTimeout('window.scrollTo(0, '+leapY+')', timer * speed);
                       leapY -= step; if (leapY < stopY) leapY = stopY; timer++;
                       }
                   }
                }
                window.location.href = "#" + element;
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
