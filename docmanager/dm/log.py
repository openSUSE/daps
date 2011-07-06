# -*- coding: UTF-8 -*-

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
