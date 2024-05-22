import configparser
import typing as t

from .exceptions import NoConfigFilesFoundError



def readconfig(dirs: t.Sequence) -> configparser.ConfigParser:
    """Read config data from config files

    :param dirs: the directories to search for config files
    :return: a :class:`configparser.ConfigParser` object
    """
    config = configparser.ConfigParser()
    configfiles = config.read(dirs)
    if not configfiles:
        raise NoConfigFilesFoundError("Config files not found")
    setattr(config, "configfiles", configfiles)
    return config

