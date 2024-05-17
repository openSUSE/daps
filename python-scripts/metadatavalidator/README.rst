Metadata validator for DocBook
==============================

The script in this directory check several metadata definition for DocBook.
Metadata can be found in the ``<meta>`` and ``<info>`` tags.


Requirements
------------

* lxml (the more recent, the better)
* Python >=3.11 (only due to for installing with :file:`pyproject.toml`.)


Configuration
-------------

The configuration file is search in the following order (first is the highest):

1. Environment variable :envar:`METAVALIDATOR_CONFIG`.
1. In the current directory: :file:`metadatavalidator.ini`
1. In the users' home directory: :file:`~/.config/metadatavalidator/config.ini`
1. In the system: :file:`/etc/metadatavalidator/config.ini`


