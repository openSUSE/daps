"""
Checks <meta name="..."> elements in a <info> element of a DocBook5 XML file.

Source: https://confluence.suse.com/x/aQDWNg
"""

import typing as t

from lxml import etree

from ..common import NAMESPACES
from ..exceptions import InvalidValueError
from ..logging import log


def check_meta_title(tree: etree._ElementTree, config: dict[t.Any, t.Any]):
    """Checks for a <meta name="title"> element"""
    root = tree.getroot()
    meta = root.find("./d:info/d:meta[@name='title']", namespaces=NAMESPACES)
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


def check_meta_description(tree: etree._ElementTree, config: dict[t.Any, t.Any]):
    """Checks for a <meta name="description"> element"""
    root = tree.getroot()
    meta = root.find("./d:info/d:meta[@name='description']", namespaces=NAMESPACES)
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


def check_meta_series(tree: etree._ElementTree, config: dict[t.Any, t.Any]):
    """Checks for a <meta name="series"> element"""
    root = tree.getroot()
    meta = root.find("./d:info/d:meta[@name='series']", namespaces=NAMESPACES)
    required = config.get("metadata", {}).get("required_meta_series", False)
    if meta is None:
        if required:
            raise InvalidValueError(
                f"Couldn't find required meta[@name='series'] element in {root.tag}."
            )
        return

    valid_series = [x.strip() for x in
                    config.get("metadata", {}).get("valid_meta_series", [])
                    if x]
    if meta.text.strip() not in valid_series:
        raise InvalidValueError(
            f"Meta series is invalid, got {meta.text.strip()!r}. "
            f"Valid series are {valid_series}."
        )


def check_meta_techpartner(tree: etree._ElementTree, config: dict[t.Any, t.Any]):
    """Checks for a <meta name="techpartner"> element"""
    root = tree.getroot()
    meta = root.find("./d:info/d:meta[@name='techpartner']",
                     namespaces=NAMESPACES)
    required = config.get("metadata", {}).get("require_meta_techpartner", False)
    if meta is None:
        if required:
            raise InvalidValueError(
                f"Couldn't find required meta[@name='techpartner'] element "
                f"in {root.tag}."
            )
        return

    # Do we have children?
    partners = [tag.text.strip() for tag in meta.iterchildren()]
    if not partners:
        raise InvalidValueError(
            f"Couldn't find any tech partners in meta[@name='techpartner'] element "
            f"(line {meta.sourceline})."
        )

    # Are they unique?
    if len(partners) != len(set(partners)):
        raise InvalidValueError(
            f"Duplicate tech partners found in meta[@name='techpartner'] element "
            f"(line {meta.sourceline})."
        )


def check_meta_platform(tree: etree._ElementTree, config: dict[t.Any, t.Any]):
    """Checks for a <meta name="platform"> element"""
    root = tree.getroot()
    meta = root.find("./d:info/d:meta[@name='platform']",
                     namespaces=NAMESPACES)
    required = config.get("metadata", {}).get("require_meta_platform", False)
    if meta is None:
        if required:
            raise InvalidValueError(
                f"Couldn't find required meta[@name='platform'] element "
                f"in {root.tag}."
            )
        return

    if meta.text is None or not meta.text.strip():
        raise InvalidValueError("Empty meta[@name='platform'] element")
