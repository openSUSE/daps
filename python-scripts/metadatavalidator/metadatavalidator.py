#!/usr/bin/python3
"""

"""

import argparse
import configparser
import logging
from logging.config import dictConfig
import sys

try:
    from lxml import etree
except ImportError:
    print("Cannot import lxml. ", file=sys.stderr)
    sys.exit(10)

__version__ = "0.2.0"
__author__ = "Tom Schraitle <toms@suse.de>"

#: The logger name; can also set to "__name__"
LOGGERNAME = "metadata"

#: The dictionary, passed to :class:`logging.config.dictConfig`,
#: is used to setup your logging formatters, handlers, and loggers
#: For details, see https://docs.python.org/3.4/library/logging.config.html#configuration-dictionary-schema
DEFAULT_LOGGING_DICT = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'standard': {'format': '[%(levelname)s] %(funcName)s: %(message)s'},
        # 'file': {'format': '[%(levelname)s] %(asctime)s (%(funcName)s): %(message)s',
        #          #: Depending on your wanted precision, disable this line
        #          'datefmt': '%Y-%m-%d %H:%M:%S',
        #          },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG', # will be set later
            'formatter': 'standard',
            'class': 'logging.StreamHandler',
        },
        # 'fh': {
        #     'level': 'DEBUG',  # we want all in the log file
        #     # Change the formatting here, if you want a different output in your log file
        #     'formatter': 'file',
        #     'class': 'logging.FileHandler',
        #     'filename': '/tmp/log.txt',
        #     'mode': 'w',  # use "a" if you want to append log output or remove this lien
        # },
    },
    'loggers': {
        LOGGERNAME: {
            'handlers': ['console', ],
            'level': 'DEBUG',
            'propagate': False,
        },
        # Set the root logger's log level:
        '': {
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
    parser.add_argument("XMLFILE",
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

    log.debug("CLI result: %s", args)
    return args


def main(cliargs=None) -> int:
    """Entry point for the application script
    :param cliargs: Arguments to parse or None (=use :class:`sys.argv`)
    :return: error code
    """
    try:
        args = parsecli(cliargs)
        # do some useful things here...
        # If everything was good, return without error:
        log.debug("I'm a debug message.")
        log.info("I'm an info message")
        log.warning("I'm a warning message.")
        log.error("I'm an error message.")
        log.fatal("I'm a really fatal massage!")

        return 0

    # List possible exceptions here and return error codes
    except Exception as error:  # FIXME: add a more specific exception here!
        log.fatal(error)
        # Use whatever return code is appropriate for your specific exception
        return 10


if __name__ == "__main__":
    sys.exit(main())