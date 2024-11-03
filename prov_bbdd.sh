sleep 3
sudo apt-get update && sudo apt install mysql-server -y
sleep 3
sudo mkdir /home/vagrant/appgestion
sleep 3
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /home/vagrant/appgestion
sleep 3
sudo rm -r /home/vagrant/appgestion/src
sleep 3
sudo rm -r /home/vagrant/appgestion/README.md
sleep 3
sudo su 
sleep 3
mysql -u root < /home/vagrant/appgestion/db/database.sql
sleep 3
mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'appgestion'@'192.168.10.33' IDENTIFIED BY 'appgestion1234.';
EOF
mysql -u root <<EOF
GRANT ALL PRIVILEGES ON lamp_db.* TO 'appgestion'@'192.168.10.33';
EOF
sleep 3
sudo sed -i "/^bind-address/c\bind-address = 192.168.10.34" /etc/mysql/mysql.conf.d/mysqld.cnf
sleep 3
sudo systemctl restart mysql
sleep 3
sudo ip route del default