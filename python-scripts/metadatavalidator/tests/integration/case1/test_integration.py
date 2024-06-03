import os.path
import pytest

from metadatavalidator.cli import main

BASEDIR = os.path.dirname(os.path.realpath(__file__))


def test_case1_integration(capsys):
    cli = ["--config", f"{BASEDIR}/config-test.ini",
           #  "--json",
           f"{BASEDIR}/article.xml"]

    result = main(cli)
    captured = capsys.readouterr()
    assert result == 0
    assert "RESULTS" in captured.out
    assert f"{BASEDIR}/article.xml" in captured.out
    assert "check_info_revhistory" in captured.out
    # assert "check_info_revhistory_revision_date" in captured.out

