CREATE USER blackspace WITH PASSWORD 'qaz123';
CREATE DATABASE lab1;
GRANT ALL PRIVILEGES ON DATABASE lab1 TO blackspace;
ALTER DATABASE lab1 OWNER TO blackspace;


CREATE TABLE public."Books"
(
    "IdBook" integer PRIMARY KEY,
    "BookName" text,
    "IdAvtor" integer NOT NULL,
    "KolStr" integer NOT NULL,
    "BookDate" date,
    "Note" text

);

ALTER TABLE "Books" DROP COLUMN "Note";

ALTER TABLE "Books" RENAME COLUMN "KolStr" TO "quantity";


ALTER TABLE "Books" ALTER COLUMN "quantity" TYPE smallint;

ALTER TABLE "Books" ADD COLUMN "rcd" TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

INSERT INTO "Books" ("IdBook", "BookName", "IdAvtor", "quantity", "BookDate" ) VALUES
(1, 'Вьюга на Выштынецком озере', 1, 200, '1990-01-12' ),
(2, 'Бахчевые культуры в огородничестве', 2, 3500, '2000-04-22' ),
(3, 'Белые ночи в Сочи', 2, 300, '2012-11-08' ),
(4, 'Они были белками', 1, 123, '1996-03-10' ),
(5, 'Непутёвые заметки туриста', 2, 287, '2020-06-13' ),
(6, 'Особенности характера капибары', 2, 2894, '2013-05-10' ),
(7, 'Закат солнца вручную подробное руководство', 1, 971, '2016-09-25' ),
(8, 'Морской мир Монголии', 1, 582, '2018-03-14' ),
(9, 'Доказательства плоской земли', 1, 1404, '1990-01-14' ),
(10, 'Поручик Ржевский и Кубок огня', 1, 1404, '1990-01-22' );

SELECT "BookName" AS "Название", "IdAvtor" FROM "Books" WHERE "IdAvtor" = 1;

SELECT "BookName" AS "Название",
EXTRACT('Year' FROM "BookDate") AS "Год издания",
EXTRACT('Month' FROM "BookDate") AS "Месяц издания",
EXTRACT('Day' FROM "BookDate") AS "День издания"
FROM "Books" WHERE EXTRACT('Year' FROM "BookDate") > 2000;

SELECT * FROM "Books" WHERE "BookDate" > '1990-01-01' AND "BookDate" < '1990-01-31';

SELECT COUNT(*) AS "Количество" FROM "Books" WHERE "IdAvtor" = 1;

SELECT SUM("quantity") FROM "Books";

SELECT AVG("quantity") FROM "Books";

SELECT COUNT (DISTINCT "IdAvtor") AS "Количество авторов" FROM "Books";

SELECT "BookName" AS "Название", "IdAvtor", "quantity" AS "Максимальное количество страниц" FROM "Books" WHERE "quantity" = (SELECT MAX("quantity") FROM "Books");
SELECT to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD') AS "Текущая дата", to_char(CURRENT_TIMESTAMP, 'HH24:MI:SS') AS "Текущее время";

SELECT datname FROM pg_database;
SELECT * FROM pg_database;





############################## 2 #############################

CREATE TABLE public."Avtor"
(
    "IdAvtor" SERIAL PRIMARY KEY,
    "AvtorFam" text,
    "AvtorName" text,
    "BirthDate" date
);

ALTER TABLE public."Books"
ADD CONSTRAINT "IdAvtor" FOREIGN KEY ("IdAvtor")
REFERENCES public."Avtor" ("IdAvtor") MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;

INSERT INTO "Avtor" ("AvtorFam", "AvtorName", "BirthDate" ) VALUES
('Грушневский', 'Борис', '1986-09-04'),
('Станиславский', 'Георгий', '1981-12-31'),
('Ворошилов', 'Алексей', '1990-03-22'),
('Нечаева', 'Ксения', '1989-05-06'),
('Кириченко', 'Ирина', '1993-10-24'),
('Ивлииев', 'Александр', '1985-03-17'),
('Мазуркина', 'Наталья', '1981-11-15'),
('Валеева', 'Альпина', '1985-02-11');

INSERT INTO "Avtor" ("AvtorFam", "AvtorName", "BirthDate" ) VALUES
('Курчатова', 'Светлана', '1964-03-17');


SELECT "BookName" AS "Название", EXTRACT('Year' FROM "BookDate") AS "Год издания", ("AvtorFam" || ' ' || "AvtorName") AS "Фамилия_Имя_автора" FROM "Books"
JOIN "Avtor" ON "Books"."IdAvtor" = "Avtor"."IdAvtor";

3.2. ><
SELECT "BookName" AS "Название", "BirthDate" AS "Дата рождения", ("AvtorFam" || ' ' || "AvtorName") AS "Фамилия_Имя_автора" FROM "Books"
JOIN "Avtor" ON "Books"."IdAvtor" = "Avtor"."IdAvtor" WHERE EXTRACT('Year' FROM "BirthDate") < '1960' OR  EXTRACT('Year' FROM "BirthDate") > '1980';


3.2. UNION
SELECT "BookName" AS "Название", "BirthDate" AS "Дата рождения", ("AvtorFam" || ' ' || "AvtorName") AS "Фамилия_Имя_автора" FROM "Books"
JOIN "Avtor" ON "Books"."IdAvtor" = "Avtor"."IdAvtor" WHERE EXTRACT('Year' FROM "BirthDate") < '1960'
UNION
SELECT "BookName" AS "Название", "BirthDate" AS "Дата рождения", ("AvtorFam" || ' ' || "AvtorName") AS "Фамилия_Имя_автора" FROM "Books"
JOIN "Avtor" ON "Books"."IdAvtor" = "Avtor"."IdAvtor" WHERE EXTRACT('Year' FROM "BirthDate") > '1980';


3.2. EXCEPT
SELECT "BookName" AS "Название", "BirthDate" AS "Дата рождения", ("AvtorFam" || ' ' || "AvtorName") AS "Фамилия_Имя_автора" FROM "Books"
JOIN "Avtor" ON "Books"."IdAvtor" = "Avtor"."IdAvtor"
EXCEPT
SELECT "BookName" AS "Название", "BirthDate" AS "Дата рождения", ("AvtorFam" || ' ' || "AvtorName") AS "Фамилия_Имя_автора" FROM "Books"
JOIN "Avtor" ON "Books"."IdAvtor" = "Avtor"."IdAvtor" WHERE ( EXTRACT('Year' FROM "BirthDate") <= '1980' AND EXTRACT('Year' FROM "BirthDate") >= '1960');

3.3.
SELECT "Books"."IdAvtor", COUNT(*) AS "Количество книг", ("AvtorFam" || ' ' || "AvtorName") AS "Фамилия_Имя_автора" FROM "Books"
JOIN "Avtor" ON "Books"."IdAvtor" = "Avtor"."IdAvtor" GROUP BY "Books"."IdAvtor", "Avtor"."AvtorFam", "Avtor"."AvtorName";

3.4.
SELECT EXTRACT('Year' FROM "BookDate") AS "Год издания", COUNT(*) AS "Количество книг" FROM "Books" GROUP BY EXTRACT('Year' FROM "BookDate");


команда RETURNING * - это вывод удаляемых строк, где * означает что выводим все поля каждой строки
LIMIT 1 - это и есть ограничение на количество строк, то есть выбираем одну строку с минимальным значением в поле IdAvtor
3.5.1. DELETE FROM "Avtor" WHERE "IdAvtor" IN (SELECT MIN("IdAvtor") FROM "Avtor" LIMIT 1) RETURNING *;

будет вывод

ERROR:  update or delete on table "Avtor" violates foreign key constraint "IdAvtor" on table "Books"
DETAIL:  Key (IdAvtor)=(1) is still referenced from table "Books".

Ошибка удаления возникает так как у автора с IdAvtor = 1 есть книги в таблице Books, соответствено удаляя автора книги остаются без автора - это запрещено в бд.


3.5.2. DELETE FROM "Books" WHERE "IdBook" IN (SELECT MAX("IdAvtor") FROM "Books" LIMIT 1)  RETURNING *;

данное удаление пройдёт без проблем и будет вывод
IdBook |              BookName              | IdAvtor | quantity |  BookDate  |            rcd
--------+------------------------------------+---------+----------+------------+----------------------------
      2 | Бахчевые культуры в огородничестве |       2 |     3500 | 2000-04-22 | 2024-09-16 12:35:05.222727
(1 row)

3.6.
SELECT * FROM "Books" ORDER BY "BookName" DESC;
ORDER BY - команда отсортировать вывод из бд по условию или полю
DESC - порядок сортировки по убыванию, сортируем по полю BookName - то есть по названию книги в алфавитном порядке
будет вывод
IdBook |                  BookName                  | IdAvtor | quantity |  BookDate  |            rcd
--------+--------------------------------------------+---------+----------+------------+----------------------------
     10 | Поручик Ржевский и Кубок огня              |       1 |     1404 | 1990-01-22 | 2024-09-16 12:35:05.222727
      6 | Особенности характера капибары             |       2 |     2894 | 2013-05-10 | 2024-09-16 12:35:05.222727
      4 | Они были белками                           |       1 |      123 | 1996-03-10 | 2024-09-16 12:35:05.222727
      5 | Непутёвые заметки туриста                  |       2 |      287 | 2020-06-13 | 2024-09-16 12:35:05.222727
      8 | Морской мир Монголии                       |       1 |      582 | 2018-03-14 | 2024-09-16 12:35:05.222727
      7 | Закат солнца вручную подробное руководство |       1 |      971 | 2016-09-25 | 2024-09-16 12:35:05.222727
      9 | Доказательства плоской земли               |       1 |     1404 | 1990-01-14 | 2024-09-16 12:35:05.222727
      1 | Вьюга на Выштынецком озере                 |       1 |      200 | 1990-01-12 | 2024-09-16 12:35:05.222727
      3 | Белые ночи в Сочи                          |       2 |      300 | 2012-11-08 | 2024-09-16 12:35:05.222727
(9 rows)

3.7.1. составной запрос - выбираем всех авторов из таблицы Avtor, IdAvtor которых нет в таблице Books
SELECT * FROM "Avtor" WHERE "IdAvtor" NOT IN (SELECT "IdAvtor" FROM "Books");

будет вывод
 IdAvtor | AvtorFam  | AvtorName | BirthDate
---------+-----------+-----------+------------
       3 | Ворошилов | Алексей   | 1990-03-22
       4 | Нечаева   | Ксения    | 1989-05-06
       5 | Кириченко | Ирина     | 1993-10-24
       6 | Ивлииев   | Александр | 1985-03-17
       7 | Мазуркина | Наталья   | 1981-11-15
       8 | Валеева   | Альпина   | 1985-02-11
       9 | Курчатова | Светлана  | 1964-03-17
(7 rows)


3.7.2. с помощью JOIN
SELECT "Avtor"."IdAvtor", "Avtor"."AvtorFam", "Avtor"."AvtorName", "Avtor"."BirthDate" FROM "Avtor"
LEFT JOIN "Books" ON  "Avtor"."IdAvtor" = "Books"."IdAvtor"
WHERE "Books"."IdAvtor" IS NULL;

будет аналогичный вывод
 IdAvtor | AvtorFam  | AvtorName | BirthDate
---------+-----------+-----------+------------
       5 | Кириченко | Ирина     | 1993-10-24
       8 | Валеева   | Альпина   | 1985-02-11
       6 | Ивлииев   | Александр | 1985-03-17
       4 | Нечаева   | Ксения    | 1989-05-06
       3 | Ворошилов | Алексей   | 1990-03-22
       9 | Курчатова | Светлана  | 1964-03-17
       7 | Мазуркина | Наталья   | 1981-11-15
(7 rows)


3.8.
SELECT * FROM "Avtor" WHERE POSITION('А' in "AvtorName" ) > 0;
Ищем именно большую букву А на кириллице
будет вывод
 IdAvtor | AvtorFam  | AvtorName | BirthDate
---------+-----------+-----------+------------
       3 | Ворошилов | Алексей   | 1990-03-22
       6 | Ивлииев   | Александр | 1985-03-17
       8 | Валеева   | Альпина   | 1985-02-11
(3 rows)

3.9.
меняем название столбца для вывода с помощью команды AS
SELECT "IdAvtor" AS "ID Автора", "AvtorFam", "AvtorName", "BirthDate" FROM "Avtor";
будет вывод
 ID Автора |   AvtorFam    | AvtorName | BirthDate
-----------+---------------+-----------+------------
         1 | Грушневский   | Борис     | 1986-09-04
         2 | Станиславский | Георгий   | 1981-12-31
         3 | Ворошилов     | Алексей   | 1990-03-22
         4 | Нечаева       | Ксения    | 1989-05-06
         5 | Кириченко     | Ирина     | 1993-10-24
         6 | Ивлииев       | Александр | 1985-03-17
         7 | Мазуркина     | Наталья   | 1981-11-15
         8 | Валеева       | Альпина   | 1985-02-11
         9 | Курчатова     | Светлана  | 1964-03-17
(9 rows)

