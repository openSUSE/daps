----------------------------------------------------------------------------
             DocBook Authoring and Publishing Suite (DAPS)
                README for upgrading from susedoc 4.x 
----------------------------------------------------------------------------

Adjusting existing projects:
----------------------------

ENV files have been renamed to DC (Doc Config) files and have 
received some changes. For updating your ENV files, use the 
conversion script /usr/bin/daps-envconvert. View the available
options with --help.
     

Basic Directory Structure
--------------------------
The basic directory structure for DAPS is still the same 
as with susedoc: you need a working directory <WD> that contains
the DC-file(s), and the subdirectories images/src/ and xml/.   


Obsolete files/directories:
---------------------------

The following files/directories in <WD> may be deleted 
(recommended but not mandatory)

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

For the impatient, here is a quick start:

   # <WD> only contains one DC file:
   cd <WD>
   daps color-pdf

   # <WD> contains several DC files:
   cd <WD>
   daps --docconfig=DC-mybook color-pdf

   # calling daps from anywhere in the filesystem
   daps --docconfig=<PATH_TO_DC_FILE>/DC-mybook 

   # mybook has been build before
   cd <WD>/build/mybook
   daps color-pdf

   # compatibility mode (still allowing to source a DC file)
   cd <WD>
   . DC-mybook
   daps color-pdf

Resulting and temporary files:
------------------------------
By default, DAPS will create a single directory named 'build' inside your <WD>
direcory. _Everything_ DAPS creates will go into this directory:

<WD>/build/mybook/
   All book and package builds (HTML, PDF, ePub, *.tar.bz2, etc.) can be
   found in this directory

<WD>/build/.profiled/
   Profiled XML sources will be copied to this directory

<WD>/build/.tmp/
   Temporary files will go here

<WD>/build/.images/
   All generated images will go here


If you prefer a complete separation of <WD> and DAPS output, specify the
option --builddir=<BUILDDIR> with DAPS. This will put all DAPS output to
'<BUILDDIR>' rather than '<WD>/build/'.

DAPS Verbosity:
----------------

By default DAPS is far less verbose than the make calls of susedoc 4.x .
Most of the time you will only see the path to the resulting file. A complete
log file of the latest 'daps <SUBCOMMAND>' run is available in
<WD>/build/mybook/log/make_<SUBCOMMAND>.log.

In case of an error the complete log will be shown on STDOUT.

Using the '-v' switch for DAPS will produce the same level of output as
susedoc 4.x.

Using the '--debug' switch will produce even mor detailed debugging output.

By default DAPS generates colored output. Use the --color=0 switch to turn
off this behavior.

Configuration:
--------------
DAPS can be configured as follows:

* system wide config file: /etc/daps/config
  - includes all configuration parameters available 
  - sets sane defaults for each parameter
  - includes extensive documentation for each parameter

* user config file: ~/.daps/config
  - create this file if wanted; it is recommended to use a copy of the system
    config file

* book specific config: <WD>/DC-<bookname>
  - use this file to set the following book-specific parameters. 
    MAIN (mandatory)
    ROOTID 
    PROFOS 
    PROFARCH            
    
    (refer to /etc/daps/config for a complete list of parameters and 
     their description)
