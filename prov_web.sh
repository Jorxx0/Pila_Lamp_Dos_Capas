sudo apt-get update && sudo apt-get upgrade -y
sudo apt install apache2 -y
sudo apt install php libapache2-mod-php php-mysql -y
sudo systemctl restart apache2
sudo rm /var/www/html/index.html
sudo mkdir /var/www/html/appalumnos
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
sudo rm -R /var/www/html/appalumnos/iaw-practica-lamp/db
sudo rm -R /var/www/html/appalumnos/iaw-practica-lamp/README.md
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apche2/sites-available/appalumnos.conf
sudo sed -i '12s|.*| DocumentRoot /var/www/html/appalumnos/iaw-practica-lamp/src|' /etc/apache2/sites-available/appalumnos.conf
sudo sed -i "s/'localhost'/'192.168.10.34'/" /var/www/html/appalumnos/iaw-practica-lamp/src/config.php
sudo sed -i "s/'database_name_here'/'lamp_db'/" /var/www/html/appalumnos/iaw-practica-lamp/src/config.php
sudo sed -i "s/'username_here'/'appgestion'/" /var/www/html/appalumnos/iaw-practica-lamp/src/config.php
sudo sed -i "s/'password_here'/'appgestion1234.'/" /var/www/html/appalumnos/iaw-practica-lamp/src/config.php
sudo a2ensite appalumnos.conf
sudo systemctl reload apache2
