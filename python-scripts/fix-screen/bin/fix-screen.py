#!/usr/bin/env python3
"""
Searches for <screen> tags in DocBook files and replace misplaced
linebreaks.

"""

import argparse
import re
from lxml import etree
import sys

__version__ = "0.2.0"
__author__ = "Tom Schraitle <toms@suse.de>"


ENTITIES = re.compile(r'&(?!(lt|gt|apos|quot|amp);)([\w\.\-_]+);')
START_DELIMITER = r"{{{"
END_DELIMITER = r"}}}"
MASKED_ENTITIES = re.compile(r'{}([\w\.\-_]+){}'.format(
    re.escape(START_DELIMITER),
    re.escape(END_DELIMITER))
)
SPACES = re.compile(r' +')


def stderr(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def parsecli(cliargs=None) -> argparse.Namespace:
    """Parse CLI with :class:`argparse.ArgumentParser` and return parsed result
    :param cliargs: Arguments to parse or None (=use sys.argv)
    :return: parsed CLI result
    """
    parser = argparse.ArgumentParser(description=__doc__,
                                     epilog="Version %s written by %s " % (__version__, __author__)
                                     )

    parser.add_argument('--version',
                        action='version',
                        version='%(prog)s ' + __version__
                        )
    parser.add_argument("--start-delimiter",
                        # default=r"{{{",
                        help="The start delimiter for masked entities (default: %(default)s)"
                        )
    parser.add_argument("--end-delimiter",
                        # default=r"}}}",
                        help="The end delimiter for masked entities (default: %(default)s)"
                        )
    parser.add_argument("--stdout",
                        action="store_true",
                        default=False,
                        help="Print the modified content to stdout"
                        )
    parser.add_argument("XMLFILES",
                        # dest="xmlfiles",
                        metavar="XMLFILES",
                        nargs='+',
                        help="The XML files to search for <screen>"
                        )

    global MASKED_ENTITIES, START_DELIMITER, END_DELIMITER
    args = parser.parse_args(args=cliargs)
    if args.start_delimiter is not None:
        START_DELIMITER = args.start_delimiter
    if args.end_delimiter is not None:
        END_DELIMITER = args.end_delimiter

    if args.start_delimiter is not None or args.end_delimiter is not None:
        MASKED_ENTITIES = re.compile(r'{}(\w+){}'.format(
            re.escape(START_DELIMITER),
            re.escape(END_DELIMITER))
        )
    return args


def xmlparser(**args):
    """Return a new XML parser object"""
    return etree.XMLParser(recover=True, **args)


def is_screen_content_text_only(screen):
    """
    Checks if the content inside a <screen> element contains only
    text and no child elements.
    """
    # Check that the <screen> element has no child elements using XPath
    return bool(screen.xpath("not(*) and normalize-space()"))


def replace_entities_with_braces(text, start=START_DELIMITER, end=END_DELIMITER):
    """
    Replaces entities in the text with curly braces, except for the
    standard entities &lt;, &gt;, &apos;, &quot;.
    """
    # Replace the matched entities with curly braces
    replacement = r'{}\2{}'.format(start, end)
    return ENTITIES.sub(replacement, text)


def restore_entities_from_braces(text):
    """
    Restores masked entities from curly braces back to their original form with ampersand.
    """
    # Define a regex pattern to match masked entities (e.g., {name})

    # Replace the masked entities with their original form
    return MASKED_ENTITIES.sub(r'&\1;', text)


def extract_screen_blocks(content):
    """
    Extracts all lines between <screen> and </screen> tags, including the tags.
    """
    screen_blocks = []
    current_block = []
    inside_screen = False

    for line in content.splitlines(keepends=True):
        if "<screen" in line:
            inside_screen = True

        if inside_screen:
            current_block.append(replace_entities_with_braces(line))

        if "</screen>" in line:
            inside_screen = False
            screen_blocks.append("".join(current_block))
            current_block = []

    return screen_blocks


def modify_screen_with_text_only(screen):
    # Remove the first newline character if it exists
    if screen.text and screen.text.startswith('\n'):
        screen.text = screen.text.lstrip()
    # Remove last newline character if it exists
    if screen.tail and screen.tail.endswith('\n'):
        screen.tail = screen.tail[:-1]


def group_by_prompt(screen):
    # Helper function to define a group when we encounter a 'prompt'
    grouped = []

    for element in screen:
        if element.tag == 'prompt':
            # Start a new group when 'prompt' is encountered
            grouped.append([element])
        else:
            # Append 'command' to the last group
            grouped[-1].append(element)

    return grouped


def modify_screen_with_prompt(screen):
    if screen.xpath("*[1][self::prompt]") and screen.text is not None:
        # Remove any whitespace between <screen> and <prompt>
        screen.text = screen.text.lstrip()
    if screen.text is not None and MASKED_ENTITIES.search(screen.text):
        screen.text = screen.text.lstrip()
    # Group the elements by <prompt> and non-prompt elements.
    # (<prompt>, <command>, <command>, <prompt>, <command>, ...) =>
    # [(<prompt>, <command>, <command>), (<prompt>, <command>), ...]
    grouped = group_by_prompt(screen)
    for group in grouped:
        prompt = group[0]
        if prompt.tail is not None:
            prompt.tail = SPACES.sub("", prompt.tail).strip("\n")
        for element in group[1:]:
            if element.tail is not None:
                element.tail = SPACES.sub(" ", element.tail).strip("\n")
        # Last element in the group should contain a newline character
        if group[-1].tail is not None:
            group[-1].tail = "\n" + group[-1].tail.lstrip()



def modify_screen_content(screen_content: str) -> str:
    """
    Parses the <screen> content using lxml.etree, modifies it, and returns the modified string.
    """
    # Parse the content as XML
    screen = etree.fromstring(screen_content, parser=xmlparser())

    has_text_only = is_screen_content_text_only(screen)
    # Case 1: The content starts with an entity
    if screen.text is not None and MASKED_ENTITIES.search(screen.text):
        screen.text = screen.text.lstrip()
    # Case 2: The content contains only text
    elif has_text_only:
        modify_screen_with_text_only(screen)
    # Case 3: The content contains child elements and starts with a <prompt> element
    elif screen.xpath("*[1][self::prompt]"):
        modify_screen_with_prompt(screen)

    # Return the modified XML as a string
    return etree.tostring(screen, encoding="unicode")


def replace_screen_blocks(content, modified_blocks):
    """
    Replaces the original <screen> blocks with the modified content.
    """
    for original, modified in modified_blocks:
        restored_modified = restore_entities_from_braces(modified)
        content = content.replace(original.rstrip(), restored_modified)
    return content


def process_file(xmlfile, stdout=False):
    """
    Orchestrates the extraction, modification, and replacement of <screen> blocks.
    """
    with open(xmlfile, 'r') as file:
        content = file.read()

    # Step 2: Extract <screen> blocks
    screen_blocks = extract_screen_blocks(content)

    # Check if any <screen> blocks were found
    if not screen_blocks:
        stderr(f"Skip {xmlfile}: No <screen> content found.")
        return

    # Step 3: Modify each <screen> block
    modified_blocks = [(block, modify_screen_content(block)) for block in screen_blocks]

    # Step 4: Replace original blocks with modified ones
    modified_content = replace_screen_blocks(content, modified_blocks)

    # Step 5: Output the modified content
    if not stdout:
        stderr(f"Would write to {xmlfile}")
        with open(xmlfile, 'w') as file:
            file.write(modified_content)
    else:
        print(modified_content)


def main(cliargs=None):
    args = parsecli(cliargs)
    stderr(">>> args:", args)
    for xmlfile in args.XMLFILES:
        process_file(xmlfile, args.stdout)


if __name__ == "__main__":
    main()
