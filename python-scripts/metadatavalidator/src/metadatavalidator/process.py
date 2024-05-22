import asyncio
from argparse import Namespace
from configparser import ConfigParser

from lxml import etree

from .logging import log


# Example check functions
def check_root_tag(tree):
    if tree.getroot().tag in ("article", "book", "topic"):
        raise ValueError("Root tag is not 'expected_root'")

def check_element_exists(tree, element_name):
    if tree.find(element_name) is None:
        raise ValueError(f"Element '{element_name}' not found")


async def process_xml_file(xmlfile: str):
    """Process a single XML file
    """
    try:
        # loop = asyncio.get_running_loop()
        # tree = await loop.run_in_executor(None, etree.parse, xmlfile)
        tree = etree.parse(xmlfile)

        # Apply check functions
        check_root_tag(tree)
        # check_element_exists(tree, 'required_element')

        # Add calls to more check functions here...

        log.info("File %s processed successfully.", xmlfile)

    except etree.XMLSyntaxError as e:
        log.fatal("Problem with %r: %s", xmlfile, e)
        # print(f"Error in file {xmlfile}: {e}")


async def process(args: Namespace, config: ConfigParser):
    """
    """
    log.debug("Process all XML files...")
    async with asyncio.TaskGroup() as tg:
        for xmlfile in args.xmlfiles:
            tg.create_task(process_xml_file(xmlfile))