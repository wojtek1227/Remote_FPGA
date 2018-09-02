#!/usr/bin/python3

import socket


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

host = socket.gethostname()

port = 5001

s.connect(("192.168.1.3", 5001))
# s.connect((host, port))
msg = "Test"
msg = s.recv(1024)

print(msg.decode('ascii'))
