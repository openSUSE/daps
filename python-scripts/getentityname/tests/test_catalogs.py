from unittest import mock

import pytest
import py

# "gen" is the abbreviated name for "getentityname.py"
import gen

TESTDIR = py.path.local(__file__).parts()[-2]


def test_catalog_does_not_exist():
    with pytest.raises(gen.XMLCatalogError, match=""):
        gen.xmlcatalog("urn:not_important",
                       "catalog-not-exists.xml",
                       raise_on_error=True)


@pytest.mark.parametrize("identifier", [
    "-//TOMS//DTD DocBook XML V7.0//EN",
    "https://example.org/example",
])
def test_xmlcatalog_identifiers(identifier):
    catalog = str(TESTDIR / "catalog-publicid-systemid.xml")
    result = gen.xmlcatalog(identifier, catalog, raise_on_error=True)
    assert result == "/it/works/"


def test_xmlcatalog_with_system_entity(tmpdir):
    # given
    resultentity = "my-fake.ent"
    catalogfile = (tmpdir / "catalog.xml")
    catalogfile.write_text("""<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog"> 
    <system systemId="http://www.example.org/foo.ent" uri="%s"/>
</catalog>""" % resultentity,
                           encoding="UTF-8",
                           )
    # when
    result = gen.xmlcatalog("http://www.example.org/foo.ent", str(catalogfile))
    
    # then
    assert result == str(tmpdir / resultentity)
   
    
def test_xmlcatalog_with_system_entity_mock():
    # Identical with test_xmlcatalog_with_system_entity, but without the
    # real call

    # given
    mock_patch="gen.xmlcatalog"
    entity = "fake.ent"
    with mock.patch(mock_patch) as mck:
        mck.return_value = entity
        
        # when
        result = gen.xmlcatalog("http://www.example.org", "fake-catalog.xml")

        # then
        assert result == entity
        mck.assert_called_once()


def test_xmlcatalog_with_missing_catalog():
    # given
    mock_patch="gen.os.path.exists"

    with mock.patch(mock_patch) as mck:
        mck.return_value = False
        # when/then
        with pytest.raises(gen.XMLCatalogError):
            gen.xmlcatalog("https://www.example.com", "fake-catalog.xml", True)
        

def test_xmlcatalog_with_error_from_xmlcatalog():
    # given
    mock_patch="gen.os.path.exists"

    with mock.patch(mock_patch) as mck:
        mck.return_value = True
        # 
        with pytest.raises(gen.XMLCatalogError):
            gen.xmlcatalog("https://www.example.com", "fake-catalog.xml", True)


def test_xmlcatalog_with_():
    # given
    mock_patch="gen.os.path.exists"
    proc = gen.subprocess.CompletedProcess("fake", returncode=100,
                                           stdout=b"", stderr=None)

    with mock.patch(mock_patch) as mck:
        with mock.patch("gen.subprocess.run") as mock_subprocess:
            mck.return_value = True
            mock_subprocess.return_value = proc
            assert gen.xmlcatalog("https://www.example.com", "fake-catalog.xml") is None
