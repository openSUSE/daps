## New Features:
  - parameters for text generation can be set in the config files
    via `TXT_PARAMS` or via `--param`/`--stringparam` on the command line
  - a change introduced in 2.0 made using the original DocBook
    stylesheets for text generation the default. Since this behavior
    is confusing and unexpected, it is reverted with this change:
    * the stylesheets configured via `STYLEROOT` or `--styleroot` are
      used by default for text generation
    * to ignore _any_ `STYLEROOT` definitions, set
      `TXT_IGNORE_STYLEROOT="yes"` in the config files or use
      `--ignore-styleroot` on the command line
      (`daps -d <DC> text --ignore-styleroot`)

## Bugfixes:
  - Fix for issue [#294]: xmlcatalog returns `file:<PATH>` rather than
    `file://<PATH>` on Debian Jessie and openSUSE Tumbleweed and
    caused DAPS to fail with DB5 sources

## Misc
  - added basic debugging output to test suite (`--debug`)