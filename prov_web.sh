sleep 3
sudo apt-get update && sudo apt install apache2 -y
sleep 3
sudo apt install php libapache2-mod-php php-mysql -y
sleep 3
sudo apt instal mysql-client -y
sleep 3
sudo systemctl restart apache2
sleep 3
sudo rm /var/www/html/index.html
sleep 3
sudo mkdir /var/www/html/appalumnos
sleep 3
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/html/appalumnos/
sleep 3
sudo rm -r /var/www/html/appalumnos/db
sleep 3
sudo rm -r /var/www/html/appalumnos/README.md
sleep 3
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/appalumnos.conf
sleep 3
sudo sed -i '12s|.*| DocumentRoot /var/www/html/appalumnos/src|' /etc/apache2/sites-available/appalumnos.conf
sleep 3
sudo sed -i "s/'localhost'/'192.168.10.34'/" /var/www/html/appalumnos/src/config.php
sleep 3
sudo sed -i "s/'database_name_here'/'lamp_db'/" /var/www/html/appalumnos/src/config.php
sleep 3
sudo sed -i "s/'username_here'/'appgestion'/" /var/www/html/appalumnos/src/config.php
sleep 3
sudo sed -i "s/'password_here'/'appgestion1234.'/" /var/www/html/appalumnos/src/config.php
sleep 3
sudo a2ensite appalumnos.conf
sleep 3
sudo a2dissite 000-default.conf
sleep 3
sudo systemctl restart apache2
