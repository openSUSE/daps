/*
JavaScript for SUSE documentation

Authors:
   Stefan Knorr, Thomas Schraitle, Adam Spiers

License: GPL 2+

(c) 2012-2019 SUSE LLC
*/

var active = false;
var deactivatePosition = -1;

var bugtrackerUrl = $( 'meta[name="tracker-url"]' ).attr('content');
var bugtrackerType = $( 'meta[name="tracker-type"]' ).attr('content');

// we handle Github (= gh) and bugzilla.suse.com (= bsc), default to bsc
if ((bugtrackerType != 'gh') && (bugtrackerType != 'bsc')) {
  bugtrackerType = 'bsc';
}

// For Bugzilla
var bscComponent = $( 'meta[name="tracker-bsc-component"]' ).attr('content');
if (!bscComponent) {
  bscComponent = 'Documentation'; // default component
}
var bscProduct = $( 'meta[name="tracker-bsc-product"]' ).attr('content');
var bscAssignee = $( 'meta[name="tracker-bsc-assignee"]' ).attr('content');
var bscVersion = $( 'meta[name="tracker-bsc-version"]' ).attr('content');
var bscTemplate = $( 'meta[name="tracker-bsc-template"]' ).attr('content');
// For GitHub
var ghAssignee = $( 'meta[name="tracker-gh-assignee"]' ).attr('content');
var ghLabels = $( 'meta[name="tracker-gh-labels"]' ).attr('content');
var ghMilestone = $( 'meta[name="tracker-gh-milestone"]' ).attr('content');
var ghTemplate = $( 'meta[name="tracker-gh-template"]' ).attr('content');


$(function() {
  /* http://css-tricks.com/snippets/jquery/smooth-scrolling/ */
  var speed = 400;

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

  $('._share-print').show();

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

  $('._share-fb').click(function(){share('fb');});
  $('._share-in').click(function(){share('in');});
  $('._share-tw').click(function(){share('tw');});
  $('._share-mail').click(function(){share('mail');});
  $('._print-button').click(function(){print();});

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
  $(".bubble").click(function(e) {e.stopPropagation();});
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

  addBugLinks();
  addClipboardButtons();
});


function addBugLinks() {
  // do not create links if there is no URL
  if ( typeof(bugtrackerUrl) == 'string') {
    $('.permalink:not([href^=#idm])').each(function () {
      var permalink = this.href;
      var sectionNumber = "";
      var sectionName = "";
      var url = "";
      if ( $(this).prevAll('span.number')[0] ) {
        sectionNumber = $(this).prevAll('span.number')[0].innerHTML;
      }
      if ( $(this).prevAll('span.number')[0] ) {
        sectionName = $(this).prevAll('span.name')[0].innerHTML;
      }

      if (bugtrackerType == 'bsc') {
        url = bugzillaUrl(sectionNumber, sectionName, permalink);
      }
      else {
        url = githubUrl(sectionNumber, sectionName, permalink);
      }

      $(this).before("<a class=\"report-bug\" target=\"_blank\" href=\""
        + url
        + "\" title=\"Report a bug against this section of the documentation\">Report Documentation Bug</a> ");
      return true;
    });
  }
  else {
    return false;
  }
}

function githubUrl(sectionNumber, sectionName, permalink) {
  var body = sectionNumber + " " + sectionName + ":\n\n" + permalink;
  if (ghTemplate) {
    if (ghTemplate.indexOf('@@source@@') !== -1) {
      body = ghTemplate.replace(/@@source@@/i, body);
    } else {
      body = body + '\n' + ghTemplate;
    };
  };
  var url = bugtrackerUrl
     + "?title=" + encodeURIComponent('[doc] ' + sectionNumber + ' ' + sectionName)
     + "&amp;body=" + encodeURIComponent(body);
  if (ghAssignee) {
    url += "&amp;assignee=" + encodeURIComponent(ghAssignee);
  }
  if (ghMilestone) {
    url += "&amp;milestone=" + encodeURIComponent(ghMilestone);
  }
  if (ghLabels) {
    url += "&amp;labels=" + encodeURIComponent(ghLabels);
  }
  return url;
}

function bugzillaUrl(sectionNumber, sectionName, permalink) {
  var body = sectionNumber + " " + sectionName + ":\n\n" + permalink;
  if (bscTemplate) {
    if (bscTemplate.indexOf('@@source@@') !== -1) {
      body = bscTemplate.replace(/@@source@@/i, body);
    } else {
      body = body + '\n' + bscTemplate;
    };
  };
  var url = bugtrackerUrl + "?&amp;product=" + encodeURIComponent(bscProduct)
    + '&amp;component=' + encodeURIComponent(bscComponent)
    + "&amp;short_desc=" + encodeURIComponent('[doc] ' + sectionNumber + ' ' + sectionName)
    + "&amp;comment=" + encodeURIComponent(body);
  if (bscAssignee) {
    url += "&amp;assigned_to=" + encodeURIComponent(bscAssignee);
  }
  if (bscVersion) {
    url += "&amp;version=" + encodeURIComponent(bscVersion);
  }
  return url;
}

function addClipboardButtons() {
  $( ".verbatim-wrap > pre" ).each(function () {
      var clipButton = $('<button/>', {
          class: 'clip-button',
          text: 'Copy code',
          click: function () {
            var elm = this.previousSibling;
            copyToClipboard(elm);
            elm.parentElement.classList.add("copy-success");
            setTimeout(function() {
              elm.parentElement.classList.remove("copy-success");
            }, 1000);
          }
        }
      );
      $(this).after(clipButton);
      return true;
    }
  );
}

function copyToClipboard(elm) {
  // use temporary hidden form element for selection and copy action
  var targetId = "__hiddenCopyText__";
  target = document.getElementById(targetId);
  if (!target) {
    var target = document.createElement("textarea");
    target.style.position = "fixed";
    target.style.left = "-9999px";
    target.style.top = "0";
    target.id = targetId;
    document.body.appendChild(target);
  } else {
    // empty out old content
    target.textContent = "";
  };
  $(elm).contents().each(function () {
      try {
        // we only want user-selectable elements, but not prompts.
        // (notably, if we have deeper nesting of inline elements, this
        // detection will fail but it should be good enough for common cases)
        if (getComputedStyle(this)['user-select'] != 'none') {
          target.textContent += this.textContent;
        };
      } catch(e) {
        // it's not an element node but a text node, so we always want it
        target.textContent += this.textContent;
      };
    }
  );
  // select the content
  var currentFocus = document.activeElement;
  target.focus();
  target.setSelectionRange(0, target.value.length);

  // copy the selection
  var succeed;
  try {
    succeed = document.execCommand("copy");
  } catch(e) {
    succeed = false;
  }
  // restore original focus
  if (currentFocus && typeof currentFocus.focus === "function") {
    currentFocus.focus();
  }

  return succeed;
}


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
  // helpful: https://github.com/bradvin/social-share-urls
  u = encodeURIComponent( document.URL );
  t = encodeURIComponent( document.title );
  shareSettings = 'menubar=0,toolbar=1,status=0,width=600,height=650';
  if ( service == 'fb' ) {
    shareURL = 'https://www.facebook.com/sharer.php?u=' + u + '&amp;t=' + t;
    window.open(shareURL,'sharer', shareSettings);
  }
    else if ( service == 'tw' ) {
    shareURL = 'https://twitter.com/share?text=' + t + '&amp;url=' + u + '&amp;hashtags=suse,docs';
    window.open(shareURL, 'sharer', shareSettings);
  }
    else if ( service == 'in' ) {
    shareURL = 'https://www.linkedin.com/shareArticle?mini=true&' + u + '&amp;title=' + t;
    window.open(shareURL, 'sharer', shareSettings);
  }
    else if ( service == 'mail' ) {
    shareURL = 'mailto:?subject=Check%20out%20the%20SUSE%20Documentation%2C%20%22' + t + '%22&body=' + u;
    window.location.assign(shareURL);
  };
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
