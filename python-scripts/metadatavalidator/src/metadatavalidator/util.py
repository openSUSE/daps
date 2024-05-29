from datetime import datetime, date
from lxml import etree

from .common import (
    NAMESPACES2PREFIX,
    )


def getfullxpath(element: etree._Element,
                 ns2prefix:dict[str, str]=NAMESPACES2PREFIX) -> str:
    """Return the full XPath including predicates to this element

        :param: the element to get an XPath for
        :return: the full absolute XPath with optional predicates
    """
    tree = element.getroottree()
    root = tree.getroot()

    # Get the basic XPath from the root to the element
    # There are two different cases:
    # 1. Your element belongs to no namespace:
    #    get a regular XPath, no need to add anything
    # 2. Your element belongs to a namespace:
    #    proceed further
    path = tree.getpath(element)
    if "*" not in path:
        return path
    path = path.split("/")

    # Get the "full" XPath, but add the missing root element
    # Looks like ''{http://docbook.org/ns/docbook}info/{http://docbook.org/ns/docbook}revhistory'
    fullpath = "/{}/{}".format(
        etree.QName(root),
        tree.getelementpath(element)
    )
    # Remove some leftovers in case you have just "." from .getelementpath()
    fullpath = fullpath.replace("/.", "")

    # Replace a namespace with a prefix
    for ns, prefix in ns2prefix.items():
        fullpath = fullpath.replace(f'{{{ns}}}', f'{prefix}:')
    fullpath = fullpath.split("/")

    # Check if the two paths have the same length
    # if len(path) != len(fullpath):
    #    raise RuntimeError("two paths differ")

    # Combine element part and predicate
    return "/".join([f"{p2}{p1.replace('*', '')}"
                     for p1, p2 in zip(path, fullpath) ]
    )


def parse_date(date_text: str) -> date:
    """Attempt to parse a date string into a date object
    Valid formats are YYYY-MM-DD, YYYY-M-D, YYYY-MM, YYYY-M,
    YYYY-MM-D, and YYYY-M-D
    """
    # Attempt to parse the date text into a date object
    for fmt in ("%Y-%m-%d", "%Y-%m"):
        try:
            # This will handle all formats
            parsed_date = datetime.strptime(date_text, fmt)
            return parsed_date.date()
        except ValueError:
            continue

    # If none of the formats matched, raise an error
    raise ValueError(f"Invalid date format: {date_text}")