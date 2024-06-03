import os.path
import json
import pytest

from metadatavalidator.cli import main


BASEDIR = os.path.dirname(os.path.realpath(__file__))
RELATIVE_PATH = os.path.relpath(BASEDIR, os.getcwd())


def test_case1_integration(capsys):
    cli = ["--config", f"{BASEDIR}/config-test.ini",
           "--format", "json",  # needed to avoid formatting issues
           f"{RELATIVE_PATH}/article.xml"]

    result = main(cli)
    captured = capsys.readouterr()
    assert result == 0
    result = json.loads(captured.out)
    assert result[0]['errors'] == []
    assert result[0]['xmlfile'] == f"{RELATIVE_PATH}/article.xml"

