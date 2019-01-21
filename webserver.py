import socket
import datetime
import re
import os

HOST, PORT = '',80 
listen_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
listen_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
listen_socket.bind((HOST, PORT))
listen_socket.listen(1)
print 'Serving HTTP on port %s ...' % PORT
path = ('/tdtsg','/qzfs')
while True:
    try:	    	
    	client_connection, client_address = listen_socket.accept()
	request = client_connection.recv(1024)
    	http_response=""
 	matchobj = re.finditer(r"GET (.*?) HTTP",request)
        for result in matchobj:
		request_path = result.group(1)
        print datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+"  "+request_path
	if request_path in path:
		file_path = os.getcwd()  + request_path + ".html"
        	file_text = open(file_path,"r+")
        	http_response = "HTTP/1.1 200 OK\n\n" 
        	for text in file_text:
	    		http_response = http_response + text
    	else:
		http_response ="HTTP/1.1 500 NOT FOUND\n"
    #print http_response[0:20]
        client_connection.sendall(http_response)
        client_connection.close()
    except BaseException,args:
	print datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+" Error:  "+repr(args)
