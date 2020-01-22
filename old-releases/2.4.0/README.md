# DAPS 2.4.0

## New Features

- added a dependency checker for DAPS (`/usr/bin/daps-check-deps`) that makes it easy to check for missing programs/packages
- added a `--lean` parameter to PDF generation for creating PDFs with a reduced file size (by reducing the quality of included images); useful for sharing PDFs via e-mail
- added a stylesheet for returning all IDs from an XML file (`daps-xslt/common/get-all-xmlids.xsl`)

## Bugfixes

- issue 408: The `list-file-*` commands now work with ROOTIDs from all possible elements
- issue 390: When an ID appears twice in the XML and this ID is used with `--rootid`, DAPS's error message is unhelpful
- issue 365: Improved error messages on "File not found" errors (now tells whether the path was provided by command-line or config file)
- issue 371: Make path to the `xmlformat` config file configurable
- issue 372: Adjusted debian dependency list
- issue 373: Check `unpack-locdrop`
- issue 379: Output error of list-images-multisrc with pretty | wc option
- issue 380: Proper error messages when binaries/packages are missing
- issue 392: `daps-xmlformat` writes name of config file into output
- SVGs were not included in ePUBs (https://bugzilla.suse.com/show_bug.cgi?id=1006204)
- Setting a default value for db5_version in `configure.ac` otherwise the DB5 URN in etc/config will be set to an invalid value if DB5 is not installed when running make
- fixed a few minor issues with the config file parser that were introduced with 2.3.0 (among them issue 387)
- Increased Java stacksize for `jing`
- Improved the DocBook5 -> DocBook 4 (-> NovDoc) conversion
- compatibility: Debian's version of `which` does not support long parameters

## Documentation

- Various updates to reflect changes in the code
- issue 345: added documentatioon for the `xmlformat` subcommand
- issue 362: added documentation for the `--jobs` option
- issue 363: added documentation about building a bigfile from invalid sources
- issue 364: added documentation for the `--norefchecks` option
- issue 403: improved documentation about stylesheet customizing (also see issue 407)
- issue 404: clarify doc about listing unused images
- completely revised the doc (spelling, language and grammar)
- doc is not yet 100% on par with the code, but we are getting closer

## Compatibility

- successfully tested DAPS on Linux Mint 18.1
