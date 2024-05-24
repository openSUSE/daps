import typing as t

from lxml import etree

from ..common import DOCBOOK_NS
from ..exceptions import InvalidValueError
from ..logging import log


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