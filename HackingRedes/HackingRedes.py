"""
!INTERFACES DE RED
Una interfaz de red es el software que se comunica con el dispositivo que nos brinda internet y la capa IP
a fin de proporcionar a la capa IP una interfaz coherente con todos los adaptadores de red que puedan estar 
presentes.


?$ ifconfig ---> listar interfaces de red 

?$ iwconfig 
listar más interfaces de red, incluse algunas que no estan activas, dadas de bajas, etc. Estas
se habilitan para con los containers desplegados

!TARJETAS DE RED

Si bien la pc suele traer una, por lo que si estamos en una distribucion de linux con el os de base, y no una 
vm, etc. Podriamos utilizar esta tarjeta de red si es que acepta el modo monitor. Al conectar una tarjeta de 
red se crearia una nueva interfaz, mediante la cual nos podriamos comunicar con la misma.

ES IMPORTANTE QUE TENGAMOS UNA TARJETA DE RED o ADAPTADOR WIFI CON MODO MONITOR PARA PODER ESCANEAR EL MOVIMIENTO
EN LA RED

!DIRECCIONES IP

*PRIVADAS
?$ hotname -I 

La ip privada es la ip que se asigna dentro del entorno de red local, por lo que si alguien por ejemplo nos 
lanzase una traza icmp, nuestra maquina no responderia ya que es la ip que utiliza para el segmento de red priv.

*PUBLICAS
En cambio la ip publica es con la ip que salimos a internet, la cual debemos cuidar para que no sea obtenida por
nadie.

?$ curl https://ipinfo.io

vermiip.es

!DIRECCIONES MAC

Es como el dni de un dispositivo, un celular, una tarjeta de red, el router, etc.

Para ver la direccion mac de un dispositivo 

?$ macchanger --help

?$ macchanger -s {dispositivo}

Los primeros 3 bytes de la mac identifican el fabricante

!VULNERACION

*Redes WPA/WPA2 

Ponernos en modo monitor para poder efectuar estos ataques, nos permite capturar y escuchar paquetes que viajan
en el aire, podriamos identificar distintos puntos de accesos que hay en el entorno, clientes autenticados con
sus direcciones mac, direcciones mac de los distintos AP (access point)
SSID ---> Nombre de la red
BSSID --> Direccion mac del ruter

Si nuestra tarjeta de red admite modo monitor podemos iniciarlo con 

?$ airmon-ng start {interfaz} | airmon-ng stop {interfaz}

?$ ifconfig 
Al hacer esto nuestra tarjeta de red ya no estaria

?$ iwconfig
Pero al hacer esto la veriamos, para levantarla

?$ ifconfig {interfaz} up

Cuando activamos el modo monitor hay que tener en cuenta que ciertos procesos quedan corriendo los cuales 
nos podrian traer ciertos problemas en ataques. Ya que el dhclient nos asigna ip por dhcp y el supplicant 
para que nos mantenga conectados a la red. Y practicamento todos los ataques se pueden hacer de manera offline.
Para matar estos procesos conflictivos se pueden matar de 3 formas distintas

?$ pkill dhclient && pkill wpa_supplicant
?$ killall dhclient wpa_supplicant
------
?$ airmon-ng check kill

Cuando paramos el modo monitor se recomienda es reinicar el servicio networking 

?$ /etc/init.d/networking restart

"""