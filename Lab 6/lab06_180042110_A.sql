--- DDL
CREATE TABLE Branch
(Branch_ID NUMBER PRIMARY KEY,
Branch_Name VARCHAR2(10),
Address VARCHAR2(10));

CREATE TABLE Customers
(Customer_ID NUMBER PRIMARY KEY,
Name VARCHAR2(10),
DOB DATE,
Address VARCHAR2(10),
Reg_Branch NUMBER,
CONSTRAINT FK61 FOREIGN KEY(Reg_Branch) REFERENCES Branch);

CREATE TABLE Accounts
(Account_ID NUMBER(30,10) PRIMARY KEY,
Account_Type VARCHAR2(10),
Opening_Date DATE,
Customer_ID NUMBER,
Current_Balance NUMBER,
CONSTRAINT FK62 FOREIGN KEY(Customer_ID) REFERENCES Customers);

SET SERVEROUTPUT ON;

--- Task 1
CREATE OR REPLACE FUNCTION Get_Account_No(CustomerID NUMBER, AccountType VARCHAR2, BranchCode NUMBER)
RETURN NUMBER

IS
finalResult VARCHAR2(30);
vDOB VARCHAR2(10);
vAccountType VARCHAR(10);
vCustomerID NUMBER(30,20);
vReturn NUMBER(36,20);

BEGIN
SELECT TO_CHAR(DOB,'yyyymmdd') INTO vDOB
FROM Customers
WHERE Customer_ID = CustomerID;

vCustomerID := CustomerID * .000001;

IF AccountType = 'Saving'
THEN vAccountType := '10';
ElSIF AccountType = 'Current'
THEN vAccountType := '11';
END IF;

finalResult := CONCAT(CONCAT(vAccountType,BranchCode),vDOB);
vReturn := TO_NUMBER(finalResult) + vCustomerID;

RETURN vReturn;

END;
/


--- Task 2
CREATE OR REPLACE TRIGGER Generate_Account_ID
BEFORE INSERT ON Accounts
FOR EACH ROW

DECLARE
Branch NUMBER;

BEGIN

SELECT Reg_Branch INTO Branch
FROM Customers
WHERE Customer_ID = :NEW.Customer_ID;

:NEW.Account_ID := Get_Account_No(:NEW.Customer_ID,:NEW.Account_Type,Branch);

END;
/

--- Demonstration
INSERT INTO Branch VALUES(151,'Boardbazar','Gazipur');
INSERT INTO Branch VALUES(152,'Motijheel','Dhaka');
INSERT INTO Branch VALUES(153,'Mirpur','Dhaka');


INSERT INTO Customers VALUES(100001,'A',TO_DATE('2020/05/06','yyyy/dd/mm'),'Dhaka',151);
INSERT INTO Accounts(Customer_ID,Account_Type) VALUES (100001,'Saving');


INSERT INTO Customers VALUES(100002,'B',TO_DATE('2006/20/11','yyyy/dd/mm'),'Dhaka',152);
INSERT INTO Accounts(Customer_ID,Account_Type) VALUES (100002,'Current');


INSERT INTO Customers VALUES(100003,'B',TO_DATE('2004/15/12','yyyy/dd/mm'),'Dhaka',151);
INSERT INTO Accounts(Customer_ID,Account_Type) VALUES (100003,'Saving');

INSERT INTO Customers VALUES(100004,'D',TO_DATE('2017/24/06','yyyy/dd/mm'),'Dhaka',153);
INSERT INTO Accounts(Customer_ID,Account_Type) VALUES (100004,'Current');