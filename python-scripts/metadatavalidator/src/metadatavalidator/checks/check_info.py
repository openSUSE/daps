import datetime
import itertools
import typing as t

from lxml import etree

from ..common import (
    DATE_REGEX,
    DOCBOOK_NS,
    XML_NS,
)
from ..exceptions import InvalidValueError, MissingAttributeWarning
from ..logging import log
from ..util import (
    getfullxpath,
    validatedate,
    validatedatevalue
)


def check_info(tree: etree._ElementTree, config: dict[t.Any, t.Any]):
    """Checks for an info element"""
    root = tree.getroot()
    info = root.find(".//{%s}info" % DOCBOOK_NS)
    if info is None:
        raise InvalidValueError(f"Couldn't find info element in {root.tag}.")


def check_info_revhistory(tree: etree._ElementTree, config: dict[t.Any, t.Any]):
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



def check_info_revhistory_revision(tree: etree._ElementTree,
                                   config: dict[t.Any, t.Any]):
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
        xpath += "/@xml:id"
        raise MissingAttributeWarning(xpath)


def check_info_revhistory_revision_date(tree: etree._ElementTree,
                                        config: dict[t.Any, t.Any]):
    """Checks for an info/revhistory/revision/date element"""
    date = tree.find("./d:info/d:revhistory/d:revision/d:date",
                     namespaces={"d": DOCBOOK_NS})
    if date is None:
        raise InvalidValueError(f"Couldn't find a date element in info/revhistory/revision.")

    validatedate(date)


def check_info_revhistory_revision_order(tree: etree._ElementTree,
                                        config: dict[t.Any, t.Any]):
    """Checks for the right order of info/revhistory/revision elements"""
    revhistory = tree.find("./d:info/d:revhistory", namespaces={"d": DOCBOOK_NS})
    revisions = revhistory.xpath("d:revision",
                                  namespaces={"d": DOCBOOK_NS})
    xpath = getfullxpath(revhistory)
    if not revisions:
        return None

    date_elements = [rev.find("./d:date", namespaces={"d": DOCBOOK_NS})
                     for rev in revisions]
    dates = [
        validatedatevalue(d.text)
        for d in date_elements if d is not None
    ]
    converteddates: list[datetime.date] = [d for d in dates if d is not None]

    # First check: check if we have the same number of dates and revisions
    if len(date_elements) != len(revisions):
        raise InvalidValueError(f"Couldn't convert all dates. Check {xpath}")

    # Second check: we have the same number of dates and revisions, now
    # check if the dates are in descending order
    for first, second in itertools.pairwise(converteddates):
        if first <= second:
            raise InvalidValueError("Dates in revhistory/revision are not in descending order.")

