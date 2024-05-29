import os.path
import typing as t


#: The configuration paths where to search for the config
CONFIGDIRS: t.Sequence = [
    # "Reserve" first place for environment variable 'METAVALIDATOR_CONFIG'
    # Search in the current directory:
    "metadatavalidator.ini",
    # In the users' home directory:
    "~/.config/metadatavalidator/config.ini",
    # In the system
    "/etc/metadatavalidator/config.ini"
    ]
METAVALIDATOR_CONFIG = os.environ.get('METAVALIDATOR_CONFIG')
if METAVALIDATOR_CONFIG is not None:
    CONFIGDIRS.insert(0, os.path.expanduser(METAVALIDATOR_CONFIG))

CONFIGDIRS = tuple(os.path.expanduser(i) for i in CONFIGDIRS)

DOCBOOK_NS = "http://docbook.org/ns/docbook"
XML_NS = "http://www.w3.org/XML/1998/namespace"
XLINK_NS = "http://www.w3.org/1999/xlink"
ITS_NS = "http://www.w3.org/2005/11/its"
XINCLUDE_NS = "http://www.w3.org/2001/XInclude"

NAMESPACES2PREFIX = {
    DOCBOOK_NS: "d",
    XML_NS: "xml",
    XLINK_NS: "xlink",
    ITS_NS: "its",
    XINCLUDE_NS: "xi",
}
