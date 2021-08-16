import re
import pytest

# "gen" is the abbreviated name for "getentityname.py"
import gen


def test_help(capsys):
    # given
    # n/a

    # when
    with pytest.raises(SystemExit):
        gen.main(["prog", "--help"])

    # then
    assert capsys.readouterr()


def test_invalid(capsys):
    # given
    # n/a

    # when
    with pytest.raises(SystemExit):
        gen.main(["prog", "--asdf"])

    # then
    assert capsys.readouterr()


def test_version(capsys):
    # given
    # n/a

    # when
    with pytest.raises(SystemExit):
        gen.main(["prog", "--version"])
    captured = capsys.readouterr()

    # then
    assert captured.out.rstrip() == gen.__version__
