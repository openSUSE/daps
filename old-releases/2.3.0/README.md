DAPS 2.3.0

## New Features:

- **Config File Parser:**
  Up to now, config files (DC-files, `/etc/daps/config` and  `~/.config/daps/dapsrc`) have been sourced. This has been a major security issue, since every shell code gets executed when a file is being sourced. DAPS 2.3.0 now comes with a parser that fixes this security hole. Apart from one exception (see below) existing config files do *not* need to be changed. However, the parser  offers more flexibility, see  https://github.com/openSUSE/daps/blob/develop/etc/config.in for documentation (the manuals has not been updated, yet).
  The only exception that requires changes in the config file is something like `FOO="$FOO bar"` To concatenate values, use "+="  now. See the following commit for an example:  https://github.com/openSUSE/daps/commit/7a2ce04
- **Bash Completion:**
  TAB-completion for DAPS has been one of the very first feature requests we opened (almost five years ago). Now we finally managed to conquer the black Bash magic required to get it!
- **Automatically detect the DocBook 5 version:**
  If you have DocBook 5.1 installed, docbookxi.rng from 5.1 will automatically be used as the validating schema for DocBook 5 documents. If you rather want to use the 5.0 schema or a custom schema, set DOCBOOK5_RNG_URI accordingly in `/etc/daps/config` (for a system wide configuration), in `$HOME/.config/daps/dapsrc` (for a user specific configuration), or in the DC-file (for a document-specific configuration)

## Bugfixes:

- subcommand `locdrop` failed when the book did not include images
- spellcheck now ignores text in `<replaceable>` tags
- obsolete `daps-susespell` has been removed (replaced by `daps ... spellcheck` long ago)
- paths starting with "~" were not always correctly resolved
- several fixes for ePUB, among them a fix that now correctly chooses mediaobject entries with role="html" rather than choosing the first one listed ion the XML source
- Issue 10 : Generate TAB completion
- Issue 359: Drop bash 3 support
- Issue 369: Code review: Check Variable Assignments
- Issue 375: Issues with the xmlformat target

