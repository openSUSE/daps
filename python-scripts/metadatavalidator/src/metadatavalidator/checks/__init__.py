from .check_root import (
    check_root_tag,
    check_namespace,
)
from .check_info import (
    check_info,
    check_info_revhistory,
    check_info_revhistory_xmlid,
)


# Keep the order. The next item is dependent on the previous item.
__all__ = [
    "check_root_tag",
    "check_namespace",
    "check_info",
    "check_info_revhistory",
    "check_info_revhistory_xmlid",
]

