# DAPS 2.0

After more than two years of development, 15 pre-releases and more than 2000 commits we proudly present release 2.0 of the DocBook Authoring and Publishing Suite, in short DAPS 2.0.

DAPS lets you publish your DocBook 4 or Docbook 5 XML sources in various output formats such as HTML, PDF, ePUB, man pages or ASCII with a single command. It is perfectly suited for large documentation projects by providing profiling support and packaging tools. DAPS supports authors by providing linkchecker, validator, spellchecker, and editor macros. DAPS exclusively runs on Linux.

## Download & Installation

For download and installation instructions refer to https://github.com/openSUSE/daps/blob/master/INSTALL.adoc

## Highlights of the DAPS 2.0 release include:

* fully supports DocBook 5 (production ready)
* daps_autobuild for automatically buildingand releasing  books from different sources
* support for ePUB 3 and Amazon .mobi format
* default HTML output is XHTML, also supports HTML5
* now supports XSLT processor saxon6 (in addition to xsltproc)
* improved "scriptability"
* properly handles css, javascript and images for HTML and ePUB builds
  (via a "static/" directory in the respective stylesheet folder)
* added support for JPG images
* supports all DocBook profiling attributes
* improved performance by only loading makefiles that are needed
  for the given subcommand
* added a comprehensive test suite to ensure better code quality when
  releasing
* tested on Debian Wheezy, Fedora 20/21 openSUSE 13.x, SLE
  12, and Ubuntu 14.10.

:exclamation:  Please note that this DAPS release does not support webhelp. It is planned to re-add webhelp support with DAPS 2.1. :exclamation:

For a complete Changelog refer to
https://github.com/openSUSE/daps/blob/master/ChangeLog

## Support

If you have got questions regarding DAPS, please use the discussion forum at https://sourceforge.net/p/daps/discussion/General/ . We will do our best to help.

## Bug Reports

To report bugs or file enhancement issues, use the issue Tracker at https://github.com/openSUSE/daps/issues .

## The DAPS Project

DAPS is developed by the SUSE Linux documentation team and used to
generate the product documentation for all SUSE Linux products.
However, it is not exclusively tailored for SUSE documentation, but
supports every documentation written in DocBook.
DAPS has been tested on Debian Wheezy, Fedora 20/21 openSUSE 13.x, SLE
12, and Ubuntu 14.10.

The DAPS project moved from SourceForge to GitHub and is now available
at https://opensuse.github.io/daps/


---------------------------------------------------------------------------------------------------------


## Updating from DAPS 1.1.x to DAPS 2.0

Large parts of DAPS have been rewritten for 2.0. Although we have tried
to be backwards compatible, there are a few changes you should be
aware of:

### Subcommands

* HTML:
  - `html-single` has been replaced by `html --single`
  - 'jsp` has been replaced with `html --jsp`
  - replaced support for HTML4 with support for HTML5 (--html5); xhtml remains the default, html4 is no longer supported
  - to nullify a CSS-file definition for HTML or EPUB (HTML_CSS or
    EPUB_CSS) from the DC-file, specify `--css none`
* PDF
  - `color-pdf` has been replaced by `pdf` (now produces color PDFs)
  - `pdf` has been replaced by `pdf --grayscale --cropmarks`
* file lists:
  - `projectfiles` and `projectgraphics` have been replaced with
    `list-srcfiles` (see daps help `list-srcfiles` for more options)
* General:
  - the number of subcommands has been significantly reduced, see `daps --commands`, `daps help` and `daps help <SUBCOMMAND>` for more information
  - all `dist-*` subcommands have been removed
  - when calling deprecated targets, an error message hinting at a valid alternative (if existing) is shown
* new subcommands
  - `clean-package` removes all generated package data for the given DC-file. Generated images and profiled sources will _not_ be deleted.
  - `dapsenv` shows a list of the most important make variables and their values
  - `images` generates images only for a given rootid. Intended for debugging purposes
  - `package-src` (creates a tarball with profiled XML sources and images); switch `--set-date` allows to specify a build date (default date is `now`)
  - `list-file` lists the filename that contains the ID specified with the mandatory paramater `--rootid`.
* subcommand bigfile now generates a bigfile for the given rootid (rather than for the complate set); subcommand `bigfile-reduced` has been dropped
* subbcommands `package-pdf` and `package-html` now have switches `--dcoumentfiles`, `--desktopfiles` and `--pagefiles` which generate the resource files for GNOME and KDE
 
### Config files

* the user config file has moved to $HOME/.config/daps/dapsrc. If a config file is detected in the previous location ($HOME/.daps/config) the user will be prompted to move the file
* New config file variables:
  - CONVERT_OPTS_JPG:  command-line options for ´convert´ for converting jpg images to grayscale
  - FOP_STACKSIZE: set the stacksize for fop
  - META, META_STR: permanently run html and PDF builds with `--meta`
  - STATIC_DIR: custom static directory location
  - TXT_USE_DBSTYLES:  if set to "yes" uses the default DocBook HTML stylesheets when generating text output; if set to "no" uses the HTML stylesheets specified with styleroot

### Verbosity

* ´-v0´ only shows the resulting filename; if no verbosity level is specified, this level is the default verbosity when the output device is _not_ a terminal (e.g. a pipe)
* ´-v1´ shows a result message plus filename; if no verbosity level is specified, this level is the default verbosity when the output device is a terminal
* ´-v2´ shows additional messages
* ´-v3´ shows the complete make output from ´make -j1´ (commands are executed successively, not parallel)
* ´--debug´ shows the complete make output from ´make -jx´ (commands are executed inparallel)

