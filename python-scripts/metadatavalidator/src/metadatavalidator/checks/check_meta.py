import typing as t

from lxml import etree

from ..common import DOCBOOK_NS
from ..exceptions import InvalidValueError
from ..logging import log


def check_meta_title(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """Checks for a <meta name="title"> element"""
    root = tree.getroot()
    meta = root.find(".//{%s}meta[@name='title']" % DOCBOOK_NS)
    required = config.get("metadata", {}).get("meta_title_required", False)
    if meta is None:
        if required:
            raise InvalidValueError(
                f"Couldn't find required meta[@name='title'] element in {root.tag}."
            )
        return

    length = config.get("metadata", {}).get("meta_title_length", 55)
    if len(meta.text) > length:
        raise InvalidValueError(f"Meta title is too long. Max length is {length} characters.")


def check_meta_description(tree: etree.ElementTree, config: dict[t.Any, t.Any]):
    """Checks for a <meta name="description"> element"""
    root = tree.getroot()
    meta = root.find(".//{%s}meta[@name='description']" % DOCBOOK_NS)
    required = config.get("metadata", {}).get("meta_description_required", False)
    if meta is None:
        if required:
            raise InvalidValueError(
                f"Couldn't find required meta[@name='description'] element in {root.tag}."
            )
        return

    length = config.get("metadata", {}).get("meta_description_length", 150)
    if len(meta.text) > length:
        raise InvalidValueError(f"Meta description is too long. Max length is {length} characters.")