// Adapted from Adam Spiers's Tinkermonkey script

var XmlProduct = $( 'meta[name="product-name"]' ).attr( 'content' ) + ' ' + $( 'meta[name="product-number"]' ).attr( 'content' )
var bugzillaProduct = 0;
var bugzillaComponent = 'Documentation';


// XmlProduct comes from DocBook: <productname/> [space] <productnumber/>
// BugzillaProduct comes from Bugzilla, go to
// https://bugzilla.novell.com/enter_bug.cgi , search for the product,
// and write down the exact product name as given there. Click on the
// product name in Bugzilla, and find out what the component for documentation
// is called, that is your bugzillaComponent (default is "Documentation")

switch ( XmlProduct ) {
  case 'SUSE Cloud 2.0':
    bugzillaProduct = 'SUSE Cloud 2.0';
    break;
  case 'Subscription Management Tool 11.3':
    bugzillaProduct = 'Subscription Management Tool 11 SP3 (SMT 11 SP3)';
    bugzillaComponent = 'SMT';
    break;
  case 'SUSE Lifecycle Management Server 1.3':
    bugzillaProduct = 'SUSE Lifecycle Management Server';
    break;
  case 'SUSE Linux Enterprise Desktop 11 SP3':
    bugzillaProduct = 'SUSE Linux Enterprise Desktop 11 SP3';
    break;
  case 'SUSE Linux Enterprise Point of Service 11 SP2':
    bugzillaProduct = 'SUSE Linux Enterprise Point of Service 11 SP2 (SLEPOS 11 SP2)';
    break;
  case 'SUSE Linux Enterprise Server 11 SP3':
    bugzillaProduct = 'SUSE Linux Enterprise Server 11 SP3 (SLES 11 SP3)';
    break;
  case 'SUSE Linux Enterprise Server for SAP Applications 11 SP3':
    bugzillaProduct = 'SUSE Linux Enterprise for SAP Applications 11 SP3';
    bugzillaComponent = 'General';
    break;
  case 'SUSE Manager 1.7':
    bugzillaProduct = 'SUSE Manager 1.7 Server';
    break;
  case 'SUSE Studio Onsite 1.3':
    bugzillaProduct = 'SUSE Studio Onsite';
    break;
  case 'WebYaST 11':
    bugzillaProduct = 'WebYaST';
    bugzillaComponent = 'Documenation'; // sic!
    break;
}

// TODO: set severity to Normal somehow
var bugzillaURLprefix = 'https://bugzilla.novell.com/enter_bug.cgi?&product=' + encodeURIComponent(bugzillaProduct) + '&component=' + encodeURIComponent(bugzillaComponent);

$(function() {

  if ( !( bugzillaProduct == 0 ) ) {
    $('.permalink:not([href^=#idm])').each(function () {
        var permalink = this.href;
        if ( $(this).prevAll('span.number')[0] ) {
          var sectionNumber = $(this).prevAll('span.number')[0].innerHTML;
        }
        else {
          var sectionNumber = "";
        }
        var sectionName = $(this).prevAll('span.name')[0].innerHTML;
        var body = sectionNumber + " " + sectionName + "\n\n" + permalink;
        var URL = bugzillaURLprefix + "&short_desc=[doc]+&comment=" + encodeURIComponent(body);
        $(this).before("<a class=\"file-bug\" target=\"_blank\" href=\"" + URL + "\">File Bug</a> ");
    });
  }

});
