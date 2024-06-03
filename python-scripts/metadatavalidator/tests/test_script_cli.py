import argparse
import re
import pytest

from metadatavalidator.cli import parsecli


def test_parsecli():
    args = parsecli(["-v", "a.xml", "b.xml"])
    assert args.verbose == 1
    assert args.xmlfiles == ["a.xml", "b.xml"]


def test_parsecli_version(capsys):
    with pytest.raises(SystemExit):
        parsecli(["--version"])

    captured = capsys.readouterr()
    # We can't check for the script name as it's "pytest"
    assert re.match(r"[a-z]+ \d+\.\d+(\.\d+)? written by .*\n", captured.out)


def test_parsecli_config():
    args = parsecli(["--config", "config.ini", "a.xml", "b.xml"])
    assert args.config == "config.ini"
    assert args.xmlfiles == ["a.xml", "b.xml"]