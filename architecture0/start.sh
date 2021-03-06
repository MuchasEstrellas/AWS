#!/bin/sh
sudo apt-get --yes update
sudo apt-get --yes install build-essential python
sudo apt-get --yes install python-setuptools
echo "mysql-server-5.6 mysql-server/root_password password uisaws123" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password uisaws123" | sudo debconf-set-selections
sudo apt-get --yes install mysql-server
sudo apt-get --yes install python-dev
sudo apt-get --yes install nginx
sudo apt-get --yes install upstart
mysql -u root --password=uisaws123 < earthquake.sql
sudo /etc/init.d/nginx start
sudo easy_install pip
sudo pip install virtualenv
virtualenv venv
. venv/bin/activate
pip install -r requirements.txt
deactivate
sudo chown -R www-data:www-data static/uploadedimages/
python nginx_conf_maker.py
sed -i "s?WorkingDirectory=.*?WorkingDirectory=$(pwd)?" aws_app.service
sed -i "s?Environment=.*?Environment=\"PATH=$(pwd)/venv/bin\"?" aws_app.service
sed -i "s?ExecStart=.*?ExecStart=$(pwd)/venv/bin/uwsgi --ini aws_app.ini?" aws_app.service
sudo systemctl daemon-reload
sudo rm -r /etc/nginx/sites-enabled/aws_app_nginx.conf
sudo rm -r /etc/systemd/system/aws_app.service
sudo ln -s $(pwd)/aws_app_nginx.conf /etc/nginx/sites-enabled
sudo ln -s $(pwd)/aws_app.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start aws_app

sudo service nginx restart
