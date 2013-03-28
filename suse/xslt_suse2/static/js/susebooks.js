/*  We use lots of .'s in our actual documentation's IDs. The following "helps"
    J-Query deal with this. Incidentally, it also breaks selectors like
    #id.class (unless the ID starts with an underscore).
   <http://stackoverflow.com/questions/5489869/is-there-a-plugin-that-makes-the-jquery-id-selector-dot-safe>
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

$(function() {

    /* http://css-tricks.com/snippets/jquery/smooth-scrolling/ */

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

    $(document).keyup(function(e) {
        if (e.keyCode == 27) { deactivate() }
    });

    // The other things.

    if( window.addEventListener ) {
        window.addEventListener('scroll', scrollDeactivator, false);
    }
    
    $('#_share-print').show();
    
    if (location.protocol.match(/^(http|spdy)/)) {
        $('body').removeClass('offline');
    }
    labelInputFind();
    
    $('#_toc-area-button').click(function(){activate('_toc-area'); return false;});
    $('#_fixed-header .single-crumb').unbind('click');
    $('#_fixed-header .single-crumb').click(function(){activate('_fixed-header-wrap'); return false;});
    $('#_header .single-crumb').unbind('click');
    $('#_header .single-crumb').click(function(){ moveToc('up'); return false;});
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

    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').unbind('click');
    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').append('<span class="arrow">&nbsp;</span>');
    $('#_bubble-toc ol > li').filter(':has(ol)').children('a').click(function(e) {
        exchClass('#_bubble-toc > ol > li', 'active', 'inactive');
        $(this).parent('li').removeClass('inactive');
        $(this).parent('li').addClass('active');
        e.stopPropagation();
        e.preventDefault();
        return false;
    });
    $('#_bubble-toc ol > li').not(':has(ol)').children('a').click(function(e) {
        deactivate();
    });
    $('#_bubble-toc > ol').not(':has(li > ol)').addClass('full-width');
    $('#_bubble-toc ol > li').not(':has(ol)').children('a').addClass('leads-to-page');
    $('#_bubble-toc ol > li').has('ol').children('a').append('<span class="arrow">&nbsp;</span>');
    $('#_bubble-toc ol ol').prepend('<li class="bubble-back"><a href="#"><span class="back-icon">&nbsp;</span></a></li>');
    $('.bubble-back').click(function(){exchClass('#_bubble-toc > ol > li', 'active', 'inactive'); return false;});
    $('#_pickers a.selected').append('<span class="tick">&nbsp;</span>');
    $('.bubble h6').append('<span class="bubble-closer">&nbsp;</span>');
    $('.bubble-closer').click(function(){deactivate(); return false;});

    if ( !( $('#_nav-area div').length ) ) {
        $('#_toolbar').addClass('only-toc');
    }
    else if ( !( $('#_toc-area div').length && $('#_nav-area div').length ) ) {
        $('#_toolbar').addClass('only-nav');
    }
});


function activate( elm ) {
    var element = elm;
    if (element == '_toc-area' || element == '_find-area' ||
        element == '_language-picker' || element == '_format-picker' ||
        element == '_fixed-header-wrap') {
        deactivate();
        exchClass( '#' + element , 'inactive', 'active' );
        if (element == '_fixed-header-wrap') {
            $('#_fixed-header .single-crumb').unbind('click');
            $('#_fixed-header .single-crumb').click(function(){deactivate(); return false;});
            exchClass( '#_find-area', 'active', 'inactive' );
            deactivatePosition = $('html').scrollTop();
        }
        else {
            if (element == '_find-area') {
                $('#_find-input').focus();
            }
            else if ((element == '_toc-area')) {
                exchClass( '#_find-area', 'active', 'inactive' );
                deactivatePosition = $('html').scrollTop();
                if ( $(window).width() < 450 ) {
                    $('body').css('overflow', 'hidden');
                    $('body').css('height', '100%');
                }
            }
            $('#' + element + '-button').unbind('click');
            $('#' + element + '-button').click(function(){deactivate(); return false;});
        }
    }
}

function moveToc ( direction ) {
    if (direction == 'up') {
        $('#_fixed-header-wrap > .bubble').detach().appendTo('#_toc-bubble-wrap');
        exchClass( '#_toc-bubble-wrap', 'inactive', 'active' );
        exchClass( '#_header .crumbs', 'inactive', 'active' );
        $('#_header .single-crumb').unbind('click');
        $('#_header .single-crumb').click(function(){ moveToc('down'); return false;});
        deactivatePosition = $('html').scrollTop();
        if ( $(window).width() < 450 ) {
            $('body').css('overflow', 'hidden');
            $('body').css('height', '100%');
        }
    }
    else if (direction == 'down') {
        $('#_toc-bubble-wrap > .bubble').detach().appendTo('#_fixed-header-wrap');
        exchClass( '#_toc-bubble-wrap', 'active', 'inactive' );
        exchClass( '#_header .crumbs', 'active', 'inactive' );
        $('#_header .single-crumb').unbind('click');
        $('#_header .single-crumb').click(function(){ moveToc('up'); return false;});
    }
    else
        alert('I don\'t want to move to the' + direction + '.');
}

function scrollDeactivator() {
    if (deactivatePosition != -1 && $(window).width() > 450 ) {
        var diffPosition = $('html').scrollTop() - deactivatePosition;
        if ((diffPosition < -300) || (diffPosition > 300)) {
            deactivate();
        }
    }
}

function deactivate() {
    deactivatePosition = -1;
    var changeClass = new Array('_toc-area','_language-picker','_format-picker');
    for (var i = 0; i < changeClass.length; ++i) {
            exchClass( '#' + changeClass[i] , 'active', 'inactive');
            $('#' + changeClass[i] + '-button').unbind('click');
    }
    moveToc( 'down' );
    $('#_fixed-header .single-crumb').unbind('click');
    exchClass('#_fixed-header-wrap', 'active', 'inactive');
    $('#_find-area-button').unbind('click');
    $('#_toc-area-button').click(function(){activate('_toc-area'); return false;});
    $('#_find-area-button').click(function(){activate('_find-area'); return false;});
    $('#_language-picker-button').click(function(){activate('_language-picker'); return false;});
    $('#_format-picker-button').click(function(){activate('_format-picker'); return false;});
    $('#_fixed-header .single-crumb').click(function(){activate('_fixed-header-wrap'); return false;});
    exchClass( '#_find-area', 'inactive', 'active' );
    $('body').css('overflow', 'auto');
    $('body').css('height', 'auto');
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
