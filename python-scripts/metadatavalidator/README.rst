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

1. Command line with :option:`--config`. This doesn't search for other configuration files.
1. Environment variable :envar:`METAVALIDATOR_CONFIG`.
1. In the current directory: :file:`metadatavalidator.ini`
1. In the users' home directory: :file:`~/.config/metadatavalidator/config.ini`
1. In the system: :file:`/etc/metadatavalidator/config.ini`


Configuration values
--------------------

The configuration file is a standard INI file. The following values are
recognized:

* :var:`validator`: Global options to configure the validator.
    * :var:`file_extension`: The file extension to search for. Default is
      ``.xml``.

    * :var:`check_root_elements`: List of allowed root elements (space separated by local DocBook name). Default is ``article book topic``.

    * :var:`valid_languages`: List of valid languages (space separated by ISO 639-1 code). Default is ``ar-ar cs-cz de-de en-us es-es fr-fr hu-hu it-it ja-jp ko-kr nl-nl pl-pl pt-br ru-ru sv-se zh-cn zh-tw``.

* :var:`metadata`: Options to change behaviour of specific `<meta>` tags.
    * :var:`revhistory`: Requires a ``<revhistory>`` tag or not.

    * :var:`require_xmlid_on_revision`:  Requires a ``xml:id`` attribute on each ``<revision>`` tag or not.

    * :var:`require_meta_title`: Requires a ``<meta name="title">`` tag or not.

    * :var:`meta_title_length`: Checks the length of the text content in ``<meta name="title">``. Default is 55.

    * :var:`require_meta_description`: Requires a ``<meta name="description">`` tag or not.

    * :var:`meta_description_length`: Checks the length of the text content in ``<meta name="description">``. Default is 155.

    * :var:`require_meta_series`: Requires a ``<meta name="series">`` tag or not.

    * :var:`valid_meta_series`: Lists the valid series names for ``<meta name="series">``.
