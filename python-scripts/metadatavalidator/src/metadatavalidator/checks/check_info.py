import typing as t

from lxml import etree

from ..common import DOCBOOK_NS
from ..exceptions import InvalidValueError
from ..logging import log


def check_info(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """Checks the info element"""
    root = tree.getroot()
    info = root.find(".//{%s}info" % DOCBOOK_NS)
    if info is None:
        raise InvalidValueError(f"Couldn't find info element in {root.tag}.")