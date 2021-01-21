--- DDL
CREATE TABLE AccountProperties(
ID NUMBER PRIMARY KEY,
Name VARCHAR2(10),
iRATE NUMBER,
GP NUMBER
CONSTRAINT GPV CHECK (GP IN (1,2,3,4,5)));

CREATE TABLE Accounts(
ID NUMBER PRIMARY KEY,
Name VARCHAR2(10),
AccCode NUMBER,
Balance NUMBER,
LastDateInterest DATE,
CONSTRAINT FK1 FOREIGN KEY(AccCode) REFERENCES AccountProperties);

--- Data Insertion
INSERT INTO AccountProperties VALUES(101,'A',5,1);
INSERT INTO AccountProperties VALUES(102,'B',5,2);
INSERT INTO AccountProperties VALUES(103,'C',5,3);
INSERT INTO AccountProperties VALUES(104,'D',5,4);
INSERT INTO AccountProperties VALUES(105,'E',5,5);

INSERT INTO Accounts VALUES(1,'A',101,100000,TO_DATE('2020/05/06','yyyy/dd/mm'));
INSERT INTO Accounts VALUES(2,'B',102,200000,TO_DATE('2020/12/06','yyyy/dd/mm'));
INSERT INTO Accounts VALUES(3,'C',103,150000,TO_DATE('2020/03/06','yyyy/dd/mm'));
INSERT INTO Accounts VALUES(4,'D',104,320000,TO_DATE('2020/02/06','yyyy/dd/mm'));
INSERT INTO Accounts VALUES(5,'E',105,400000,TO_DATE('2020/07/06','yyyy/dd/mm'));

--- Task 1.1
CREATE OR REPLACE FUNCTION calculate_profit (in_ID NUMBER)
RETURN NUMBER
IS

Balance NUMBER;
LastTrans DATE;
GP NUMBER;
iRATE NUMBER;
AccountCode NUMBER;
Profit NUMBER;

BEGIN

SELECT Balance, LastDateInterest, AccCode INTO Balance, LastTrans, AccountCode
FROM Accounts
WHERE ID = in_ID;

SELECT iRATE, GP INTO iRATE, GP
FROM AccountProperties
WHERE ID = AccountCode;

iRATE := iRATE / 100;



IF GP = 1 AND TRUNC(SYSDATE - LastTrans) >= 1 THEN
	profit := Balance * iRATE * TRUNC(SYSDATE - LastTrans);
	
ELSIF GP = 2 AND MONTHS_BETWEEN(SYSDATE,LastTrans) >= 1 THEN
	profit := Balance * iRATE * (MONTHS_BETWEEN(SYSDATE,LastTrans));

ELSIF GP = 3 AND MONTHS_BETWEEN(SYSDATE,LastTrans) >= 3 THEN
	profit := Balance * iRATE * (MONTHS_BETWEEN(SYSDATE,LastTrans)/3);
	
ELSIF GP = 4 AND MONTHS_BETWEEN(SYSDATE,LastTrans) >= 6  THEN
	profit := Balance * iRATE * (MONTHS_BETWEEN(SYSDATE,LastTrans)/6);
	
ELSIF GP = 5 AND MONTHS_BETWEEN(SYSDATE,LastTrans) >= 12 THEN
	profit := Balance * iRATE * (MONTHS_BETWEEN(SYSDATE,LastTrans)/12);
	
ELSE 
	profit := 0;
	
END IF;

RETURN profit;
END;
/

--- Task 1.2
CREATE OR REPLACE PROCEDURE updateCurrentBalance
IS

profit NUMBER;
CURSOR c

IS
SELECT * FROM Accounts;

BEGIN
FOR v IN c
LOOP
	profit := calculate_profit(v.ID);
	UPDATE Accounts SET Balance = Balance + profit, LastDateInterest = sysdate
	WHERE ID = v.ID;
END LOOP;
END;
/
