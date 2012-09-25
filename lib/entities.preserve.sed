s:&\([^;]*;\):|000\1:g
#s:&\([a-z,A-Z,0-9]*\)\;:|000\1|:g
# fs 2012-09-25:
# This regexp is not sufficient - see
# http://www.w3.org/TR/1998/REC-xml-19980210#NT-CombiningChar
# for characters allowed to define an entity
#s:&sle\;:000sle0:g
#s:&slereg\;:000slereg0:g
#s:&sls\;:000sls0:g
#s:&slsa\;:000slsa0:g
#s:&slsreg\;:000slsreg0:g
#s:&nld\;:000nld0:g
#s:&nlda\;:000nlda0:g
#s:&nldreg\;:000nldreg0:g
#s:&naareg\;:000naareg0:g
#s:&slreg\;:000slreg0:g
