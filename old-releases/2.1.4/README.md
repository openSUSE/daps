## Bugfixes
  - Target text shows remarks (issue [#293])
  - DAPS `checklink` doesn't work (issue [#296])
  - ASPELL_EXTRA_DICT from `~/.config/daps/dapsrc` is ignored (issue [#297])
  - DAPS package includes SUSE wordlist (issue [#298])
  - Parameter passed with `--param` is ignored with subcommand `text` (issue [#299])
  - Target `locdrop` does not generate `graphics-setfiles-$(DOCNAME)$(LANGSTRING).tar.bz2`
    (issue #302)
  - Translation check for `locdrop` (issue [#306])
  - Add `--optipng` to `unpack-locdrop` (issue [#307])
  - Add `--xmlonly`/`--imgonly` switches to `list-srcfiles` (issue [#310])
  - bigfile creates unresolved xrefs for DocBook5 (issue [#314])
  - Improve DocBook5 -> DocBook4 -> Novdoc Stylesheets (issue [#311])
  - Enhancements in user guide, thanks to Martin Koeditz (issue [#315])
  - FO contains wrong image paths when XML contains no profiling PI (issue [#316])
  - DB-4-to-5 migration: missing book titles/productnames/productnumbers
    (issue #319)

## New Features
  - Option `--schema` lets you specify an URN to a DocBook 5 schema that is to
    be used for validation. Will be ignored when validating Docbbok4 documents.
  - `DOCBOOK5_STYLE_URI`, `DOCBOOK5_STYLE_URI`, and `DOCBOOK4_STYLE_URI` may now
    also point to a local file. If the URN begins with the prefix "file://",
    it will not be resolved via xmlcatalog, but rather taken as is (minus
    "file://").
  - Add conversion options to online-docs:
    * `--db5todb4`: converts DocBook 5 sources to a DocBook 4 bigfile
    * `--db5todb4nh`: converts DocBook 5 sources to a DocBook 4 bigfile without
      a DOCTYPE declaration
    * `--dbtonovdoc`: converts DocBook 4/5 to Novdoc

## Misc
  - Do not set `-nocs`, hurts us when building Arabic (related: issue [#108])
  - Avoid adding version attribute on all elements (commit 3a273d5)

