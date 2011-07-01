----------------------------------------------------------------------------
             DocBook Authoring and Publishing Suite (daps)
                README for upgrading from susedoc 4.x 
----------------------------------------------------------------------------

Adjusting existing projects:
----------------------------

In order to use daps the following adjustments are needed:

ENV files:
..........   

   * remove the line that sources .env-profile
     Example:
       '. env-profile' gets deleted 
   * remove all export commands.
     Example:
       'export MAIN="MAIN-mybook.xml"' becomes 'MAIN="MAIN-mybook.xml"'
   * if you want to be able to still source ENV-files for compatibility
     reasons, add the following line to your ENV-file:
     export DAPS_ENV_NAME=E$(basename $BASH_SOURCE)
     NOTE: this is optional

   * The following commands should change your ENV files accordingly
     (provided each command in the ENV-file is on a separate line)
   
     sed -r -i.bkp "/^\s*(\.|source) \s*\.env-profile\s*$/d;s/^\s*export //" ENV-mybook
     echo "export DAPS_ENV_NAME=$(basename \$BASH_SOURCE)" >> ENV-mybook

Obsolete files/directories:
---------------------------

The following files/directories in <WD> may be deleted (recommended but not
mandatory)

  * obsolete files:
   - .env-profile
   - Makefile

  * obsolete directories (including any files within):
    - images/print/
    - images/online/
    - profiled/
    - tmp/
    
  * files that may have been created by susedoc (please doublecheck):
    - *.pdf
    - *.tar.bz2

  * direcories that may have been created by susedoc (please doublecheck):
    - diffs/
    - epub/
    - html/
    - txt/
    - wiki/
    - online-docs-*/
    - package-*/

Changed Paths:
--------------

* General:
  old: /usr/share/susedoc
  new: /usr/share/daps

* SUSE dictionary:
  old: /usr/share/susedoc/aspell/suse_aspell.rws
  new: /usr/share/daps/lib/suse_aspell.rws

* emacs DocBook macros:
  old: /usr/share/susedoc/etc/emacs_docbook_macros.el
  new: /usr/share/emacs/site-lisp/docbook_macros.el

* documentation
  old: /usr/share/susedoc/doc/
  new: /usr/share/doc/packages/daps/

daps Command
----------------
Sourcing an ENV-file and calling make <TARGET> has been replaced by calling
"daps". Please see "daps help" for extensive help.

For the impatient, here is a quickstart (<WD> = working directory containing
the ENV-file(s), an images/src/ and an xml/ directory)

   # <WD> only contains on ENV file:
   cd <WD>
   daps color-pdf

   # <WD> contains several ENV-files:
   cd <WD>
   daps --envfile=ENV-mybook color-pdf

   # calling daps from anywhere in the filesystem
   daps --envfile=ENV-mybook --basedir=<WD>

   # mybook has been build before
   cd <WD>/build/mybook
   daps color-pdf

   # compatibility mode allows to source an ENV-file (also see the below for
   # ENV-file changes)
   cd <WD>
   . ENV-mybook
   daps color-pdf

Resulting and temporary files:
------------------------------
By default daps will create a single directory named 'build' inside your <WD>
direcory. _Everything_ daps creates will go into this directory:

<WD>/build/mybook/
   All book and package builds (HTML, PDF, ePub, *.tar.bz2, etc.) can be
   found in this directory

<WD>/build/.profiled/
   Profiled XML sources will be copied to this directory

<WD>/build/.tmp/
   Temporary files will go here

<WD>/build/.images/
   All generated images will go here


If you prefer a complete separation of <WD> and daps' output, specify the
option --builddir=<BUILDDIR> with daps. This will put all daps output to
'<BUILDDIR>' rather than '<WD>/build/'.

daps Verbosity:
------------------

By default daps is far less verbose than the make calls of susedoc 4.x .
Most of the time you will only see the path to the resulting file. A complete
log file of the latest 'daps <SUBCOMMAND>' run is available in
<WD>/build/mybook/log/make_<SUBCOMMAND>.log.

In case of an error the complete log will be shown on STDOUT.

Using the '-v' switch for daps will produce the same level of output as
susedoc 4.x.

Using the '-d' switch will produce even mor detailed debugging output.

By default daps generates colored output. Use the --color=0 switch to turn
off this behavior.

Configuration:
--------------
daps can be configured as follows:

* system wide config file: /etc/daps/config
  - includes all configuration parameters available 
  - sets sane defaults for each parameter
  - includes extensive documentation for each parameter

* user config file: ~/.daps/config
  - create this file if wanted; it is recommended to use a copy of the system
    config file

* book specific config: <WD>/ENV-<bookname>
  - use this file to set the following book-specific parameters. The only
    manadatory parameter is MAIN
    MAIN
    ROOTID
    PROFOS
    PROFARCH
    DISTVER
    PRODUCTNAME
    PRODUCTNAMEREG
    COMMENTS (recommendation: set this value on the command line)
    DRAFT (recommendation: set this value on the command line)
    REMARKS (recommendation: set this value on the command line)       
    
    (refer to /etc/daps/config for documentation)
