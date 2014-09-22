var active = false;
var deactivatePosition = -1;

// Parts of the bug reporter, (c) Adam Spiers
var XmlProduct = $( 'meta[name="product-name"]' ).attr( 'content' ) + ' ' + $( 'meta[name="product-number"]' ).attr( 'content' )
var bugzillaProduct = 0;
var bugzillaComponent = 'Documentation';

// XmlProduct comes from DocBook: <productname/> [space] <productnumber/>
// BugzillaProduct comes from Bugzilla, go to
// https://bugzilla.suse.com/enter_bug.cgi , search for the product,
// and write down the exact product name as given there. Click on the
// product name in Bugzilla, and find out what the component for documentation
// is called, that is your bugzillaComponent (default is "Documentation")


switch ( XmlProduct ) {
  case 'SUSE Cloud 2.0':
    bugzillaProduct = 'SUSE Cloud 2.0';
    break;
  case 'SUSE Cloud 3':
    bugzillaProduct = 'SUSE Cloud 3';
    break;
  case 'Subscription Management Tool 11.3':
    bugzillaProduct = 'Subscription Management Tool 11 SP3 (SMT 11 SP3)';
    bugzillaComponent = 'SMT';
    break;
  case 'SUSE Lifecycle Management Server 1.3':
    bugzillaProduct = 'SUSE Lifecycle Management Server';
    break;
  case 'SUSE Linux Enterprise Desktop 12':
    bugzillaProduct = 'SUSE Linux Enterprise Desktop 12';
    break;
  case 'SUSE Linux Enterprise Desktop 11 SP3':
    bugzillaProduct = 'SUSE Linux Enterprise Desktop 11 SP3';
    break;
  case 'SUSE Linux Enterprise Point of Service 11 SP2':
    bugzillaProduct = 'SUSE Linux Enterprise Point of Service 11 SP2 (SLEPOS 11 SP2)';
    break;
  case 'SUSE Linux Enterprise Server 12':
    bugzillaProduct = 'SUSE Linux Enterprise Server 12 (SLES 12)';
    break;
  case 'SUSE Linux Enterprise Server 11 SP3':
    bugzillaProduct = 'SUSE Linux Enterprise Server 11 SP3 (SLES 11 SP3)';
    break;
  case 'SUSE Linux Enterprise Server for SAP Applications 11 SP3':
    bugzillaProduct = 'SUSE Linux Enterprise for SAP Applications 11 SP3';
    bugzillaComponent = 'General';
    break;
//for NFS Quick Start, productnumber is 11 instead on 11 SP3 (PM's wish)
  case 'SUSE Linux Enterprise High Availability Extension 11':
    bugzillaProduct = 'SUSE Linux Enterprise High Availability Extension 11 SP3';
    break;
  case 'SUSE Linux Enterprise High Availability Extension 11 SP3':
    bugzillaProduct = 'SUSE Linux Enterprise High Availability Extension 11 SP3';
    break;
  case 'SUSE Linux Enterprise High Availability Extension 12':
    bugzillaProduct = 'SUSE Linux Enterprise High Availability Extension 12';
    break;
  case 'GEO Clustering for SUSE Linux Enterprise High Availability Extension 12':
    bugzillaProduct = 'SUSE Linux Enterprise High Availability Extension 12';
    break;
  case 'SUSE Manager 1.7':
    bugzillaProduct = 'SUSE Manager 1.7 Server';
    break;
  case 'SUSE Manager 2.1':
    bugzillaProduct = 'SUSE Manager 2.1 Server';
    break;
  case 'SUSE Studio Onsite 1.3':
    bugzillaProduct = 'SUSE Studio Onsite';
    break;
  case 'WebYaST 11':
    bugzillaProduct = 'WebYaST';
    bugzillaComponent = 'Documenation'; // sic!
    break;
}

var bugzillaURLprefix = 'https://bugzilla.suse.com/enter_bug.cgi?&product=' + encodeURIComponent(bugzillaProduct) + '&component=' + encodeURIComponent(bugzillaComponent);


$(function() {

  /* http://css-tricks.com/snippets/jquery/smooth-scrolling/ */
  var speed = 400;

  $('a[href*=#]:not([href=#])').click(function() {
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'')
     || location.hostname == this.hostname) {
      var target = $(this.hash.replace( /(:|\.|\[|\])/g, "\\$1" ));
      var targethash = this.hash;
      target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
      if (target.length) {
        $('html,body').animate({
          scrollTop: target.offset().top
        }, speed, function() { location.hash = targethash; });
        return false;
      }
    }
  });
  $('a.top-button[href=#]').click(function() {
    $('html,body').animate({ scrollTop: 0 }, speed,
      function() { location = location.pathname + '#'; });
    return false;
  });


  $('body').removeClass('js-off');
  $('body').addClass('js-on');

  $(document).keyup(function(e) {
    if (e.keyCode == 27) { deactivate() }
  });

  if( window.addEventListener ) {
    window.addEventListener('scroll', scrollDeactivator, false);
  }

  hashActivator();
  window.onhashchange = hashActivator;

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
  $('html').click(function(e){deactivate(); e.stopPropagation();});
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
  $('#_bubble-toc ol > li').not(':has(ol)').children('a').click(function(e) {
    exchClass('#_bubble-toc > ol > li', 'active', 'inactive');
  });
  $('#_bubble-toc ol > li').has('ol').children('a').append('<span class="arrow">&nbsp;</span>');
  $('#_bubble-toc ol ol').prepend('<li class="bubble-back"><a href="#"><span class="back-icon">&nbsp;</span></a></li>');
  $('.bubble-back').click(function(){exchClass('#_bubble-toc > ol > li', 'active', 'inactive'); return false;});
  $('#_pickers a.selected').append('<span class="tick">&nbsp;</span>');
  $('.bubble h6').append('<span class="bubble-closer">&nbsp;</span>');
  $('.bubble-closer').click(function(){deactivate(); return false;});
  $('.question').click(function(){ $(this).parent('dl').toggleClass('active'); });
  $('.table tr').has('td[rowspan]').addClass('contains-rowspan');
  $('.informaltable tr').has('td[rowspan]').addClass('contains-rowspan');

  if ( !( $('#_nav-area div').length ) ) {
    $('#_toolbar').addClass('only-toc');
  }
  else if ( !( $('#_toc-area div').length && $('#_nav-area div').length ) ) {
    $('#_toolbar').addClass('only-nav');
  }

  if ( bugzillaProduct != 0 ) {
    $('.permalink:not([href^=#idm])').each(function () {
        var permalink = this.href;
        var sectionNumber = "";
        var sectionName = "";
        if ( $(this).prevAll('span.number')[0] ) {
          sectionNumber = $(this).prevAll('span.number')[0].innerHTML;
        }
        if ( $(this).prevAll('span.number')[0] ) {
          var sectionName = $(this).prevAll('span.name')[0].innerHTML;
        }
        var body = sectionNumber + " " + sectionName + "\n\n" + permalink;
        var URL = bugzillaURLprefix + "&short_desc=[doc]+&comment=" + encodeURIComponent(body);
        $(this).before("<a class=\"report-bug\" target=\"_blank\" href=\"" + URL + "\" title=\"Report a bug against this section\">Report Bug</a> ");
    });
  }

});


function activate( elm ) {
  var element = elm;
  if (element == '_toc-area' || element == '_find-area' ||
    element == '_language-picker' || element == '_format-picker' ||
    element == '_fixed-header-wrap') {
    deactivate();
    active = true;
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
    active = true;
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
    active = true;
    $('#_toc-bubble-wrap > .bubble').detach().appendTo('#_fixed-header-wrap');
    exchClass( '#_toc-bubble-wrap', 'active', 'inactive' );
    exchClass( '#_header .crumbs', 'active', 'inactive' );
    $('#_header .single-crumb').unbind('click');
    $('#_header .single-crumb').click(function(){ moveToc('up'); return false;});
  }
}

function scrollDeactivator() {
  if (deactivatePosition != -1 && $(window).width() > 450 ) {
    var diffPosition = $('html').scrollTop() - deactivatePosition;
    if ((diffPosition < -300) || (diffPosition > 300)) {
      deactivate();
    }
  }
}

function hashActivator() {
  if ( location.hash.length ) {
    var locationhash = location.hash.replace( /(:|\.|\[|\])/g, "\\$1" );
    if ( $( locationhash ).is(".free-id") ) {
      $( locationhash ).next(".qandaentry").addClass('active');
    };
    if ( $( locationhash ).is(".question") ) {
      location.hash = $( locationhash ).parent(".qandaentry").prev('.free-id').attr('id');
    };
  };
}

function deactivate() {
  if (active == true) {
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
    active = false;
  }
}

function share( service ) {
  u = encodeURIComponent( document.URL );
  t = encodeURIComponent( document.title );
  if ( service == 'fb' ) {
    shareURL = 'https://www.facebook.com/sharer.php?u=' + u + '&amp;t=' + t;
    window.open(shareURL,'sharer','toolbar=0,status=0,width=626,height=436');
  }
    else if ( service == 'tw' ) {
    shareURL = 'https://twitter.com/share?text=' + t + '&amp;url=' + u;
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
