-- DDL
DROP TABLE Acc_Type;
DROP TABLE Customers;
DROP TABLE Defaulters;
DROP TABLE Accounts;
DROP TABLE Transactions;

CREATE TABLE Acc_Type
(ID NUMBER PRIMARY KEY,
Name VARCHAR2(10),
IRate NUMBER,
GraceP NUMBER);

CREATE TABLE Customers
(ID NUMBER PRIMARY KEY,
NAME VARCHAR2(10),
DOB DATE,
Address VARCHAR2(10));

CREATE TABLE Defaulters
(CID NUMBER PRIMARY KEY,
DateOfEntry DATE,
Tp VARCHAR2(10),
CONSTRAINT FK1 FOREIGN KEY(CID) REFERENCES Customers,
CONSTRAINT CH1 CHECK (Tp IN ('Major','Minor')));

CREATE TABLE Accounts
(AccNo NUMBER PRIMARY KEY,
CID NUMBER,
Acc_type VARCHAR2(10),
OpenDt Date,
Current_Balance NUMBER,
LastDtIgiven DATE,
CONSTRAINT FK2 FOREIGN KEY(Acc_type) REFERENCES(Acc_type));

CREATE TABLE Transactions
(Dt TIMESTAMP,
AccNo NUMBER UNIQUE,
Tp VARCHAR(10),
Amount NUMBER,
CONSTRAINT PK PRIMARY KEY (Dt, AccNo),
CONSTRAINT FK3 FOREIGN KEY(AccNo) REFERENCES Accounts,
CONSTRAINT CH2 CHECK (Tp('Deposit','Withdraw')));

-- Data Insertion
INSERT INTO Acc_Type VALUES(1,'A',10,1);
INSERT INTO Acc_Type VALUES(2,'B',15,2);
INSERT INTO Acc_Type VALUES(3,'C',20,1);
INSERT INTO Acc_Type VALUES(4,'D',25,2);
INSERT INTO Acc_Type VALUES(5,'E',30,1);

INSERT INTO Customers VALUES(1,'A',12-10-1988,'Dhaka');
INSERT INTO Customers VALUES(2,'B',14-8-1988,'Dhaka');
INSERT INTO Customers VALUES(3,'C',6-7-1988,'Dhaka');
INSERT INTO Customers VALUES(4,'D',7-2-1988,'Dhaka');
INSERT INTO Customers VALUES(5,'E',8-6-1988,'Dhaka');

INSERT INTO Defaulters VALUES(1,12-5-2020,'Major');
INSERT INTO Defaulters VALUES(1,12-6-2020,'Minor');
INSERT INTO Defaulters VALUES(2,12-10-2020,'Major');
INSERT INTO Defaulters VALUES(3,12-6-2020,'Minor');
INSERT INTO Defaulters VALUES(4,12-7-2020,'Major');
INSERT INTO Defaulters VALUES(5,12-8-2020,'Minor');
INSERT INTO Defaulters VALUES(5,12-4-2020,'Minor');

INSERT INTO Accounts VALUES(10010,1,5-5-2010,200000,12-5-2020);
INSERT INTO Accounts VALUES(10020,2,6-5-2010,50000,14-8-2020);
INSERT INTO Accounts VALUES(10030,3,7-5-2010,4100,15-6-2020);
INSERT INTO Accounts VALUES(10040,4,2-5-2010,500000,16-5-2020);
INSERT INTO Accounts VALUES(10050,5,6-3-20210,36000,18-7-2020);

INSERT INTO Transacrtions VALUES(10010,12-5-2020,'Deposit');
INSERT INTO Transacrtions VALUES(10020,12-6-2020,'Withdraw');
INSERT INTO Transacrtions VALUES(10030,12-6-2020,'Withdraw');
INSERT INTO Transacrtions VALUES(10040,12-7-2020,'Deposit');
INSERT INTO Transacrtions VALUES(10050,12-4-2020,'Deposit');

-- Task A
CREATE OR REPLACE FUNCTION STATUS_EVAL(customer_id NUMBER)
RETURN VARCHAR2
IS

var_current_balance NUMBER := 0;
major_allegation NUMBER := 0;
minor_allegation NUMBER := 0;
status VARCHAR2(10);

BEGIN

SELECT Current_Balance
INTO var_current_balance
FROM Accounts
WHERE Accounts.CID = customer_id;

SELECT COUNT(Tp)
INTO major_allegation
FROM Defaulters
WHERE Defaulters.CID = customer_id AND Tp = 'Major';

SELECT COUNT(Tp)
INTO minor_allegation
FROM Defaulters
WHERE Defaulters.CID = customer_id AND Tp = 'Minor';

IF var_current_balance > 200000 AND major_allegation == 0 AND minor_allegation = 0 THEN
	status := 'VIP';
ELSIF var_current_balance <= 40000 AND var_current_balance >= 200000 AND major_allegation = 0 THEN
	status := 'IMPORTANT';
ELSIF var_current_balance <= 10000 AND var_current_balance >= 400000 AND major_allegation = 1 THEN
	status := 'Ordinary';
ELSIF major_allegation >= 3 AND minor_allegation >= 5 THEN
	status := 'Criminal';
ELSE
	status := 'Undefined';
END IF;

RETURN status;

END;
/
	
	
-- Task B
CREATE OR REPLACE PROCEDURE Update_Current_Balance (customer_id NUMBER)
IS
DaysBetween NUMBER :=0;
GP NUMBER := 0;
GP_IN NUMBER := 0;
Interest NUMBER := 0;


BEGIN
SELECT TRUNC(sysdate) - TRUNC(LastDtGiven)
INTO Days
FROM Accounts
WHERE CID = customer_id;

IF DaysBetween >= 0 AND DaysBetween <= 90 THEN
	GP := 1;
ELSIF DaysBetween >= 91 AND DaysBetween <= 180 THEN
	GP := 2;
END IF;

SELECT GrapceP, IRate
INTO GP_IN, Interest
FROM Accounts NATURAL JOIN Acc_type
WHERE Acc_type.ID = Accounts.CID AND CID = customer_id;

IF GP = GP_IN THEN
UPDATE Accounts
SET Current_Balance = (Current_Balance + Current_Balance * Interest), LastDtGiven = sysdate
WHERE CID = customer_id;

-- 30% interest increase for GP = 1
ELSIF GP = 1 THEN
UPDATE Accounts
SET Current_Balance = (Current_Balance + Current_Balance * Interest * 0.3), LastDtGiven = sysdate;
WHERE CID = customer_id;

UPDATE Acc_Type
SET GraceP = 1, IRate = IRate * 0.3
WHERE ID = customer_id;

-- 50% interest increase for GP = 2
ELSIF GP = 2 THEN
UPDATE Accounts
SET Current_Balance = (Current_Balance + Current_Balance * Interest * 0.5), LastDtGiven = sysdate
WHERE CID = customer_id;

UPDATE Acc_Type
SET GraceP = 2, IRate = IRate * 0.5
WHERE ID = customer_id;

END IF;

END;
/




