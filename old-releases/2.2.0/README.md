## New Features:
- new subcommand `xmlformat' prettyfies the XML sources of a given DC-file or ROOTID using daps-xmlformat with /etc/daps/docbook-xmlformat.conf. (Note: this command will modify the original XML sources!) 
- SVG image support for HTML builds. To use it, make sure to provide the images in SVG format and reference to them as follows:
```
<imageobject role="html">
 <imagedata fileref="SVG-FILE" format="SVG"/>
</imageobject>
```
- the new global switch `--jobs` lets you specify how many parallel jobs to use. The default is set to the number of CPU cores (as was done in previous versions).
- all commands generating file lists (e.g. `list-srcfiles`) now generate human readable output on STDOUT. When the output goes to a pipe or subshell, it will be generated as a a one-liner.
- Debugging of XML errors has been made easier. Sometimes the error message of the validator only points to an xi:include line, making it impossible to find the real location of the error. The option `--novalid` for the target `bigfile` will create the bigfile without performing a validation check on the sources. A single XML will be built and validated. Now the error message points to the exact location of the error in the bigfile. From there it should be easy to find the error in the original sources.
- Verbose and debugging output now also show all profiling attributes set in the DC-file, plus version information for the sytlesheets (if available)
- added the option `--norefchecks` to all output-generating targets (`html`, `pdf`, ...), `validate`, `bigfile` and others. Allows to build/validate documents without checking internal links (&lt;... linkend="ID">).
- subcommand `online-docs` now always converts the bigfile that is created to NovDoc. To keep the same format as the original sources, specify `--dbnoconv`. To create a DocBook4 bigfile from DocBook5 sources, specify `--db5todb4`.

## Bugfixes:
- 368: db4tonovdoc.xsl generates invalid NovDoc
- 367: daps does not validate fop output
- 366: Spellcheck trying to check the files "Cannot", "stat:", "No", "such", "file" ...
- 364: DocBook5: Allow validating without checking xrefs
- 363: Allow building a bigfile from invalid sources
- 362: Make the number of parallel jobs configurable
- 361: Externel xrefs are resolved to "????"
- 360: Check Rootid fails on Debian 8.4.0
- 356: file list output should default to pretty format
- 354: Validate the result of online docs when it has been converted from DB5 to DB4 or novdoc
- 353: Make db5 to db4 conversion default for online-docs
- 351, 348, 342, 282: Fixes for the daps spec-file
- 346: daps-xmlformat writes its messages into the output
- 343: daps-init warning messages
- 340: ePUB builds always show remarks
- 335: on Debian, make install creates incorrect group in /etc/xml/config
- 330: Enable SVG2Grayscale stylesheet to handle new color names
- 305: locdrop produces no "non-trans" image tarball for a complete set
- 301: SVG to PNG conversion creates very large PNGs
- 289: Verbose / Debugging Output Should Show Profiling Attributes
- 251: Write XSLT to Return xml-model PI
- 226: Let stylesheets know which version of DAPS calls them
- subcommand "clean-all" fails if run from within a directory that will be removed with that command
- daps fails when called from a directory that no longer exists

## Cross-Distribution Support
- first release with full Debian/Ubuntu support--manual adjustments after the installation are no longer needed (was required in previous releases for DocBook5 support). Many thanks to Tomáš Bažant and Christoph Berg for their help!
- GitHub checkouts now also work for Fedora/RedHat and Debian/Ubuntu--refer to https://github.com/openSUSE/daps/blob/develop/INSTALL.adoc for details
- tested on Debian 8.5.0 / Fedora 23 / openSUSE 13.2 and Leap 42.1 / SUSE Linux Enterprise 12 / Ubuntu 16.0 

## Misc:
- removed `daps-envconvert`, a script for converting susedoc ENV-files to DAPS DC-files. susedoc was the predecessor of DAPS. 

## Documentation:
- the documentation has _not_ been updated for this release, so new features mentioned above are not yet covered 
