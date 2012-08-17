#!/usr/bin/python

import StringIO, commands, os

master     = "board_master.txt"
to_addr    = "to-email-addr@domainname"
board_addr = "http://10.3.3.41/board.txt"
last_line  = commands.getstatusoutput("tail -n 7 '%s' | grep -vE '^[[:space:]]$' | tail -n 1" % (master))[1]
updates    = ''


latest = commands.getstatusoutput('/usr/bin/curl "%s"' % (board_addr))[1]
#f = open('board_latest.txt', 'r')
#latest = StringIO.StringIO(f.read())
#f.close


for line in latest:
    if line[0:-1] == last_line:
        break

updates = latest.read()
latest.close()

print updates
os.system('echo "%s" | mail -s "DC++ Readboard" "%s"' % (updates, to_addr))

# Updating master file
f = open(master, 'a')
f.write(updates)
f.close
