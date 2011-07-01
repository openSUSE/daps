#!/usr/bin/python
# -*- coding: UTF-8 -*-


def sortDeutsch(a,b):
    return locale.strcoll(a, b)

def test():
    #print sys.argv, sys.argv[0].rsplit("/",1)[0]
    #path=os.path.join(os.path.dirname(sys.argv[0]), "indexterms")
    #sys.path.insert(0, path)
    #
    locale.setlocale(locale.LC_ALL,"")

    s = """
Aal
Aachen
Arau
Abakus
Abbau
Xerces
Ägide
Äffchen
Affäre
überall 
Üxeküll 
Übermacht 
übernachten 
über
übermenschlich
"""

    print "Sort according to German Locale:"
    sList =s.split()
    sList.sort(sortDeutsch)
    for x in sList:
        print x

    print '--------' 


    for x in sorted(sList, key=locale.strxfrm):
        print x
