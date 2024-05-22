import argparse
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

from . import __author__, __version__
from .config import readconfig
from .common import CONFIGDIRS
from .logging import DEFAULT_LOGGING_DICT, LOGLEVELS, log


#: Change root logger level from WARNING (default) to NOTSET
#: in order for all messages to be delegated.
logging.getLogger().setLevel(logging.NOTSET)



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


def process(args, config):
    """
    """
    log.info("I'm the process function!")


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