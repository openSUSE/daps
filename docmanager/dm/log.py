# -*- coding: UTF-8 -*-
#
# This file is part of the docmanager distribution.
#
# docmanager is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2 of the License, or (at your option) any
# later version.
#
# docmanager is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

class DMLogger(logging.Logger):
    """
    A DM logger is not that different to any other logger, except that
    it must have a logging level and there is only one instance of it in
    the hierarchy.
    """
    def __init__(self, **kwargs):
        """
        Initialize the logger with the name "root".
        """
        logging.Logger.__init__(self, "DocManager")
        filename = kwargs.get("filename")
        if filename:
            mode = kwargs.get("filemode", 'a')
            hdlr = logging.FileHandler(filename, mode)
        else:
            stream = kwargs.get("stream")
            hdlr = logging.StreamHandler(stream)
        fs = kwargs.get("format", logging.BASIC_FORMAT)
        dfs = kwargs.get("datefmt", None)
        fmt = logging.Formatter(fs, dfs)
        hdlr.setFormatter(fmt)
        self.addHandler(hdlr)
        level = kwargs.get("level")
        if level:
          self.setLevel(level)


def logs(function):
    return Logs(function)

class Logs(object):
   """Decorator class"""
   def __init__(self, function, level=logging.DEBUG):
      self.func = function
      self.level = level

   def __get__(self, instance, cls=None):
        self.instance = instance
        return self

   def __call__(self, *args):
      kwargs=vars(self.func)
      # print >> sys.stderr, "<%s>" % self.func.__name__, args, kwargs
      dmlog.log(self.level, msg="Start %s: args=%s vars=%s" % ( self.func.__name__, args, kwargs) )
      try:
        return self.func(self.instance, *args)
      
      finally:
        # print >> sys.stderr, "</%s>" % self.func.__name__
        dmlog.log(self.level, msg=" End %s" % ( self.func.__name__, ) )


dmlog = DMLogger(level=logging.DEBUG, filename="/tmp/foo.log")

if __name__=="__main__":
  pass
