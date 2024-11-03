# README

# Infraestructura en Dos Capas con Vagrant

Este documento describe el proceso para crear una infraestructura en dos capas utilizando Vagrant, con una configuración LAMP que separa el servidor de aplicación (Apache y PHP) y el servidor de base de datos (MySQL).

## Índice

1. [Introducción](about:blank#introducci%C3%B3n)
2. [Requisitos Previos](about:blank#requisitos-previos)
3. [Diseño de la Infraestructura](about:blank#dise%C3%B1o-de-la-infraestructura)
4. [Configuración del VagrantFile](about:blank#configuraci%C3%B3n-del-vagrantfile)
5. [Provisión del Servidor de Aplicación](about:blank#provisi%C3%B3n-del-servidor-de-aplicaci%C3%B3n)
6. [Provisión del Servidor de Base de Datos](about:blank#provisi%C3%B3n-del-servidor-de-base-de-datos)
7. [Conexión entre las Capas](about:blank#conexi%C3%B3n-entre-las-capas)
8. [Pruebas de Funcionamiento](about:blank#pruebas-de-funcionamiento)
9. [Conclusiones](about:blank#conclusiones)

## Introducción

Este README proporciona instrucciones para configurar una infraestructura en dos capas:
- **Capa de Aplicación**: servidor web Apache con PHP.
- **Capa de Base de Datos**: servidor de base de datos MySQL.

## Requisitos Previos

- **Vagrant**: [Instalar Vagrant](https://www.vagrantup.com/downloads)
- **VirtualBox** u otro proveedor compatible con Vagrant.
- Conocimientos básicos de redes y provisión de servicios.

## Diseño de la Infraestructura

La infraestructura consiste en dos máquinas virtuales:
- **Aplicación**: instancia con Apache, que servirá como servidor web.
- **Base de Datos**: instancia con MySQL para el almacenamiento de datos.

Ambas máquinas se comunican a través de una red privada configurada en el VagrantFile.

## Configuración del VagrantFile

El siguiente `Vagrantfile` configura dos máquinas virtuales, una para la aplicación y otra para la base de datos.

```ruby
Vagrant.configure("2") do |config|  
# Configuración de las máquinas
config.vm.box = "ubuntu/jammy64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048      # Asigna 2 GB de RAM a la VM
    vb.cpus = 2           # Asigna 2 CPU a la VM
  end
# Máquina de Apache
  config.vm.define "webserver" do |webserver|
    webserver.vm.hostname = "JorgeLopezApache"
    webserver.vm.network "public_network"
    webserver.vm.network "forwarded_port", guest: 80, host: 8080
    webserver.vm.network "private_network", ip:"192.168.10.33", virtualbox__intnet: "red_datos"
    webserver.vm.provision "shell", path: "prov_web.sh"
  end
# Máquina de Base de Datos
  config.vm.define "bbddserver" do |bbddserver|
    bbddserver.vm.hostname = "JorgeLopezMySql"
    bbddserver.vm.network "private_network", ip:"192.168.10.34", virtualbox__intnet: "red_datos"
    bbddserver.vm.provision "shell", path: "prov_bbdd.sh"
  end

end
```

Este archivo Vagrantfile crea dos máquinas virtuales:
- La máquina de aplicación, con IP privada `192.168.10.33`.
- La máquina de base de datos, con IP privada `192.168.10.34`.

## Provisión del Servidor de Aplicación

El script de aprovisionamiento `prov_web.sh` configura Apache, PHP y el cliente MySQL en el servidor de aplicación:

```bash
# Actualiza los repositorios e instala Apache
sudo apt-get update && sudo apt install apache2 -y
# Instala PHP, el módulo de PHP para Apache, y php-mysql para conexión con MySQL
sudo apt install php libapache2-mod-php php-mysql -y
# Instala el cliente de MySQL para conexiones remotas
sudo apt install mysql-client -y
# Reinicia el servicio Apache para aplicar configuraciones iniciales
sudo systemctl restart apache2
# Elimina el archivo predeterminado index.html en el directorio raíz de Apache
sudo rm /var/www/html/index.html
# Crea un directorio para la aplicación dentro del directorio raíz de Apache
sudo mkdir /var/www/html/appalumnos
# Clona el repositorio de la aplicación en el nuevo directorio de la aplicación
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/html/appalumnos/
# Elimina archivos innecesarios del repositorio clonado
sudo rm -r /var/www/html/appalumnos/db
sudo rm -r /var/www/html/appalumnos/README.md
# Crea una copia de la configuración de sitio de Apache como base para appalumnos.conf
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/appalumnos.conf
# Modifica el DocumentRoot en appalumnos.conf para apuntar a la carpeta de la aplicación
sudo sed -i '12s|.*| DocumentRoot /var/www/html/appalumnos/src|' /etc/apache2/sites-available/appalumnos.conf
# Configura la IP de la base de datos en config.php para permitir acceso remoto
sudo sed -i "s/'localhost'/'192.168.10.34'/" /var/www/html/appalumnos/src/config.php
# Define el nombre de la base de datos en config.php
sudo sed -i "s/'database_name_here'/'lamp_db'/" /var/www/html/appalumnos/src/config.php
# Configura el nombre de usuario en config.php para acceso a la base de datos
sudo sed -i "s/'username_here'/'appgestion'/" /var/www/html/appalumnos/src/config.php
# Configura la contraseña en config.php para el usuario de la base de datos
sudo sed -i "s/'password_here'/'appgestion1234.'/" /var/www/html/appalumnos/src/config.php
# Habilita el nuevo sitio de Apache appalumnos
sudo a2ensite appalumnos.conf
# Deshabilita el sitio predeterminado de Apache
sudo a2dissite 000-default.conf
# Reinicia Apache para aplicar todas las configuraciones del sitio
sudo systemctl restart apache2
```

Este script realiza las siguientes acciones:
1. Instala Apache y PHP.
2. Configura el directorio del proyecto.
3. Ajusta la conexión a la base de datos en el archivo `config.php` para que use la IP de la máquina de base de datos.

## Provisión del Servidor de Base de Datos

El script de aprovisionamiento `prov_bbdd.sh` configura MySQL y los datos iniciales en la base de datos:

```bash
# Actualiza los repositorios e instala el servidor MySQL
sudo apt-get update && sudo apt install mysql-server -y
# Crea un directorio para la aplicación dentro de la carpeta del usuario vagrant
sudo mkdir /home/vagrant/appgestion
# Clona el repositorio de la aplicación en el directorio recién creado
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /home/vagrant/appgestion
# Elimina la carpeta src del repositorio, que no es necesaria en este servidor
sudo rm -r /home/vagrant/appgestion/src
# Elimina el archivo README.md del repositorio para limpiar el entorno
sudo rm -r /home/vagrant/appgestion/README.md
# Cambia al usuario root
sudo su 
# Importa la base de datos inicial usando un archivo SQL
mysql -u root < /home/vagrant/appgestion/db/database.sql
# Crea un usuario en MySQL llamado 'appgestion' con permisos para conectarse desde la IP especificada
mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'appgestion'@'192.168.10.33' IDENTIFIED BY 'appgestion1234.';
EOF
# Otorga todos los privilegios en la base de datos 'lamp_db' al usuario 'appgestion' desde la IP especificada
mysql -u root <<EOF
GRANT ALL PRIVILEGES ON lamp_db.* TO 'appgestion'@'192.168.10.33';
EOF
# Configura MySQL para que escuche en la IP de la máquina de base de datos en lugar de localhost
sudo sed -i "/^bind-address/c\\bind-address = 192.168.10.34" /etc/mysql/mysql.conf.d/mysqld.cnf
# Reinicia MySQL para aplicar los cambios de configuración
sudo systemctl restart mysql
# Elimina la ruta predeterminada de la tabla de enrutamiento (opcional según necesidades de red)
sudo ip route del default
```

Este script realiza las siguientes acciones:
1. Instala MySQL.
2. Importa datos iniciales a la base de datos.
3. Crea un usuario para la aplicación y ajusta la IP de `bind-address` para permitir conexiones desde la máquina de aplicación.

## Conexión entre las Capas

Para que Apache en la capa de aplicación pueda acceder a MySQL en la capa de base de datos, verificamos que ambas máquinas estén en la misma red privada (`192.168.10.0/24`). La IP del servidor de base de datos (`192.168.10.34`) debe ser accesible desde la máquina de aplicación.

## Pruebas de Funcionamiento

1. **Prueba de Apache**: accede a `http://127.0.0.1:8080` desde el navegador para verificar que Apache esté funcionando.
2. **Prueba de MySQL**: desde la máquina de aplicación, intenta conectarte a MySQL en `192.168.10.34`:
    
    ```bash
    mysql -h 192.168.10.34 -u appgestion -p
    ```
