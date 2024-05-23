import configparser
from pathlib import Path
import re
import tomllib
import typing as t

from .exceptions import MissingKeyError, MissingSectionError, NoConfigFilesFoundError
from .logging import log


def read_and_merge_toml_files(*paths: str) -> dict[t.Any, t.Any]:
    """Read and merge TOML files from given paths.

    :param paths:
    :return: the merged configuration as dictionary.
    """
    merged_config = {}
    for path in paths:
        full_path = Path(path).resolve()
        if full_path.exists():
            with open(full_path, mode='rb') as f:
                config = tomllib.load(f)
                # merged_config.update(config)
                merged_config |= config
    return merged_config


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



def validate_and_convert_config(config: configparser.ConfigParser):
    """Validate sections, keys, and their values of the config
    """
    split = re.compile(r"[;, ]")
    theconfig = as_dict(config)

    if not config.has_section("validator"):
        raise MissingSectionError("validator")

    # Validate "validator" section
    check_root_elements = config.get("validator", "check_root_elements", fallback=None)
    if check_root_elements is None:
        raise MissingKeyError("validator.check_root_elements")
    theconfig["validator"]["check_root_elements"] = split.split(check_root_elements)

    # Store the configfiles
    theconfig["configfiles"] = getattr(config, "configfiles")
    log.debug("The config: %s", theconfig)
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

