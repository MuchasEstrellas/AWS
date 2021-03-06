import urllib
ip = str(urllib.urlopen("http://169.254.169.254/latest/meta-data/public-ipv4").read())
file = open("aws_app_nginx.conf","w")
file.write("server {")
file.write("listen 80;")
file.write("server_name "+ip+";")
file.write("location / {")
file.write("include uwsgi_params;")
file.write("uwsgi_pass unix:///tmp/aws_app.sock;")
file.write("}")
file.write("}")
file.close()
