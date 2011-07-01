#s/scale=/width=/g
#s/width=\"65%\"\(.*EPS\)/width=\"75%\"\1/g
#s/width=\"60%\"\(.*EPS\)/width=\"75%\"\1/g
#s/width=\"90%\"\(.*EPS\)/width=\"75%\"\1/g
#s/width=\"85%\"\(.*EPS\)/width=\"75%\"\1/g
#s/width=\"80%\"\(.*EPS\)/width=\"75%\"\1/g
#s/width=\"100%\"\(.*EPS\)/width=\"75%\"\1/g
#s/<wordasword>//g
#s/<\/wordasword>//g
#s/width=\"100%\"\(.*PNG\)/width=\"75%\"\1/g
#s/width=\"90%\"\(.*PNG\)/width=\"75%\"\1/g
#s/width=\"85%\"\(.*PNG\)/width=\"75%\"\1/g
#s/width=\"80%\"\(.*PNG\)/width=\"75%\"\1/g
#s/=\"cha\(p\)\?[:\.]\(.*\)\"/=\"cha.\2\"/g
#s/=\"sec[:.]\(.*\)\"/=\"sec.\1\"/g
#s/=\"fig[:.]\(.*\)\"/=\"fig.\1\"/g
#s/linkend=\"\(.*\)[:]\(.*\)\"/linkend=\"\1.\2\"/g
#s/id=\"\(.*\)[:]\(.*\)\"/id=\"\1.\2\"/g
#s/startref=\"\(.*\)[:]\(.*\)\"/startref=\"\1.\2\"/g
#s# *<\/screen>#<\/screen>#g
#s:../enti:enti:g
#s:role="latex":role="fo":
#s:fileref="\(.*\).eps":fileref="\1.png":
#s:format="EPS":format="PNG":
#s/xml\.base/xml:base/
#s:&bladecenter\;:BladeCenter:
#s:&cr\;::
#s:&Ctrl\;:<keycap>Ctrl</keycap>:
#s:&js20\;:JS 20 Blade:
#s:&Enter\;:<keycap>Enter</keycap>:
#s:&BS\;:<keycap function="backspace"/>:
#s:&PfeilL\;:&larr\;:
#s:&autoyast\;:AutoYaST:
#s: pgwide = "0"::
#s: colwidth = ".*"::
#s:revision = ".*" ::
#s:lang = "en"::
#s:width="" ::
#s:fileref="graphics/\(.*\)eps":fileref="\1png":
#s:fileref="graphics/\(.*png\)":fileref="\1":
# s: "\(.*eps\)" : "\1":
#s:format="EPS":format="PNG":
#s:format="png":format="PNG":
s:Banshee:Helix Banshee:g
# s:\"novdocx.dtd\">:"novdocx.dtd" \n[ <!ENTITY % NOVDOC.DEACTIVATE.IDREF "INCLUDE"> \n<!ENTITY % entities SYSTEM "entity-decl.ent"> \n%entities; ]>:
1a\<?xml-stylesheet href="urn:x-suse:xslt:profiling:novdoc-profile.xsl" \
                 type="text/xml" \
                 title="Profiling step"?>

