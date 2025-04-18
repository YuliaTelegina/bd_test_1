1.1. Создаём тип данных для хранения списка из трёх магазинов
CREATE TYPE ShopEnum AS ENUM ('Магазин1', 'Магазин2', 'Магазин3');

1.2. создаём таблицу Orders
CREATE TABLE public."Orders"
(
    "IdOrder" SERIAL PRIMARY KEY,
    "IdBook" integer NOT NULL,
    "Shop" ShopEnum,
    "KolBook" integer NOT NULL,
    "DatePost" date,
    "Price" integer NOT NULL

);

1.3. и 2.6. Добавляем в таблицу Orders внешний ключ для связи с таблицей Books
ALTER TABLE public."Orders"
ADD CONSTRAINT "IdBook" FOREIGN KEY ("IdBook")
REFERENCES public."Books" ("IdBook") MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;

1.4. Создаём функцию для того чтобы сигнализировать менеджеру триггеров о пропуске остальной части операции для этой строки (то есть последующие триггеры не запускаются, и операция INSERT/UPDATE/DELETE не выполняется для этой строки)

CREATE OR REPLACE FUNCTION func_before_ins_up() RETURNS TRIGGER AS $func_before_ins_up$
DECLARE
    id_set integer[];
    BEGIN
        EXECUTE
        'SELECT ARRAY_AGG("IdBook") FROM "' || TG_TABLE_NAME ||
        '" WHERE ("DatePost"::date = ''' || NEW."DatePost"::date || ''' AND "Shop" = ''' || New."Shop" || ''')
        OR ("DatePost"::date = ''' || NEW."DatePost"::date || ''' AND "Price" = ' || New."Price" || ');'
        INTO id_set;
        IF NEW."IdBook" = any (id_set) THEN
            RAISE EXCEPTION 'Невозможно добавить повторно наименование книги в эту дату: % : %!', NEW."IdBook", NEW."DatePost";
        END IF;

        RETURN NEW;
    END;

$func_before_ins_up$ LANGUAGE  plpgsql;


1.5. Создание триггера, который реагирует при событиях INSERT или UPDATE для таблицы Orders и вызывает выполнение функции func_before_ins_up с опцией BEFORE на уровне оператора, который срабатывает до того, как оператор начнет что-либо делать.

CREATE TRIGGER trigger_orders
BEFORE INSERT OR UPDATE ON public."Orders" FOR EACH ROW
EXECUTE FUNCTION func_before_ins_up ();

DROP TRIGGER trigger_books ON "Books";


1.6. Заполняем таблицу данными по заказам.
ВАЖНО! поле IdBook мы вводим вручную - и мы не можем вводить в качестве IdBook числа 2, 3 и 5 так как мы удалили записи с данными книгами в прошлой лабораторной номер 2, пункты: 3.5.2. и 3.10.2

ошибка - ERROR:  invalid input value for enum shopenum: "Магазин4"
так как чтобы вставить строку необходимо поле "Shop" заполнить одним из трёх значений: 'Магазин1', 'Магазин2', 'Магазин3', которые прописаны в созданном типе данных ShopEnum
INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(6, 'Магазин4', 25, '2024-09-12', 1450);

успешно
INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(1, 'Магазин1', 100, '2024-08-03', 300);

успешно
INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(4, 'Магазин1', 55, '2024-08-03', 400);

успешно
INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(1, 'Магазин1', 100, '2024-08-04', 300);

исключение при срабатывании триггера - потому что пробуем добавить в одну дату одно и то же наименование с одинаковой ценой, несмотря на то что магазины разные
INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(1, 'Магазин2', 100, '2024-08-04', 300);

успешно - поменяли только цену книги
INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(1, 'Магазин2', 100, '2024-08-04', 300);

далее ВСЕ успешно!
INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(6, 'Магазин2', 82, '2024-09-12', 1500);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(6, 'Магазин3', 25, '2024-09-12', 1450);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(6, 'Магазин1', 43, '2024-09-12', 1275);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(7, 'Магазин1', 88, '2024-09-15', 570);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(7, 'Магазин1', 21, '2024-09-17', 570);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(7, 'Магазин3', 65, '2024-09-17', 670);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(8, 'Магазин2', 34, '2024-09-19', 1093);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(8, 'Магазин3', 34, '2024-09-19', 1100);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(9, 'Магазин3', 64, '2024-09-19', 740);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(9, 'Магазин3', 21, '2024-09-21', 740);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(10, 'Магазин2', 55, '2024-09-23', 510);

INSERT INTO "Orders" ("IdBook", "Shop", "KolBook", "DatePost", "Price") VALUES
(10, 'Магазин2', 78, '2024-09-24', 510);

2.1. Запрос на выборку количесвта книг в каждом магазине - номенклатура
SELECT "Shop" AS "Магазин", COUNT("IdBook") AS "КоличествоНаименований" FROM "Orders" GROUP BY "Shop";

2.2.   Для каждого наименования книги вывести количество магази-
нов, в которые она поступала
DISTINCT с функцией COUNT() для подсчета только уникальных значений

SELECT "Orders"."IdBook","BookName" AS "НазваниеКниги", COUNT(DISTINCT "Shop") AS "КоличествоМагазинов"  FROM "Orders"
LEFT JOIN "Books" ON "Orders"."IdBook" = "Books"."IdBook"
GROUP BY "Orders"."IdBook", "BookName";

2.3. Для каждой книги вывести общее количество книг, переданных в магазины и сумму.
Так как в разных заказах фигурируют разные суммы за одну книгу, то чтобы найти общую сумму за все книги необходимо сначала вычислить среднюю стоимость одной книги, которую потом умножить на общее количество книг.
SELECT "Orders"."IdBook","BookName" AS "НазваниеКниги", SUM("KolBook") AS "Количество Книг", ROUND( SUM("KolBook") * AVG("Price"), 2) AS "Сумма (руб)"  FROM "Orders"
LEFT JOIN "Books" ON "Orders"."IdBook" = "Books"."IdBook"
GROUP BY "Orders"."IdBook", "BookName";

2.4.1. Выборка последних трёх наименований книг, поставленных в магазины, результат запроса сохраняется во временную таблицу "tempSnapshot".
Запрос на выборку возвращает не последние три заказа по дате, а именно выбирает последние три разные книги, которые были поставлены.

CREATE TEMPORARY TABLE "tempSnapshot" AS
SELECT * FROM (
SELECT DISTINCT ON ("Orders"."IdBook") "Orders"."IdBook", "Books"."BookName" AS "НазваниеКниги", MAX("Orders"."DatePost") AS "Дата поставки" FROM "Orders"
LEFT JOIN "Books" ON "Orders"."IdBook" = "Books"."IdBook"
GROUP BY "Orders"."IdBook", "Books"."BookName"
)
ORDER BY "Дата поставки" DESC LIMIT 3;

2.4.2. Проверяем что временная таблица существует - выводим список всех таблиц текущей БД.
\dt

2.4.3. Запрос на выборку всех записей из временной таблицы "tempSnapshot"
SELECT * FROM "tempSnapshot";

2.4.4. Удаление временной таблицы
DROP TABLE "tempSnapshot";

2.4.5. Проверяем что таблица "tempSnapshot" отсутствует - вновь выводим список всех таблиц текущей БД.
\dt
или любым запросом к таблице "tempSnapshot", например пробуем её повторно удалить
DROP TABLE "tempSnapshot";

2.5.
SELECT * FROM "Orders" WHERE "Price" > 500  EXCEPT SELECT *  FROM "Orders" GROUP BY "IdOrder" HAVING "KolBook" * "Price" > 50000;

2.6. - связь между таблицами внешним ключом выполнена в пункте 1.3.

2.7.1. Попытка удалить книгу с IdBook равным 1 из таблицы "Books" приводит к ошибке так как в таблице "Orders" существуют заказы, ссылающиеся на книгу с IdBook равным 1
Данная ошибка возникает в связи с тем что внешний ключ в таблице "Orders" имеет ограничения ON DELETE и ON UPDATE равные NO ACTION, которые проверяются в конце транзакции. Если выявляется нарушение связи, транзакция откатывается.

DELETE FROM "Books" WHERE "IdBook" = 1;
ERROR:  update or delete on table "Books" violates foreign key constraint "IdBook" on table "Orders"
DETAIL:  Key (IdBook)=(1) is still referenced from table "Orders".

2.7.2. Для автоматического удаления связанных с книгой заказов необходимо ограничения ON DELETE и ON UPDATE сделать равными CASCADE.

Вначале удалим существующее ограничение внешнего ключа в таблице "Orders"

ALTER TABLE "Orders"
DROP CONSTRAINT "IdBook";

Далее добавим ограничение внешенго ключа вновь, используя значение CASCADE для ограничений ON DELETE и ON UPDATE
ALTER TABLE public."Orders"
ADD CONSTRAINT "IdBook" FOREIGN KEY ("IdBook")
REFERENCES public."Books" ("IdBook") MATCH SIMPLE
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID;

2.7.3. Перед тестированием автоматического удаления заказов из таблицы "Orders" при удалении книги из таблицы "Books" выводим все записи таблицы "Orders"
SELECT * FROM "Orders";

2.7.4. Удаляем из таблицы "Books" книгу с IdBook равным 1
DELETE FROM "Books" WHERE "IdBook" = 1;

Удаление происходит без ошибки.

2.7.5. Проверяем удалились ли заказы из таблицы "Orders", в которых IdBook  был равен 1.

SELECT * FROM "Orders";
Заказы были успешно удалены.

2.8. DELETE FROM "Orders" WHERE "IdBook" = 4;
Удаление успешно - ошибок нет.

2.9.1. Создаём представление viewOrders, в которое помещаем резултат запроса на выборку. Представление является вычисляемым и информация в представлении не хранится физически отдельно в БД.

CREATE VIEW "viewOrders" AS
SELECT "IdOrder" AS "Номер Заказа", "KolBook" AS "количество книг", "Price" * "KolBook" AS "Общая стоимость"
FROM "Orders";


2.9.2. Выводим всю записи из представления "viewOrders"
SELECT * FROM "viewOrders";


2.10.1. Создаём представление для авторов, у которых в фамилии или имени присутствует буква "A" или которые родились позже 01 января 1985 года.
CREATE VIEW "viewAvtor" AS
SELECT "AvtorFam" FROM "Avtor" WHERE "BirthDate" > '1985-01-01' OR POSITION('А' in "AvtorName" ) > 0 OR POSITION('А' in "AvtorFam" ) > 0;

2.10.2.  Выводим всю записи из представления "viewAvtor"
SELECT * FROM "viewAvtor";


2.11. В PostgreSQL обобщенное табличное выражение начинается с ключевого слова WITH и размещается перед запросом. Оно описывает временные структуры данных, которым даны те или иные имена. Структуры описаны как комбинации запросов — так один сложный запрос разделяется на много более простых. Это выражение называется внутренним, оно вычисляется перед основным запросом и составляет суть CTE. После выполнения внутреннего выражения начинается основной запрос, и он обращается уже к полученной временной структуре.


WITH "cteDate" AS (
SELECT "Orders"."IdBook", "DatePost" AS "Дата поставки", SUM("KolBook") AS "Общее количество книг" FROM "Orders"
GROUP BY "Orders"."IdBook", "DatePost"
)
SELECT "BookName" AS "Название книги", "Дата поставки", "Общее количество книг" FROM "Books" JOIN "cteDate" ON "cteDate"."IdBook" = "Books"."IdBook";
