import pytest

# "gen" is the abbreviated name for "getentityname.py"
import gen


def test_version(capsys):
    ver = None
    with pytest.raises(SystemExit):
        ver = gen.main(["--version"])
    captured = capsys.readouterr()
    assert captured.out.rstrip() == gen.__version__
