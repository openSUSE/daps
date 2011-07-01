#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys

class progressbar(object):
    def __init__(self, finalcount, block_char="."):
        self.finalcount = finalcount
        self.blockcount = 0
        self.block = block_char
        self.f = sys.stdout
        if not self.finalcount: return
        self.f.write("\n------------------- % Progress ------------------1\n")
        self.f.write("    1    2    3    4    5    6    7    8    9    0\n")
        self.f.write("----0----0----0----0----0----0----0----0----0----0\n")

    def progress(self, count):
        count = min(count, self.finalcount)
        if self.finalcount:
            percentcomplete = int(round(100.0*count/self.finalcount))
            if percentcomplete < 1: percentcomplete = 1
        else:
            percentcomplete=100
        blockcount = int(percentcomplete/2)
        if blockcount <= self.blockcount:
            return
        for i in range(self.blockcount, blockcount):
            self.f.write(self.block)
        self.f.flush()
        self.blockcount = blockcount
        if percentcomplete == 100:
            self.f.write("\n")

if __name__ == "__main__":
    from time import sleep
    pb = progressbar(100, "*")
    pb.progress(20)
    sleep(0.3)
    pb.progress(35)
    sleep(0.3)
    pb.progress(47)
    sleep(0.3)
    pb.progress(80)
    sleep(1)
    pb.progress(100)
#    sleep(0.4)
#    pb.progress(1)
