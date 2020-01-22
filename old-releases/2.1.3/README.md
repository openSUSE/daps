This release fixes some non-critical bugs and standardizes the way java program calls (fop, jing, xep) can be customized.

## Bugfixes

- Fix for issue [#284] (`spellcheck` / `getimages` use wrong filelist when called with `--debug`)
- Fix for issue [#283] (`spellcheck` fails with error on Language bug)
- `--param` and `--stringparam` were missing for the subcommands `package-pdf` and `package-html`
- all warning messages now go to STDERR, making it possible to always capture the output of a DAPS command on the shell with `FOO="$(daps...)`

## Miscellaneous

- added a wrapper for jing allwing to customize java flags, jars, and options
- standardized customising options for all java programs (fop, jing, xep)
