sudo apt-get update && sudo apt-get upgrade -y
sudo apt install mysql-server -y
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
sudo rm -R /home/vagrant/iaw-practica-lamp/src
sudo rm -R /home/vagrant/iaw-practica-lamp/README.md
su root 
mysql -u root < database.sql
mysql -u root
CREATE USER 'appgestion'@'192.168.10.33' IDENTIFIED BY 'appgestion1234.';
GRANT ALL PRIVILEGES ON lamp_db.* TO 'appgestion'@'192.168.10.33';
FLUSH PRIVILEGES;
sudo sed -i "/^bind-address/c\bind-address = 192.168.10.34" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql