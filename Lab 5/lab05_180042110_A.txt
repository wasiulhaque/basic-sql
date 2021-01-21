--- DDL
CREATE TABLE Customer
(Customer_ID NUMBER PRIMARY KEY,
Name VARCHAR2(10),
Address VARCHAR2(10),
Website VARCHAR2(10),
Credit_Limit NUMBER);

CREATE TABLE Orders
(Order_ID NUMBER PRIMARY KEY,
Customer_ID NUMBER,
STATUS VARCHAR2(10),
Salesman_ID NUMBER,
Order_Date DATE,
CONSTRAINT FK1 FOREIGN KEY(Customer_ID) REFERENCES Customer);

CREATE TABLE Order_Items
(Order_ID NUMBER NOT NULL,
Item_ID NUMBER NOT NULL,
Product_ID NUMBER,
Quantity NUMBER,
Unit_Price NUMBER,
CONSTRAINT FK2 FOREIGN KEY(Order_ID) REFERENCES Orders,
PRIMARY KEY (Order_ID, Item_ID));

--- Inserting Values
INSERT INTO Customer VALUES(101,'A','Dhaka','Amazon',100);
INSERT INTO Customer VALUES(102,'B','Dhaka','Amazon',150);
INSERT INTO Customer VALUES(103,'C','Dhaka','Ebay',250);
INSERT INTO Customer VALUES(104,'D','Dhaka','Bikroy',80);
INSERT INTO Customer VALUES(105,'E','Dhaka','Amazon',265);

INSERT INTO Orders VALUES(501,101,'Shipped',901,SYSDATE);
INSERT INTO Orders VALUES(502,102,'Shipped',902,SYSDATE);
INSERT INTO Orders VALUES(503,103,'Shipped',901,SYSDATE);
INSERT INTO Orders VALUES(504,104,'Ready',904,SYSDATE);
INSERT INTO Orders VALUES(505,105,'On the Way',902,SYSDATE);

INSERT INTO Order_Items VALUES(501,1,2,10,25000);
INSERT INTO Order_Items VALUES(502,1,2,10,400);
INSERT INTO Order_Items VALUES(503,4,6,10,3600);
INSERT INTO Order_Items VALUES(504,7,9,10,6800);
INSERT INTO Order_Items VALUES(505,6,9,10,500);

--- Given View
CREATE OR REPLACE VIEW sales AS
SELECT customer_id ,
SUM ( unit_price * quantity ) total ,
ROUND (SUM ( unit_price * quantity ) * 0.05) credit
FROM order_items
INNER JOIN orders USING ( order_id )
WHERE status = ’Shipped’
GROUP BY customer_id;

SET SERVEROUTPUT ON;

--- Task 1
BEGIN
	UPDATE Customer
	SET Credit_Limit = 0;
END;
/

--- Task 2
DECLARE
Budget NUMBER := 1000000;
Total_Credit NUMBER := 0;
Revenue_Ratio NUMBER(10,2);

CURSOR C
IS
SELECT *
FROM Sales
ORDER BY Total DESC;

BEGIN
SELECT SUM(Credit) INTO Total_Credit
FROM Sales;

FOR V IN C
LOOP
Revenue_Ratio := V.credit / Total_Credit;

UPDATE Customer
SET Credit_Limit = (Budget * Revenue_Ratio)
WHERE Customer_ID = V.Customer_ID;

END LOOP;

END;
/

