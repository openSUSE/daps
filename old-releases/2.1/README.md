# DAPS 2.1

Since we have been asked for webhelp support multiple time after having released 2.0 and implementing it took less time than expected, we proudly present ***DAPS 2.1 with webhelp support***. And while we were at it, we also did a few other changes...

## Download & Installation

[Download DAPS 2.1](https://github.com/openSUSE/daps/archive/2.1.tar.gz)
For download alternatives and installation instructions refer to https://github.com/openSUSE/daps/blob/master/INSTALL.adoc

## New Features

- added support for `webhelp`<br>
  Please note the following when using the DocBook webhelp
  stylsheets:
  * building with ROOTID should be avoided (does not generate
    sidebar)
  * building webhelp is slow; speed up by adjusting the chunk size<br>
    recommended parameters are<br>
    `chunk.fast 1` and `chunk.section.depth 0`
- added support for &lt;xi:include ... parse="text"&gt; (issue [#71])
- handling of passing XSLT parameters on the command line has been
  improved (issue [#263]), use
  * `--param "KEY=VALUE"` and `--stringparam "KEY=VALUE"`
  * each parameter can be specified multiple times
  * both parameters are supported for the following subcommands:
    epub, html, man, pdf, text, webhelp
  * changes only apply to the command-line - settings in the DC-file
    still need to be done with XSLTPARAM as before
  * use of `--xsltparam` still supported for compatibility reasons, but
    should be avoided; support will be removed in future versions

## Bugfixes and Enhancements

- improved handling of documents that do not need to be profiled
- daps_autobuild: changed the order of builds to increase performance
- bugfix package-src: removed extraneous text
- bugfix daps_autobuild: in case no rebuild was necessary, rsync deleted the previous results
- bugfix DB4 -> DB5 migration: Fixed various issues in the migration stylesheet

## Support

If you have got questions regarding DAPS, please use the discussion forum at https://sourceforge.net/p/daps/discussion/General/ . We will do our best to help.

## Bug Reports

To report bugs or file enhancement issues, use the issue Tracker at https://github.com/openSUSE/daps/issues .

## The DAPS Project

DAPS is developed by the SUSE Linux documentation team and used to
generate the product documentation for all SUSE Linux products.
However, it is not exclusively tailored for SUSE documentation, but
supports every documentation written in DocBook 4 and DocBook 5.
DAPS has been tested on Debian Wheezy, Fedora 20/21 openSUSE 13.x, SLE
12, and Ubuntu 14.10.
DAPS is hosted on [GitHub](https://opensuse.github.io/daps/).