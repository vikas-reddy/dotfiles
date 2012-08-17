#!/usr/bin/python

import StringIO, commands, os, string, smtplib, re

master     = "readboard_master.txt"
from_addr  = "dcppreadboard@iiith.com"
to_addr    = "to-email-addr@domainname"
board_addr = "http://10.3.3.41/board.txt"

os.system("/usr/bin/curl '%s' > board.txt" % (board_addr))

last_lines = commands.getstatusoutput("tail -n 7 '%s' | grep -vE '^[[:space:]\r]*$' | tail -n 3" % (master))[1].split('\n')
updates    = ''
latest     = open('board.txt', 'r')
found      = 0

last_lines.reverse()

for last_line in last_lines:
	while True:
		line = latest.readline()

		# EOF
		if line == '':
			break

		# Match | breaking condition
		if string.strip(line) == string.strip(last_line):
			found = 1
			updates = latest.read()
			print updates
			break

	if found == 1:
		break
	else:
		latest.seek(0)


# Fallback! Save entire readboard
if string.strip(updates) == '':
	latest.seek(0)
	updates = latest.read()

latest.close()
#print updates


# SMTP
srv = smtplib.SMTP('localhost')
headers = "From: DC++ Mailer <dcpp@iiith.com>\r\nTo: %s\r\nSubject: DC++ Readboard\r\n\r\n" %(to_addr)
srv.sendmail(from_addr, to_addr, headers + updates)
srv.quit()


# Updating master file
f = open(master, 'a')
f.write(updates)
f.close
