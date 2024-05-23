import typing as t

from lxml import etree

from ..common import DOCBOOK_NS
from ..exceptions import InvalidValueError
from ..logging import log


def check_root_tag(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """
    """
    allowed_root_elements = config.get("validator", {}).get("check_root_elements")
    # log.debug("Found config: %s", allowed_root_elements)
    tag = etree.QName(tree.getroot().tag)
    # log.debug("Found tag <%s>", tag)
    if tag.localname not in allowed_root_elements:
        raise InvalidValueError("Root tag is not ")


def check_namespace(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """Checks the namespace"""
    tag = etree.QName(tree.getroot().tag)
    # log.debug("Found namespace %s", tag.namespace)
    if tag.namespace != DOCBOOK_NS:
        raise InvalidValueError("Root element doesn't belong to DocBook 5")
