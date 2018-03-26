#!/bin/sh
if [ -z "$1" ]
  then
    echo "Please put your write RDS endpoint"
    exit 1
elif [ -z "$2" ]
  then
    echo "Please put ACCESS KEY"
    exit 1
elif [ -z "$3" ]
  then
    echo "Please put your SECRET KEY"
    exit 1
elif [ -z "$4" ]
  then
    echo "Please put your S3 region"
    exit 1
elif [ -z "$5" ]
    then
      echo "Please put your domain"
      exit 1
elif [ -z "$6" ]
  then
    echo "Please put your REDIS endpoint"
    exit 1
elif [ -z "$7" ]
    then
      echo "Please put your read RDS endpoint"
      exit 1
fi
sudo apt-get --yes update
sudo apt-get --yes install build-essential python
sudo apt-get --yes install python-setuptools
sudo apt-get --yes install python-dev
sudo apt-get --yes install nginx
sudo apt-get --yes install upstart
mysql -h $1 -u root --password=uisaws123 < earthquake.sql
sudo /etc/init.d/nginx start
sudo easy_install pip
sudo pip install virtualenv
virtualenv venv
. venv/bin/activate
pip install -r requirements.txt
deactivate
sudo systemctl stop aws_app
sudo service nginx stop
sed -i "s?DB_HOST_WRITE=.*?DB_HOST_WRITE=\"$1\"?" views.py
sed -i "s?DB_HOST_READ=.*?DB_HOST_READ=\"$7\"?" views.py
sed -i "s?AWS_ACCESS_KEY_ID=.*?AWS_ACCESS_KEY_ID=\"$2\"?" views.py
sed -i "s?AWS_SECRET_ACCESS_KEY=.*?AWS_SECRET_ACCESS_KEY=\"$3\"?" views.py
sed -i "s?REGION=.*?REGION=\"$4\"?" views.py
sed -i "s?server_name.*?server_name $5;?" aws_app_nginx.conf
sed -i "s?REDIS_ENDPOINT=.*?REDIS_ENDPOINT=\"$6\"?" views.py
sudo rm -r /etc/nginx/sites-enabled/aws_app_nginx.conf
sudo rm -r /etc/systemd/system/aws_app.service
sed -i "s?WorkingDirectory=.*?WorkingDirectory=$(pwd)?" aws_app.service
sed -i "s?Environment=.*?Environment=\"PATH=$(pwd)/venv/bin\"?" aws_app.service
sed -i "s?ExecStart=.*?ExecStart=$(pwd)/venv/bin/uwsgi --ini aws_app.ini?" aws_app.service
sudo ln -s $(pwd)/aws_app_nginx.conf /etc/nginx/sites-enabled
sudo ln -s $(pwd)/aws_app.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start aws_app
sudo service nginx start