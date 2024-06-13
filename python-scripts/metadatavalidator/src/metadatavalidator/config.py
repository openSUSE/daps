import configparser
from pathlib import Path
import re
# import tomllib
import typing as t

from .exceptions import MissingKeyError, MissingSectionError, NoConfigFilesFoundError
from .logging import log


# def read_and_merge_toml_files(*paths: str) -> dict[t.Any, t.Any]:
#     """Read and merge TOML files from given paths.

#     :param paths:
#     :return: the merged configuration as dictionary.
#     """
#     merged_config = {}
#     for path in paths:
#         full_path = Path(path).resolve()
#         if full_path.exists():
#             with open(full_path, mode='rb') as f:
#                 config = tomllib.load(f)
#                 # merged_config.update(config)
#                 merged_config |= config
#     return merged_config


def as_dict(config: configparser.ConfigParser):
    """
    Converts a ConfigParser object into a dictionary.

    The resulting dictionary has sections as keys which point to a dict of the
    sections options as key => value pairs.
    """
    the_dict = {}
    for section in config.sections():
        the_dict[section] = {}
        for key, val in config.items(section):
            the_dict[section][key] = val
    return the_dict


def truefalse(value: str|bool|int) -> bool:
    """Convert a string to a boolean value
    """
    if isinstance(value, bool):
        return value

    return str(value).lower() in ("true", "yes", "1", "on")


def validate_and_convert_config(config: configparser.ConfigParser) -> dict[t.Any, t.Any]:
    """Validate sections, keys, and their values of the config

    :param config: the :class:`configparser.Configparser` object
    :return: a dict that contains converted keys into their
             respective datatypes
    """
    split = re.compile(r"[;, ]")
    theconfig = as_dict(config)

    if not config.has_section("validator"):
        raise MissingSectionError("validator")

    # Section "validator"
    check_root_elements = config.get("validator", "check_root_elements", fallback=None)
    if check_root_elements is None:
        raise MissingKeyError("validator.check_root_elements")
    theconfig["validator"]["check_root_elements"] = split.split(check_root_elements)

    valid_languages = config.get("validator", "valid_languages", fallback=None)
    if valid_languages is None:
        raise MissingKeyError("validator.valid_languages")

    theconfig["validator"]["valid_languages"] = split.split(valid_languages)

    # Section "metadata"
    require_xmlid_on_revision = truefalse(
        theconfig.get("metadata", {}).get("require_xmlid_on_revision", True)
    )
    theconfig.setdefault("metadata", {})["require_xmlid_on_revision"] = require_xmlid_on_revision

    try:
        meta_title_length = int(theconfig.get("metadata", {}).get("meta_title_length"))
        if meta_title_length < 0:
            raise ValueError("meta_title_length should be a positive integer")
        theconfig.setdefault("metadata", {})["meta_title_length"] = meta_title_length

    except TypeError:
        raise MissingKeyError("metadata.meta_title_length")

    try:
        meta_description_length = int(theconfig.get("metadata", {}).get("meta_description_length"))
        if meta_description_length < 0:
            raise ValueError("meta_description_length should be a positive integer")
        theconfig.setdefault("metadata", {})["meta_description_length"] = meta_description_length

    except TypeError:
        raise MissingKeyError("metadata.meta_description_length")

    split = re.compile(r"[;,]")  # no space!
    valid_meta_series = split.split(theconfig.get("metadata", {}).get("valid_meta_series", ""))
    theconfig.setdefault("metadata", {})["valid_meta_series"] = valid_meta_series

    require_meta_series = truefalse(
        theconfig.get("metadata", {}).get("require_meta_series", False)
    )
    theconfig.setdefault("metadata", {})["require_meta_series"] = require_meta_series

    # architectures
    require_meta_architecture = truefalse(
        theconfig.get("metadata", {}).get("require_meta_architecture", False)
    )
    theconfig.setdefault("metadata", {})["require_meta_architecture"] = require_meta_architecture
    try:
        architectures = split.split(theconfig.get("metadata", {}).get("valid_meta_architecture", []))
        theconfig.setdefault("metadata", {})["valid_meta_architecture"] = architectures
    except TypeError:
        raise MissingKeyError("metadata.valid_meta_architecture")


    # categories
    require_meta_category = truefalse(
        theconfig.get("metadata", {}).get("require_meta_category", False)
    )
    theconfig.setdefault("metadata", {})["require_meta_category"] = require_meta_category
    try:
        categories = split.split(theconfig.get("metadata", {}).get("valid_meta_category", []))
        theconfig.setdefault("metadata", {})["valid_meta_category"] = categories
    except TypeError:
        raise MissingKeyError("metadata.valid_meta_category")


    # Store the configfiles
    theconfig["configfiles"] = getattr(config, "configfiles")
    return theconfig


def readconfig(dirs: t.Sequence) -> dict[t.Any, t.Any]:  # configparser.ConfigParser
    """Read config data from config files

    :param dirs: the directories to search for config files
    :return: a :class:`configparser.ConfigParser` object
    """
    config = configparser.ConfigParser()
    configfiles = config.read(dirs)
    if not configfiles:
        raise NoConfigFilesFoundError("Config files not found")
    setattr(config, "configfiles", configfiles)

    return validate_and_convert_config(config)

