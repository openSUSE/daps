#!/usr/bin/python
# -*- coding: UTF-8 -*-

try:
    from operator import itemgetter
except ImportError:
    def itemgetter(i):
        def getter(self): return self[i]
        return getter

def superTuple(typename, *attribute_names):
    """create and return a subclass of 'tuple', with named attributes"""
    # make the subclass with appropriate __new__ and __repr__ specials
    nargs = len(attribute_names)
    class supertup(tuple):
        __slots__ = () # save memory, we don't need per-instance dict
        def __new__(cls, *args):
            if len(args) != nargs:
                raise TypeError, \
                   "%s takes exactly %d arguments (%d given)" % \
                       (typename, nargs, len(args) )
            return tuple.__new__(cls, args)

        def __repr__(self):
            return "%s(%s)" % (typename, ', '.join(map(repr, self)) )
    # add a few key touches to our subclass of 'tuple'
    for index, attr_name in enumerate(attribute_names):
        setattr(supertup, attr_name, property(itemgetter(index)))
    supertup.__name__ = typename
    return supertup
