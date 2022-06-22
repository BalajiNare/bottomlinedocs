SESSION 1:
What is a Database -> Collection of data and holds this data in the form of tables.
What is a Table -> holds the data in the form of rows and columns. and it is similar to excel sheet
-> The database provides us the capability to access and manipulate the data.
Kind of databases:
1. Relational Database
2. Non relational (NoSQL Database)
Relational vs NoSQL DB
What is SQL
MySQL vs SQL
How to get a quick setup for working
Creating/dropping a Database
Creating/dropping a Table

root@goorm:/workspace/Balaji_Mysql# mysql-ctl cli
 * Stopping MySQL database server mysqld
   ...done.

MySQL 5.7 database added.  Please make note of these credentials:

       Root User: root
   Database Name: mysql

 * Starting MySQL database server mysqld
No directory, logging in with HOME=/
   ...done.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.7.36-0ubuntu0.18.04.1 (Ubuntu)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql> create database balajitech;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| balajitech         |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> use balajitech;
Database changed
mysql> show tables;
Empty set (0.00 sec)

mysql> select database;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '' at line 1
mysql> show database();
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'database()' at line 1
mysql> select database();
+------------+
| database() |
+------------+
1 row in set (0.00 sec)

mysql> create table emp(name varchar(20),age int, salary int);
Query OK, 0 rows affected (0.13 sec)

mysql> show tables;
+----------------------+
| Tables_in_balajitech |
+----------------------+
| emp                  |
+----------------------+
1 row in set (0.00 sec)

mysql> select * from emp;
Empty set (0.01 sec)

mysql> use balajitech;
Database changed
mysql> show tables;
+----------------------+
| Tables_in_balajitech |
+----------------------+
| emp                  |
+----------------------+
1 row in set (0.00 sec)

mysql> describe emp;
+--------+-------------+------+-----+---------+-------+
| Field  | Type        | Null | Key | Default | Extra |
+--------+-------------+------+-----+---------+-------+
| name   | varchar(20) | YES  |     | NULL    |       |
| age    | int(11)     | YES  |     | NULL    |       |
| salary | int(11)     | YES  |     | NULL    |       |
+--------+-------------+------+-----+---------+-------+
3 rows in set (0.10 sec)

mysql> desc emp;
+--------+-------------+------+-----+---------+-------+
| Field  | Type        | Null | Key | Default | Extra |
+--------+-------------+------+-----+---------+-------+
| name   | varchar(20) | YES  |     | NULL    |       |
| age    | int(11)     | YES  |     | NULL    |       |
| salary | int(11)     | YES  |     | NULL    |       |
+--------+-------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

mysql> drop database balajitech;
Query OK, 1 row affected (0.06 sec)

mysql> create table emp(name varchar(20),age int, salary int);
ERROR 1046 (3D000): No database selected

mysql> create database balajitech;
Query OK, 1 row affected (0.00 sec)

mysql> create table balajitech.emp(name varchar(20),age int, salary int);
Query OK, 0 rows affected (0.07 sec)


mysql> select database();
+------------+
| database() |
+------------+
| NULL       |
+------------+
1 row in set (0.00 sec)

RECAP: CREATE DATABASES, TABLES, BASIC DATA TYPES, DROP TABLE, DROP DATABASE


SESSION 2: LEARN SQL the Right Way
CRUD OPERATIONS:
CREATE - INSERT statements
READ - SELECT statements
UPDATE - UPDATE statements
DELETE  - DELETE statements

Creation of table and Insert statements
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| balajitech         |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> use balajitech;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------------+
| Tables_in_balajitech |
+----------------------+
| emp                  |
| employee             |
+----------------------+
2 rows in set (0.01 sec)

mysql> CREATE TABLE balajitech.employee(  firstname varchar(20),  lastname varchar(20),  middlename varchar(20),  age int,  salary int,  location varchar(20));
Query OK, 0 rows affected (0.14 sec)

mysql> desc employee;
+------------+-------------+------+-----+---------+-------+
| Field      | Type        | Null | Key | Default | Extra |
+------------+-------------+------+-----+---------+-------+
| firstname  | varchar(20) | YES  |     | NULL    |       |
| lastname   | varchar(20) | YES  |     | NULL    |       |
| middlename | varchar(20) | YES  |     | NULL    |       |
| age        | int(11)     | YES  |     | NULL    |       |
| salary     | int(11)     | YES  |     | NULL    |       |
| location   | varchar(20) | YES  |     | NULL    |       |
+------------+-------------+------+-----+---------+-------+
6 rows in set (0.00 sec)

mysql> select * from employee;
Empty set (0.00 sec)

mysql> INSERT INTO employee(firstname,lastname,middlename,age,salary,location) VALUES('naveen','kumar','patre',29,12000,'bangalore');
Query OK, 1 row affected (0.01 sec)

mysql> select * from employee;
+-----------+----------+------------+------+--------+-----------+
| firstname | lastname | middlename | age  | salary | location  |
+-----------+----------+------------+------+--------+-----------+
| kapil     | kumar    | sharma     |   28 |  10000 | bangalore |
| naveen    | kumar    | patre      |   29 |  12000 | bangalore |
+-----------+----------+------------+------+--------+-----------+
2 rows in set (0.00 sec)

mysql> INSERT INTO employee VALUES('kapil','kumar','sharma',28,10000,'bangalore'); --It's not recommended
Query OK, 1 row affected (0.01 sec)

mysql> INSERT INTO employee(firstname,lastname,age,salary,location) VALUES('rajesh','kumar',32,20000,'bangalore');
Query OK, 1 row affected (0.01 sec)

mysql> select * from employee;
+-----------+----------+------------+------+--------+-----------+
| firstname | lastname | middlename | age  | salary | location  |
+-----------+----------+------------+------+--------+-----------+
| kapil     | kumar    | sharma     |   28 |  10000 | bangalore |
| naveen    | kumar    | patre      |   29 |  12000 | bangalore |
| rajesh    | kumar    | NULL       |   32 |  20000 | bangalore |
+-----------+----------+------------+------+--------+-----------+
3 rows in set (0.00 sec)

mysql> INSERT INTO employee VALUES('rajesh','kumar',32,20000,'bangalore');
ERROR 1136 (21S01): Column count doesn't match value count at row 1

mysql> INSERT INTO employee(firstname,lastname,middlename,age,salary,location) VALUES('naveen',"kumar's",'patre',29,12000,'bangalore');
Query OK, 1 row affected (0.01 sec)

mysql> select * from employee;
+-----------+----------+------------+------+--------+-----------+
| firstname | lastname | middlename | age  | salary | location  |
+-----------+----------+------------+------+--------+-----------+
| kapil     | kumar    | sharma     |   28 |  10000 | bangalore |
| naveen    | kumar    | patre      |   29 |  12000 | bangalore |
| rajesh    | kumar    | NULL       |   32 |  20000 | bangalore |
| naveen    | kumar's  | patre      |   29 |  12000 | bangalore |
+-----------+----------+------------+------+--------+-----------+
4 rows in set (0.00 sec)



