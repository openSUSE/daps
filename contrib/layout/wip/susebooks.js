                      var deactivatePosition = -1;
           
           function init() {
               if(window.addEventListener) {
                   window.addEventListener("scroll", scrollDeactivator, false);
               }
           }
            
           function show() {
                document.getElementById('_share-print').style.display = 'block';
                if ((document.URL.lastIndexOf('http', 0) === 0) || (document.URL.lastIndexOf('spdy', 0) === 0)) {
                    document.getElementById('_share-print').className = 'online';
                }
                return false;
            }
            
            function activate(element) {
                if ((element == '_toc-area') || (element == '_find-area') || (element == '_language-picker' || element == '_format-picker')) {
                    deactivate();
                    document.getElementById(element).className = 'active';
                    if ((element == '_find-area')) {
                        document.getElementById('_find-input').focus();
                    }
                    else if ((element == '_toc-area')) {
                        document.getElementById('_find-area').className = 'inactive';
                    }
                    document.getElementById(element + '-button').onclick = function() {deactivate(); return false;};
                }
                else {
                    alert('Eek! This element can\'t be activated.');
                }
                deactivatePosition = currentYPosition();
            }


            function scrollDeactivator() {
                if (deactivatePosition != -1) {
                    var diffPosition = currentYPosition() - deactivatePosition;
                        if ((diffPosition < -100) || (diffPosition > 100)) {
                            deactivate();
                        }
                }
            }
            
            function deactivate() {
                document.getElementById('_toc-area').className = 'inactive';
                document.getElementById('_find-area').className = 'active';
                document.getElementById('_language-picker').className = 'inactive';
                document.getElementById('_format-picker').className = 'inactive';
                document.getElementById('_toc-area-button').onclick = function() {activate('_toc-area'); return false;};
                document.getElementById('_find-area-button').onclick = function() {activate('_find-area'); return false;};
                document.getElementById('_language-picker-button').onclick = function() {activate('_language-picker'); return false;};
                document.getElementById('_format-picker-button').onclick = function() {activate('_format-picker'); return false;};
                return false;
            }
            
            function share(service) {
                u = encodeURIComponent(document.URL);
                t = encodeURIComponent(document.title);
                if (service == 'fb') {
                    shareURL = 'http://www.facebook.com/sharer.php?u=' + u + '&amp;t=' + t;
                    window.open(shareURL,'sharer','toolbar=0,status=0,width=626,height=436');
                }
                else if (service == 'tw') {
                    shareURL = 'http://twitter.com/share?text=' + t + '&amp;url=' + u;
                    window.open(shareURL, 'sharer', 'toolbar=0,status=0,width=340,height=360');
                }
                else if (service == 'gp') {
                    shareURL = 'https://plus.google.com/share?url=' + u;
                    window.open(shareURL, 'sharer', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
                }
                
                else if (service == 'mail') {
                    shareURL = 'https://www.suse.com/company/contact/sendemail.php?url=' + u;
                    window.open(shareURL, 'sharer', 'toolbar=0,status=0,width=535,height=650');
                }
                else {
                    alert('Eek! This sharing service must be new.');
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
                document.getElementById('_find-input-label').style.display = 'none';
                return false;
            }
            
            function labelInputFind() {
                if (document.getElementById('_find-input').value == '') {
                    document.getElementById('_find-input-label').style.display = 'block';
                }
                return false;
            }