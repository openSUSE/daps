# -*- coding: UTF-8 -*-

__version__="$Revision: 99 $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4"]

__all__=["Formatter"]

class colorprint:
    """Class for printing colored text
    """
    colordict = {
        "red":       "\033[31m",
        "green":     "\033[32m",
        "brown":     "\033[33m",
        "blue":      "\033[34m",
        "pink":      "\033[35m",
        "cyan":      "\033[36m",
        "lightgrey": "\033[37m",
        "black":     "\033[m\017",
        }
    backgroundcolordict={
        "black":     "\033[40m",
        "green":     "\033[42m",
        "brown":     "\033[43m",
        "blue":      "\033[44m",
        "pink":      "\033[45m",
        "cyan":      "\033[46m",
        "lightgrey": "\033[47m",
        "white":     "\033[48m",
        }
    def __init__(self, msg, color="black", background=None):
        self.msg = msg
        self.color = color
        self.background=background

    def __repr__(self):
        return "<colorprint '%s|%s' '%s'>" % \
                (self.color, self.background, self.msg)

    def __str__(self):
        color=self.colordict.get(self.color, self.colordict["black"])
        black=self.colordict["black"]
        return "%s%s%s" % (color, self.msg, black)

    def listcolors(self):
        return self.colordict.iterkeys()

    def listbackgroundcolors(self):
        return self.backgroundcolordict.iterkeys()

if __name__ == "__main__":
    a = colorprint("Hello World!", "blue")
    print repr(a)
    print "Available colors:", list(a.listcolors())
    for c in a.listcolors():
       print colorprint("Hello World!", c)
    #print a
