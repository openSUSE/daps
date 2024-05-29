import typing as t

from lxml import etree

from ..common import (
    DOCBOOK_NS,
    XML_NS,
    )
from ..exceptions import InvalidValueError, MissingAttributeWarning
from ..logging import log
from ..util import getfullxpath


def check_info(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """Checks for an info element"""
    root = tree.getroot()
    info = root.find(".//{%s}info" % DOCBOOK_NS)
    if info is None:
        raise InvalidValueError(f"Couldn't find info element in {root.tag}.")


def check_info_revhistory(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """Checks for an info/revhistory element"""
    info = tree.find("./d:info", namespaces={"d": DOCBOOK_NS})
    if info is None:
        # If <info> couldn't be found, we can't check <revhistory>
        return

    revhistory = info.find("./d:revhistory", namespaces={"d": DOCBOOK_NS})
    if revhistory is None:
        raise InvalidValueError(f"Couldn't find a revhistory element in {info.tag}.")

    xmlid = revhistory.attrib.get(f"{{{XML_NS}}}id")
    if xmlid is None:
        raise InvalidValueError(f"Couldn't find xml:id attribute in info/revhistory.")

    if not xmlid.startswith("rh"):
        raise InvalidValueError(f"xml:id attribute in info/revhistory should start with 'rh'.")



def check_info_revhistory_revision(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """Checks for an info/revhistory/revision element"""
    revhistory = tree.find("./d:info/d:revhistory", namespaces={"d": DOCBOOK_NS})
    if revhistory is None:
        # If <info> couldn't be found, we can't check <revhistory>
        return

    revision = revhistory.find("./d:revision", namespaces={"d": DOCBOOK_NS})
    if revision is None:
        raise InvalidValueError(f"Couldn't find a revision element in {revhistory.tag}.")
    xmlid = revision.attrib.get(f"{{{XML_NS}}}id")

    if config.get("metadata", {}).get("require_xmlid_on_revision", True) and xmlid is None:
        xpath = getfullxpath(revision)
        raise MissingAttributeWarning("")