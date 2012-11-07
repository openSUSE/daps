/* http://stackoverflow.com/questions/5489869/is-there-a-plugin-that-makes-the-jquery-id-selector-dot-safe
   We use lots of .'s in our IDs. The following "helps". Note that you can't use
   selectors like #id.class any more, unless the ID starts with an underscore.
*/

(function($){
 $.fn._init = $.fn.init;
 $.fn.init = function ( selector, context, rootjQuery ) {
  if (typeof selector == 'string' && /^#(?!_)/.test(selector)
      && /\./.test(selector)) {
       var construct= '#';
       selector = selector.replace(/\#/, '');
       var parts = selector.match(/\./g).length + 1;
       for (var i=0; i < parts; ++i) {
           construct += selector.match(/[^\s\.]*/);
           if (i < parts-1) { construct += '\\.'; }
           selector = selector.replace(/[^\s\.\\]*\./, '');
       }
       selector = construct;
   }
  return new $.fn._init(selector,context,rootjQuery);
}
})(jQuery);



var deactivatePosition = -1;

$(document).ready(function() {
    if( window.addEventListener ) {
        window.addEventListener('scroll', scrollDeactivator, false);
    }
    
    $('#_share-print').show;
    
    if (location.protocol.match(/^(http|spdy)/)) {
        $('body').removeClass('offline');
    }
    labelInputFind();
    
    $('#_toc-area-button').click(function(){activate('_toc-area'); return false;});
    $('#_find-area-button').click(function(){activate('_toc-area'); return false;});
    $('#_format-picker-button').click(function(){activate('_format-picker'); return false;});
    $('#_language-picker-button').click(function(){activate('_language-picker'); return false;});
    $('#_content').click(function(){deactivate(); return true;});
    $('#_find-input').focus(function(){unlabelInputFind();});
    $('#_find-input').blur(function(){labelInputFind();});
    $('#_find-input-label').click(function(){$('#_find-input').focus();});
    
    $('#_share-fb').click(function(){share('fb');});
    $('#_share-gp').click(function(){share('gp');});
    $('#_share-tw').click(function(){share('tw');});
    $('#_share-mail').click(function(){share('mail');});
    $('#_print-button').click(function(){print();});


    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').append('<span class="arrow">&nbsp;</span>');
    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').click(function(e) {
        exchClass('#_bubble-toc > ol > li', 'active', 'inactive');
        $(this).parent('li').removeClass('inactive');
        $(this).parent('li').addClass('active');
        e.preventDefault();
        return false;
    });
    $('#bubble-toc a').click(function(e) {
        e.stopPropagation();
        return true;
    });
    $('#_bubble-toc ol > li').filter(':not(:has(ol))').children('a').addClass('leads-to-page');
    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').append('<span class="arrow">&nbsp;</span>');
    $('#_pickers a.selected').append('<span class="tick">&nbsp;</span>');
    
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
          $('html').animate({scrollTop: 0}, 400, function() {
             location = location.pathname + '#';
          });
      }
    }
   });	
  });
});

function activate( elm ) {
    var element = elm;
    if ((element == '_toc-area') || (element == '_find-area') || (element == '_language-picker' || element == '_format-picker')) {
        deactivate();
        if ( document.getElementById(element) ) {
            exchClass( '#' + element , 'inactive', 'active' );
            if ((element == '_find-area')) {
                $('#_find-input').focus();
            }
            else if ((element == '_toc-area')) {
                exchClass( '#_find-area', 'active', 'inactive' );
                deactivatePosition = $('html').scrollTop();
            }
            $('#' + element + '-button').unbind('click');
            $('#' + element + '-button').click(function(){deactivate(); return false;});
        }
    }
}

function scrollDeactivator() {
    if (deactivatePosition != -1) {
        var diffPosition = $('html').scrollTop() - deactivatePosition;
        if ((diffPosition < -300) || (diffPosition > 300)) {
            deactivate();
        }
    }
}
            
function deactivate() {
    var changeClass = new Array('_toc-area','_language-picker','_format-picker');
    for (var i = 0; i < changeClass.length; ++i) {
            exchClass( '#' + changeClass[i] , 'active', 'inactive');
            $('#' + changeClass[i] + '-button').unbind('click');
    }
    $('#_find-area-button').unbind('click');
    $('#_toc-area-button').click(function(){activate('_toc-area'); return false;});
    $('#_find-area-button').click(function(){activate('_find-area'); return false;});
    $('#_language-picker-button').click(function(){activate('_language-picker'); return false;});
    $('#_format-picker-button').click(function(){activate('_format-picker'); return false;});
    exchClass( '#_find-area', 'inactive', 'active' );
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
            
function unlabelInputFind() {
    $('#_find-input-label').hide();
}

function labelInputFind() {
    if ( !($('#_find-input').val()) ) {
        $('#_find-input-label').show();
    }
}
            
function exchClass(path, clsOld, clsNew) {
    $(path).addClass(clsNew);
    $(path).removeClass(clsOld);
}