import pytest
import py

# "gen" is the abbreviated name for "getentityname.py"
import gen

DATADIR=py.path.local(__file__).dirpath().join("data")
XMLFILES=DATADIR.listdir("*.xml", sort=True)
OUTFILES=(f.new(ext=".out") for f in XMLFILES)
# CATALOGFILES=DATADIR.listdir("*.", sort=True)


@pytest.mark.parametrize("xmlfile, outfile",
    zip(XMLFILES, OUTFILES),
    ids=lambda path: path.basename,
)
def test_xml_and_output(xmlfile, outfile, capsys):
    DIRNAME = py.path.local(xmlfile.dirname)

    # First we check for consistency if the .out file is there
    assert outfile.exists()
    # We read our data and convert it into a set.
    # We are only interested in the content, not the order.
    # That way, the order doesn't matter.
    # Furthermore, any empty string ("") are skipped (see the if clause
    # inside the list comprehension)
    outdata = outfile.read().strip().split(" ")
    outdata = [DATADIR / f for f in outdata if f]

    result = gen.main([xmlfile.strpath])
    assert result == 0

    captured = capsys.readouterr().out.strip().split(" ")
    captured = [DATADIR / py.path.local(f).basename for f in captured if f]
    assert set(captured) == set(outdata)
