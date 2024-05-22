from lxml import etree

from ..common import DOCBOOK_NS
from ..exceptions import InvalidValueError
from ..logging import log


def check_root_tag(tree):
    """
    """
    tag = etree.QName(tree.getroot().tag)
    log.debug("Found tag <%s>", tag)
    if tag.localname not in ("topic"):
        raise InvalidValueError("Root tag is not ")


def check_namespace(tree):
    """Checks the namespace"""
    tag = etree.QName(tree.getroot().tag)
    log.debug("Found namespace %s", tag.namespace)
    if tag.namespace != DOCBOOK_NS:
        raise InvalidValueError("Root element doesn't belong to DocBook 5")
