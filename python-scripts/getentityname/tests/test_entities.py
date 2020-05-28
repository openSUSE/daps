import argparse
import re
from unittest import mock
import pytest
import py
import sys

# "gen" is the abbreviated name for "getentityname.py"
import gen


@pytest.fixture
def cliargs():
    """Simulates parsed CLI arguments"""
    return argparse.Namespace(absolute=False,
                              catalog=gen.MAINCATALOG,
                              separator=' ',
                              skip_public=True,
                              verbose=1,
                              xmlfiles=["fake.xml"],
                              )


def test_parse_ent_file_empty(cliargs, tmpdir):
    # given
    # cliargs: parsed CLI arguments
    # tmpdir: temporary directory
    entityfile = (tmpdir / "entity-file.ent")
    entityfile.write_text("", encoding="UTF-8")
    
    # when
    entity = gen.parse_ent_file(str(entityfile), cliargs)
    
    # then
    assert list(entity) == []


def test_parse_ent_file_content(cliargs, tmpdir):
    # given
    # cliargs: parsed CLI arguments
    # tmpdir: temporary directory
    entityfile = (tmpdir / "entity-file.ent")
    entityfile.write_text("""<!ENTITY x "X">""",
                          encoding="UTF-8")
    
    # when
    entity = gen.parse_ent_file(str(entityfile), cliargs)
    
    # then
    assert list(entity) == []


def test_parse_ent_file_with_one_entity(cliargs, tmpdir):
    # given
    # cliargs: parsed CLI arguments
    # tmpdir: temporary directory
    entityfile = (tmpdir / "entity-file.ent")
    entityfile.write_text("""<!ENTITY % foo SYSTEM "foo.ent">
                          %foo;""",
                          encoding="UTF-8")
    secondfile = (tmpdir / "foo.ent")
    secondfile.write_text("", encoding="UTF-8")
    
    # when
    entity = gen.parse_ent_file(str(entityfile), cliargs)
    
    # then
    assert list(entity) == [str(tmpdir / 'foo.ent')]


def test_parse_ent_file_with_two_entities(cliargs, tmpdir):
    # given
    # cliargs: parsed CLI arguments
    # tmpdir: temporary directory
    entityfile = (tmpdir / "entity-file.ent")
    entityfile.write_text("""<!ENTITY % foo SYSTEM "foo.ent">
                          %foo;
                          <!ENTITY % bar SYSTEM "bar.ent">
                          %bar;
                          """,
                          encoding="UTF-8")
    secondfile = (tmpdir / "foo.ent")
    secondfile.write_text("", encoding="UTF-8")
    thirdfile = (tmpdir / "bar.ent")
    thirdfile.write_text("", encoding="UTF-8")
    
    
    # when
    entity = gen.parse_ent_file(str(entityfile), cliargs)
    
    # then
    assert set(entity) == set([str(tmpdir / 'foo.ent'),
                               str(tmpdir / 'bar.ent'),
                              ])


def test_parse_ent_file_with_public_entity(cliargs, tmpdir):
    # given
    # cliargs: parsed CLI arguments
    # tmpdir: temporary directory
    resultentity = "my-fake.ent"
    publicid = "-//TOMS//ENTITIES Example V1//EN"
    entityfile = (tmpdir / "entity-file.ent")
    entityfile.write_text(f"""
<!ENTITY % foo PUBLIC "{publicid}" "http://www.example.org/foo.ent">
%foo;
""",
                          encoding="UTF-8")

    catalogfile = (tmpdir / "catalog.xml")
    catalogfile.write_text(f"""<catalog prefer="public" xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
    <public publicId="{publicid}" uri="{resultentity}"/>
</catalog>""",
                           encoding="UTF-8",
                           )
    cliargs.skip_public = False
    cliargs.catalog = str(catalogfile)
    cliargs.verbose = 4

    # when
    result = list(gen.parse_ent_file(str(entityfile), cliargs))

    # then
    assert result == [str(tmpdir / resultentity)]


def test_parse_ent_file_with_system_entity(cliargs, tmpdir):
    # given
    # cliargs: parsed CLI arguments
    # tmpdir: temporary directory
    resultentity = "my-fake.ent"
    entityfile = (tmpdir / "entity-file.ent")
    entityfile.write_text("""<!ENTITY % foo SYSTEM "http://www.example.org/foo.ent">
                          %foo;
                          """,
                          encoding="UTF-8")
    catalogfile = (tmpdir / "catalog.xml")
    catalogfile.write_text("""<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog"> 
    <system systemId="http://www.example.org/foo.ent" uri="%s"/>
</catalog>""" % resultentity,
                           encoding="UTF-8",
                           )
    # cliargs.skip_public = False
    cliargs.catalog = str(catalogfile)
    
    # when
    result = list(gen.parse_ent_file(str(entityfile), cliargs))
    
    # then
    assert result == [str(tmpdir / resultentity)]


def test_skip_public_parameter_entity_in_investigate_identifiers(cliargs, caplog):
    import logging

    # given
    cliargs.skip_public = True
    cliargs.verbose = 4
    content = """
<!ENTITY % dbcent PUBLIC
    "-//OASIS//ENTITIES DocBook Character Entities V4.5//EN"
    "http://www.oasis-open.org/docbook/xml/4.5/dbcentx.mod">
%dbcent;
    """
    result = None
    # We are interested in a specific logger only
    caplog.set_level(logging.DEBUG, logger=gen.LOGGERNAME)

    # when
    # we are not interested in the result, but the logging output
    list(gen.investigate_identifiers(content, cliargs))

    # then
    for record in caplog.records:
        assert record.levelname == "DEBUG"
        if record.msg.startswith("Skipping public parameter entity"):
            result = True

    assert result, "Could not find 'Skipping public...' inside log records"
