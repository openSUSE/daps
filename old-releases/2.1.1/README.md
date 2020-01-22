This release contains a few bugfixes mainly for `webhelp` and `pdf`. We also added support for the profiling attribute `outputformat` that was introduced in DocBook 5.1.

## Bugfixes

- fix for issue [#274] (PDF Index Building Fails Because of Empty Profiling Directory)
- fix for issue [#275] (Avoid Same Target Names in Different Makefiles)
- fix for issue [#276] (PROFILE_URN Detection Depends on Position of PI in Document)
- fix for issue [#277] (Debugging Targets Fail when xml:lang is not set)
- fix for issue [#278] (Avoid Using "LANGUAGE" as a Variable Name)
- fix for issue [#280] (Webhelp: Common/ Directory Contains Dead Symbolic Links)

## New Features:

- added support for profiling attribute `outputformat` by intrducing `PROFOUTPUTFORMAT` (issue [#279])

## Miscellaneous:

 - replaced Chinese font "FZSongTi" with "wqy-microhei" in the default config file for XEP (`XEP_CONFIG_FILE=etc/xep/xep-daps.xml`)