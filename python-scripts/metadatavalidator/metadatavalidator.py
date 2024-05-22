#!/usr/bin/python3
"""

"""

import argparse
import configparser
import logging
from logging.config import dictConfig
import os.path
import sys
import typing as t

try:
    from lxml import etree

except ImportError:
    print("Cannot import lxml. ", file=sys.stderr)
    sys.exit(10)

__version__ = "0.2.0"
__author__ = "Tom Schraitle <toms@suse.de>"

#: The logger name; can also set to "__name__"
LOGGERNAME = "metadata"

#: The configuration paths where to search for the config
CONFIGDIRS: t.Sequence = [
    # "Reserve" first place for environment variable 'METAVALIDATOR_CONFIG'
    # Search in the current directory:
    "metadatavalidator.ini",
    # In the users' home directory:
    "~/.config/metadatavalidator/config.ini",
    # In the system
    "/etc/metadatavalidator/config.ini"
    ]
METAVALIDATOR_CONFIG = os.environ.get('METAVALIDATOR_CONFIG')
if METAVALIDATOR_CONFIG is not None:
    CONFIGDIRS.insert(0, os.path.expanduser(METAVALIDATOR_CONFIG))

CONFIGDIRS = tuple(os.path.expanduser(i) for i in CONFIGDIRS)

#: The dictionary, passed to :class:`logging.config.dictConfig`,
#: is used to setup your logging formatters, handlers, and loggers
#: For details, see https://docs.python.org/3.4/library/logging.config.html#configuration-dictionary-schema
DEFAULT_LOGGING_DICT = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'standard': {'format': '[%(levelname)s] %(funcName)s: %(message)s'},
    },
    'handlers': {
        'console': {
            'level': 'DEBUG', # will be set later
            'formatter': 'standard',
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        LOGGERNAME: {
            'handlers': ['console',],
            'level': 'DEBUG',
            'propagate': False,
        },
        # Set the root logger's log level:
        'root': {
            'level': 'WARNING',
            'handlers': ["console"],
        }
    }
}


#: Map verbosity level (int) to log level
LOGLEVELS = {None: logging.WARNING,  # 0
             0: logging.WARNING,
             1: logging.INFO,
             2: logging.DEBUG,
             }


#: Change root logger level from WARNING (default) to NOTSET
#: in order for all messages to be delegated.
logging.getLogger().setLevel(logging.NOTSET)

#: Instantiate our logger
log = logging.getLogger(LOGGERNAME)


#----------------
class NoConfigFilesFoundError(FileNotFoundError):
    pass


def parsecli(cliargs=None) -> argparse.Namespace:
    """Parse CLI with :class:`argparse.ArgumentParser` and return parsed result
    :param cliargs: Arguments to parse or None (=use sys.argv)
    :return: parsed CLI result
    """
    parser = argparse.ArgumentParser(description=__doc__,
                                     epilog="Version %s written by %s " % (__version__, __author__)
                                     )

    parser.add_argument('-v', '--verbose',
                        action='count',
                        default=0, # emit warnings, errors, and critical
                        help="increase verbosity level")

    parser.add_argument('--version',
                        action='version',
                        version='%(prog)s ' + __version__
                        )
    parser.add_argument("xmlfiles",
                        metavar="XMLFILES",
                        nargs="+",
                        help="Searches for metadata in the XML file"
                        )

    args = parser.parse_args(args=cliargs)
    # Setup logging and the log level according to the "-v" option
    dictConfig(DEFAULT_LOGGING_DICT)
    # Setup logging and the log level according to the "-v" option
    # If user requests more, cut it and return always DEBUG
    loglevel = LOGLEVELS.get(args.verbose, logging.DEBUG)

    # Set console logger to the requested log level
    for handler in log.handlers:
        if handler.name == "console":
            handler.setLevel(loglevel)

    args.config = readconfig(CONFIGDIRS)
    log.debug("Reading these config files %s",
              getattr(args.config, "configfiles", "n/a"))
    return args


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


# def check_


def process(args: argparse.Namespace, config: configparser.ConfigParser):
    """
    """
    pass


def main(cliargs=None) -> int:
    """Entry point for the application script
    :param cliargs: Arguments to parse or None (=use :class:`sys.argv`)
    :return: error code
    """
    try:
        args = parsecli(cliargs)
        config = readconfig(CONFIGDIRS)
        log.debug("CLI args %s", args)

        process(args, config)
        # do some useful things here...
        # If everything was good, return without error:
        log.debug("I'm a debug message.")
        log.info("I'm an info message")
        log.warning("I'm a warning message.")
        log.error("I'm an error message.")
        log.fatal("I'm a really fatal massage!")

        return 0

    except NoConfigFilesFoundError as error:
        log.critical("No config files found")
        return 100

    except Exception as error:  # FIXME: add a more specific exception here!
        log.exception("Some unknown exception occured", error)
        # Use whatever return code is appropriate for your specific exception
        return 200


if __name__ == "__main__":
    sys.exit(main())