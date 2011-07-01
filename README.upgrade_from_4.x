----------------------------------------------------------------------------
              susedoc README for upgrades from version 4.x 
----------------------------------------------------------------------------

Adjusting existing projects:
----------------------------

In order to use susedoc 5.x the following adjustments are needed:

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
     export SUSEDOC_ENV_NAM=E$(basename $BASH_SOURCE)
     NOTE: this is optional

   * The following commands should change your ENV files accordingly
     (provided each command in the ENV-file is on a separate line)
   
     sed -r -i.bkp "/^\s*(\.|source) \s*\.env-profile\s*$/d;s/^\s*export //" ENV-mybook
     echo "export SUSEDOC_ENV_NAM=E$(basename \$BASH_SOURCE)" >> ENV-mybook

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

* SUSE dictionary:
  old: /usr/share/susedoc/aspell/suse_aspell.rws
  new: /usr/share/susedoc/lib/suse_aspell.rws

* emacs DocBook macros:
  old: /usr/share/susedoc/etc/emacs_docbook_macros.el
  new: /usr/share/emacs/site-lisp/docbook_macros.el

* documentation
  old: /usr/share/susedoc/doc/
  new: /usr/share/doc/packages/susedoc/

susedoc Command
----------------
Sourcing an ENV-file and calling make <TARGET> has been replaced by calling
"susedoc". PLease see "susedoc help" for extensive help.

For the impatient, here is a quickstart (<WD> = working directory containing
the ENV-file(s), an images/src/ and an xml/ directory)

   # <WD> only contains on ENV file:
   cd <WD>
   susedoc color-pdf

   # <WD> contains several ENV-files:
   cd <WD>
   susedoc --envfile=ENV-mybook color-pdf

   # calling susedoc from anywhere in the filesystem
   susedoc --envfile=ENV-mybook --basedir=<WD>

   # mybook has been build before
   cd <WD>/build/mybook
   susedoc color-pdf

   # compatibility mode allows to source an ENV-file (also see the below for
   # ENV-file changes)
   cd <WD>
   . ENV-mybook
   susedoc color-pdf

Resulting and temporary files:
------------------------------
By default susedoc will create a single directory named 'build' inside your <WD>
direcory. _Everything_ susedoc creates will go into this directory:

<WD>/build/mybook/
   All book and package builds (HTML, PDF, ePub, *.tar.bz2, etc.) can be
   found in this directory

<WD>/build/.profiled/
   Profiled XML sources will be copied to this directory

<WD>/build/.tmp/
   Temporary files will go here

<WD>/build/.images/
   All generated images will go here


If you prefer a complete separation of <WD> and susedoc output, specify the
option --builddir=<BUILDDIR> with susedoc. This will put all susedoc output to
'<BUILDDIR>' rather than '<WD>/build/'.

susedoc Verbosity:
------------------

By default susedoc is far less verbose than the make calls of version 4.x .
Most of the time you will only see the path to the resulting file. A complete
log file of the latest 'susedoc <SUBCOMMAND>' run is available in
<WD>/build/mybook/log/make_<SUBCOMMAND>.log.

In case of an error the complete log will be shown on STDOUT.

Using the '-v' switch for susedoc will produce the same level of output as
version 4.x.

Using the '-d' switch will produce even mor detailed debugging output.

By default susedoc generates colored output. Use the --color=0 switch to turn
off this behavior.

Configuration:
--------------
susedoc can be configured as follows:

* system wide config file: /etc/susedoc/config
  - includes all configuration parameters available 
  - sets sane defaults for each parameter
  - includes extensive documentation for each parameter

* user config file: ~/.susedoc/config
  - create this file if wanted; it is recommended to use a copy the system
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
    
    (refer to /etc/susedoc/config for documentation)


Bugs:
-----

* DocManager is currently not working and has been exluded from this package
  for the moment

* Documentation in /usr/share/doc/packages/susedoc/ is outdated
