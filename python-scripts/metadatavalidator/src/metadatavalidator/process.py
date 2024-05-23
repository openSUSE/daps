import asyncio
from argparse import Namespace
# from configparser import ConfigParser
import typing as t

from lxml import etree

# from .checks.check_root import check_root_tag, check_namespace
from . import checks
from .exceptions import InvalidValueError
from .logging import log


def get_all_check_functions(name):
    """"Yield a check function from the :mod:`metadatavalidator.checks`
    package
    """
    import importlib
    module = importlib.import_module(name)
    for name, obj in module.__dict__.items():
        if callable(obj) and name.startswith("check_"):
            yield obj


async def process_xml_file(xmlfile: str, config: dict[t.Any, t.Any]):
    """Process a single XML file

    :param xmlfile: the XML file to check for meta data
    :param config: read-only configuration from INI file
    """
    for checkfunc in get_all_check_functions(checks.__package__):
        try:
            # loop = asyncio.get_running_loop()
            # tree = await loop.run_in_executor(None, etree.parse, xmlfile)
            tree = etree.parse(xmlfile,
                               parser=etree.XMLParser(encoding="UTF-8"))

            # Apply check function
            checkfunc(tree, config)

        except etree.XMLSyntaxError as e:
            log.fatal("Syntax error in %r: %s", xmlfile, e)

        except InvalidValueError as e:
            log.fatal("Invalid value in %r for %s: %s",
                      xmlfile, checkfunc.__name__,  e)

    log.info("File %r checked successfully.", xmlfile)


async def process(args: Namespace, config: dict[t.Any, t.Any]):
    """Process all XML files that are give on CLI

    :param args: the arguments parsed by argparse
    :param config: read-only configuration from INI file
    """
    log.debug("Process all XML files...")
    async with asyncio.TaskGroup() as tg:
        for xmlfile in args.xmlfiles:
            tg.create_task(process_xml_file(xmlfile, config))