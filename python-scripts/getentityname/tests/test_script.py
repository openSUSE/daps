import re
import pytest

# "gen" is the abbreviated name for "getentityname.py"
import gen


def test_version(capsys):
    ver = None
    with pytest.raises(SystemExit):
        ver = gen.main(["--version"])
    captured = capsys.readouterr()
    assert captured.out.rstrip() == gen.__version__


def test_should_raise_valueerror_in_rm_xml_comment_with_missing_closecomment():
    with pytest.raises(ValueError):
        gen.remove_xml_comments("<!-- Wrong XML comment")


def test_should_raise_valueerror_in_rm_xml_comment_with_doubledashes():
    with pytest.raises(ValueError):
        gen.remove_xml_comments("<!-- Not--allowed-->")


@pytest.mark.parametrize("space", [
    # space
    " ",
    # tab
    "\t",
    # newline
    "\n",
    # return
    "\r"
])
def test_regex_space(space):
    assert re.search(gen.SPACE, space)


@pytest.mark.parametrize("name", [
    "a",
    "A",
    "abc",
    "_",
    "_ab",
    ":",
    ":foo",
    "a:foo",
])
def test_regex_name(name):
    assert re.search(gen.NAME, name)


#@pytest.mark.parametrize("qstr", [
    #"'a'",
    #'"a"',
    #"'abc.def'",
    #"'http://example.org/foo'",
    #"'http://example.org/foo%20bar#xyz'",
    #"'http://example.org/foo%20\"bar#xyz'",
#])
#def test_regex_qstr(qstr):
    #assert re.search(gen.QSTR, qstr)


@pytest.mark.parametrize("sysid", [
    "'a'",
    '"a"',
    "'abc.def'",
    "'http://example.org/foo'",
    "'http://example.org/foo%20bar#xyz'",
    "'http://example.org/foo%20\"bar#xyz'",
])
def test_regex_systemliteral(sysid):
    assert re.search(gen.SYSTEMLITERAL, sysid)


@pytest.mark.parametrize("pubid", [
    "'-//OASIS//DTD DocBook XML V4.5//EN'",
    '"-//OASIS//DTD DocBook XML V4.5//EN"',
    "'ISO 8879:1986//ENTITIES Added Math Symbols: Arrow Relations//EN//XML'",
    '"-//W3C//ENTITIES Extra for MathML 2.0//EN"',
    '"urn:oasis:names:tc:entity:xmlns:xml:catalog"',
    '"-//OASIS//DTD Entity Resolution XML Catalog V1.0//EN"',
    '"http://www.w3.org/Graphics/SVG/1.1/rng/svg11.rng"',
])
def test_regex_publicliteral(pubid):
    assert re.search(gen.PUBLICLITERAL, pubid)


@pytest.mark.parametrize("extid", [
    "SYSTEM 'foo.dtd'",
    'SYSTEM "foo.dtd"',
    'SYSTEM\n"foo.dtd"',
    'SYSTEM\t"foo.dtd"',
    '''PUBLIC "-//OASIS//DTD DocBook XML V4.5//EN" "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"''',
    '''PUBLIC\n"-//OASIS//DTD DocBook XML V4.5//EN"\n"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"''',
])
def test_regex_externalid(extid):
    assert re.search(gen.EXTERNALID, extid, re.DOTALL|re.VERBOSE|re.MULTILINE)


@pytest.mark.parametrize("entity, expected", [
    # no. 1
    ("""<!ENTITY % ents SYSTEM "entities.ent">""",
     {'PEDecl': 'ents', 'pubid': None, 'sysid': '"entities.ent"'}
     ),
    # no. 2
    ("""<!ENTITY\n% ents\nSYSTEM\n"entities.ent"\n >""",
     {'PEDecl': 'ents', 'pubid': None, 'sysid': '"entities.ent"'}
     ),
    # no. 3
    ("""<!ENTITY % ents PUBLIC "urn:x-test:tom" "http://www.example.org/ent">""",
     {'PEDecl': 'ents',
      'pubid': '"urn:x-test:tom"',
      'sysid': '"http://www.example.org/ent"'}
     ),
     # no. 4
    ("""<!ENTITY\n%\n\tents PUBLIC\t"urn:x-test:tom"\r "http://www.example.org/ent"\n >""",
     {'PEDecl': 'ents',
      'pubid': '"urn:x-test:tom"',
      'sysid': '"http://www.example.org/ent"'}
     ),
     # no. 5
     ("""<!ENTITY % phrases-entities SYSTEM "phrases-decl.ent">""",
     {'PEDecl': 'phrases-entities',
      'pubid': None,
      'sysid': '"phrases-decl.ent"'}
     ),
])
def test_regex_entity(entity, expected):
    match = re.search(gen.ENTITY, entity, re.DOTALL|re.VERBOSE|re.MULTILINE)
    assert match
    assert match.groupdict() == expected



DOCTYPE_TEST_DATA = (
    # ID-Name, Data, Expected
    # no. 1
    ("normal",
     "<!DOCTYPE chapter>",
     dict(Name='chapter', pubid=None, sysid=None)
     ),

    # no. 2
    ("normal-with-linebreaks",
     "<!DOCTYPE\nchapter \n>",
     dict(Name='chapter', pubid=None, sysid=None)
     ),

    # no. 3
    ("with-empty-intsubset",
     "<!DOCTYPE\nchapter []\n>",
     dict(Name='chapter', pubid=None, sysid=None)
     ),

    # no. 4
    ("with-intsubset-oneline",
    """
<!DOCTYPE chapter [<!ENTITY % ents SYSTEM "entities.ent">]>""",
    dict(Name='chapter', pubid=None, sysid=None)
    ),

    # no. 5
    ("with-linebreaks",
    """
<!DOCTYPE
chapter
[
  <!ENTITY % ents SYSTEM "entities.ent">
]

>""",
    dict(Name='chapter', pubid=None, sysid=None)
    ),

    # no. 6
    ("with-xml-declaration",
     """<?xml version="1.0"?>
<!DOCTYPE chapter
[
  <!ENTITY % ents SYSTEM "entities.ent">
]>
     """,
    dict(Name='chapter', pubid=None, sysid=None)
    ),

    # no. 7
    ("with-xml-declaration",
     """<?xml version="1.0"?>
<!DOCTYPE chapter SYSTEM "foo.dtd"
[
  <!ENTITY % ents SYSTEM "entities.ent">
]>
     """,
    dict(Name='chapter',
         pubid=None,
         sysid='"foo.dtd"')
    ),

    # no. 8
    ("with-public-identifier",
     """<!DOCTYPE chapter PUBLIC
       "-//OASIS//DTD DocBook XML V4.5//EN"
       "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"
[
  <!ENTITY % ents SYSTEM "entities.ent">
]>
     """,
     dict(Name='chapter',
          pubid='"-//OASIS//DTD DocBook XML V4.5//EN"',
          sysid='"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"')
    ),

    # no. 9
    ("with-public-identifier",
     """<!DOCTYPE chapter
  PUBLIC
    "-//OASIS//DTD DocBook XML V4.5//EN"
    "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"
[
  <!ENTITY % ents SYSTEM "entities.ent">
]
>""",
     dict(Name='chapter',
          pubid='"-//OASIS//DTD DocBook XML V4.5//EN"',
          sysid='"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"')
    ),

    # no. 10
    ("with-comment-before-doctype",
     """<!--
A very

long

XML

comment

-->
<!DOCTYPE chapter
[
  <!ENTITY % ents SYSTEM "entities.ent">
]>
     """,
    dict(Name='chapter', pubid=None, sysid=None)
    ),

    # no. 11

)


@pytest.mark.parametrize("header, expected",
                         [(data, expected) for _, data, expected in DOCTYPE_TEST_DATA],
                         ids=[name for name, _, _ in DOCTYPE_TEST_DATA]
                         )
def test_regex_doctype(header, expected):
    # match = re.search(gen.DOCTYPE, header, re.VERBOSE|re.DOTALL|re.MULTILINE)
    match = gen.r_DOCTYPE.search(header)
    assert match
    resultdict = match.groupdict()
    del resultdict['IntSubset']
    assert resultdict == expected


ENTITIES_TEST_DATA = (
    # ID-Name, Data, Expected
    # no. 1
    ("system",
     """<!ENTITY % ent SYSTEM "foo.ent">""",
     {'PEDecl': 'ent',
      'sysid': '"foo.ent"',
      'pubid': None}
    ),
    # no. 2
    ("public",
     """<!ENTITY % ent PUBLIC "-//TEST//ENTITIES V1.0//EN" "http://example.org/foo.ent">""",
     {'PEDecl': 'ent',
      'pubid': '"-//TEST//ENTITIES V1.0//EN"',
      'sysid': '"http://example.org/foo.ent"',
      }
    ),
    # no. 3
    ("with-linebreaks",
     """
     <!ENTITY % here
     SYSTEM
  "here.ent">
     """,
     {'PEDecl': 'here',
      'sysid': '"here.ent"',
      'pubid': None
      }
    ),
)

@pytest.mark.parametrize("ent, expected",
                         [(data, expected) for _, data, expected in ENTITIES_TEST_DATA],
                         ids=[name for name, _, _ in ENTITIES_TEST_DATA]
                         )
def test_should_match_entities(ent, expected):
    match = gen.r_ENTITY.search(ent)
    assert match
    # print(">>> match:", match.groupdict())
    assert match.groupdict() == expected
