import asyncio
from argparse import Namespace
# from configparser import ConfigParser
import typing as t
import os.path

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
    errors = []
    basexmlfile = os.path.basename(xmlfile)
    for checkfunc in get_all_check_functions(checks.__package__):
        log.debug("Checking %r with %r",
                  basexmlfile,
                  checkfunc.__name__)
        try:
            # loop = asyncio.get_running_loop()
            # tree = await loop.run_in_executor(None, etree.parse, xmlfile)
            tree = etree.parse(xmlfile,
                               parser=etree.XMLParser(encoding="UTF-8"))

            # Apply check function
            checkfunc(tree, config)

        except etree.XMLSyntaxError as e:
            # log.fatal("Syntax error in %r: %s", xmlfile, e)
            errors.append({
                'checkfunc': checkfunc.__name__,
                'message': str(e)
            })

        except InvalidValueError as e:
            #log.fatal("Invalid value in %r for %s: %s",
            #          xmlfile, checkfunc.__name__,  e)
            errors.append({
                'checkfunc': checkfunc.__name__,
                'message': str(e)
            })
        else:
            # log.info("Passed check %r for %r", checkfunc.__name__, os.path.basename(xmlfile))
            pass

    log.info("File %r checked.", basexmlfile)
    return {
        "xmlfile": xmlfile,
        "errors": errors,
        "basename": os.path.basename(xmlfile),
    }

def green(text):
    return f"\033[32m{text}\033[0m"

def red(text):
    return f"\033[31m{text}\033[0m"


def format_results(results: list[t.Any]):
    """Format the results for output

    :param results: the results from the checks
    """
    error_template = """[{idx}] {xmlfile}:"""
    ok_template = f"""[{{idx}}] {{xmlfile}}: {green("OK")}"""

    print("==== RESULTS ====")
    for allidx, result in enumerate(results, 1):
        if not result['errors']:
            print(ok_template.format(idx=allidx, **result))
        else:
            print(error_template.format(idx=allidx, **result))

            for idx, error in enumerate(result['errors'], 1):
                msg = red(error['message'])
                print(f"  {allidx}.{idx}: {error['checkfunc']}: {msg}")
            print()



async def process(args: Namespace, config: dict[t.Any, t.Any]):
    """Process all XML files that are passed on CLI

    :param args: the arguments parsed by argparse
    :param config: read-only configuration from INI file
    """
    log.debug("Process all XML files...")
    tasks = []
    async with asyncio.TaskGroup() as tg:
        for xmlfile in args.xmlfiles:
             task = tg.create_task(process_xml_file(xmlfile, config))
             tasks.append(task)

    results = []
    for task in tasks:
        maybeissue = await task
        if maybeissue:
            results.append(maybeissue)

    format_results(results)
