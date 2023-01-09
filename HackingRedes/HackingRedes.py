"""
!INTERFACES DE RED
Una interfaz de red es el software que se comunica con el dispositivo que nos brinda internet y la capa IP
a fin de proporcionar a la capa IP una interfaz coherente con todos los adaptadores de red que puedan estar 
presentes.


?$ ifconfig ---> listar interfaces de red 

?$ iwconfig 
listar más interfaces de red, incluye algunas que no estan activas, dadas de bajas, etc. Estas
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

Falsificar la direccion mac 

MAc -----> Direccion unica de un dispositivo, como el dni

Se conforma de 3 pares, siendo los 3 primeros el famoso OUI (Organization Unique Identifier) y los ultimos 3 el Network Controller
Specific

?$ macchanger -l 

Listar lista de los OUI conocidos

Por lo que podriamos usar los OUI para falsificar la mac de nuestro dispositivo

?$ macchanger -l | grep -i "national security agency"
8310 - 00:20:91 - J125, NATIONAL SECURITY AGENCY

?$ macchanger --mac=00:20:91:da:af:91 {interfaz}

(hexadecimal --> n (1 - 9) l (a - f))

--> [ERROR] Could not change MAC: interface up or insufficient permissions: Device or resource busy

Esto pasa porque la red wlan0mon esta dada de alta

?$ ifconfig wlan0mon down

?$ ifconfig wlan0mon up


! AIRCRACK-NG 

Es una suite (paquete de programas) de seguridad inalambrica. Es un analizador de paquetes de redes, recupera contraseñas WEB y 
WPA/WPA2 asi como otro conjunto de  herramientas de auditorias inalambricas

Las herramientas más utilizadas para la auditoría inalámbrica son:

Aircrack-ng (descifra la clave de los vectores de inicio)
Airodump-ng (escanea las redes y captura vectores de inicio)
Aireplay-ng (inyecta tráfico para elevar la captura de vectores de inicio)
Airmon-ng (establece la tarjeta inalámbrica en modo monitor, para poder capturar e inyectar vectores)

?$ airodump-ng {interfaz}


 BSSID              PWR  Beacons    #Data, #/s  CH   MB   ENC CIPHER  AUTH ESSID

 E4:AB:89:3C:7F:C7  -29       31        1    0  11  130   WPA2 CCMP   PSK  colgatedeesta   

Donde BSSID ----> MAC del router
PWR ----> Power 
#Data ---> Data
#/s ----> por segundo
CH -----> chanel
MB ----> MegaBytes
ENC ---> Encriptado
CIPHER -----> parte del cifrado
AUTH ----> Clave de autorizacion
ESSID ----> Nombre de la red

Channel hoppin es lo que hace la tarjeta de red para ir cambiando entre canales para asi encontrar redes

CLIENTES 

 BSSID              STATION            PWR   Rate    Lost    Frames  Notes  Probes

 CC:ED:DC:1F:22:61  74:EB:80:4D:64:64  -70    0 - 1e     0        1       

BSSID ---> MAC del router al que se esta conectado
STATION ---> MAC del dispositivo (celular, pc, tele, etc)
PWR ---> Power
RATE ---> Tasa de recepcion - Tase de retransmicion (se muestra la e si la red se encuentra con el QOS habilitado) 
LOST ---> paquetes perdidos en los ultimos 10s
FRAMES ---> numero de paquetes enviados por el cliente
NOTES ---> Info adicional
PROBES ---> Probe request, buscando un probe response de redes previas a las que se haya conectado en el pasado el dispositivo

! Filtros con airodump-ng

Filtrar por canales

?$ airodump-ng -c {n°_channel} {interfaz}

?$ airodump-ng --essid {name_essid} {interfaz}

?$ airodump-ng --bssid {bssid} {interfaz}

?$ airodump-ng --bssid {bssid} -w {file_name} {interfaz}

Para hackear una red inalambrica, necesitamos ir guardando todo el trafico en un file para poder capturar la contraseña ya que 
esta no va a estar en texto claro, si no cifrada con el CIPHER que tenga, posteriormente necesitariamos extraer el hash de la 
clave cifrada para aplicar fuerza bruta, este es el porque se necesita la captura 

El archivo que nos interesa de los que crea es el .cap, el que va a alojar el hash de la contraseña

!HANDSHAKE

Se genera en el momento en el que el usuario se reconecta a la red, ya que el usuario esta volviendo a proporcionar las credenciales
de la conexion (claramente en texto no claro).

De esta manera se pueden enviar paquetes al marco de deautenticacion del router para expulsar a los clientes de la red inalambrica
Para hacerlo nos tenemos que enfocar en los clientes, si este es uno o son pocos lo que podemos hacer es un ataque de 
deauthenticacion por mac

?$ aireplay-ng -0 {n_paquetes} -e {name_essid} -c {mac_cliente} {interfaz}

En caso contrario, si tuviesemos muchos usuarios podriamos hacer un ataque de deauthenticacion global

?$ aireplay-ng -0 {n_paquetes} -e {name_essid} -c FF:FF:FF:FF:FF:FF {interfaz}
o
?$ aireplay-ng -0 {n_paquetes} -e {name_essid} {interfaz}

Esto de FF:FF:FF:FF:FF:FF es la broadcast mac addres, de esta manera desconectariamos a todos los usuarios y con que uno se 
reconecte, capturariamos el handshake.





"""