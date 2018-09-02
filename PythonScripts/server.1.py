#!/usr/bin/python3

import socket

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

host = socket.gethostname()

port = 5001

server_socket.bind((host, port))

server_socket.listen(5)

while True:
    client_socket, addr = server_socket.accept()

    print("Got a connection from %s" % str(addr))

    msg = 'Thank you bitch' + "\r\n"
    client_socket.send(msg.encode('ascii'))
    client_socket.close()