'''
Created on 03/03/2011
@author: thysmeintjes
'''

from datetime import datetime

WFILE = "/home/thys/wiki/wiki.txt"
wikifile = open(WFILE, "r")
SQLEND = "'', 0);"


class ParseData:
    def __init__(self, line):
        self.line = line
        self.name = ""
        self.time = datetime.fromtimestamp(0)
        self.author = ""
        self.text = ""

        if self.parseLine() == True:
            self.getText()

    def getText(self):
        line = wikifile.next()
        txt = []
        cnt = 0
        while (line.find(SQLEND, 0, len(SQLEND)) == -1):
            cnt = cnt + 1
            if cnt > 100:
                break
            print ".",
            txt.append(line)
            line = wikifile.next()

        self.text = ''.join(txt)

    def parseLine(self):
        tup = self.line.split()
        if len(tup) > 15:
            print self.line
            print tup
            self.name = tup[12]
            self.author = tup[15]
            tm = tup[14].strip(",")
            self.time = datetime.fromtimestamp(float(tm))
            return True
        return False

    def getDateTime(self):
        return self.time

    def __str__(self):
        return "%s %s %s\n%s" % (self.time, self.name, self.author, self.text)

    # INSERT INTO wiki (name, version, "time", author, ipnr, text, "comment", readonly) VALUES ('TracLinks', 1, 1271417103, 'trac', '127.0.0.1', '= Trac Links =


SEARCH = "INSERT INTO wiki"
for line in wikifile:
    if line.find(SEARCH, 0, len(SEARCH)) != -1:
        data = ParseData(line)
        print data
