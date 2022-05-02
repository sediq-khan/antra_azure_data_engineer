USE WideWorldImporters
--SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'

--Question 1
SELECT TOP 1000 
P.FullName, P.FaxNumber AS PFaxNumber, P.PhoneNumber as PPhoneNumber, C.PhoneNumber AS CPhoneNumber, C.FaxNumber as CFaxNumber  
FROM Application.People AS P
LEFT JOIN Sales.Customers AS C
ON (P.PersonID = C.PrimaryContactPersonID) OR (P.PersonID = C.AlternateContactPersonID)
WHERE FullName NOT LIKE 'Data Conversion%';

--Question 2
SELECT P.PersonID, P.PhoneNumber, C.PrimaryContactPersonID, C.PhoneNumber, C.CustomerName FROM Sales.Customers AS C
LEFT JOIN Application.People AS P
ON C.PrimaryContactPersonID = P.PersonID
AND P.PhoneNumber = C.PhoneNumber

--Question 3
SELECT C.CustomerName FROM Sales.Customers AS C WHERE C.CustomerID IN
(
	SELECT DISTINCT(after2016transactions.CustomerID) FROM Sales.CustomerTransactions AS after2016transactions 
		WHERE after2016transactions.TransactionDate > '2016-01-01' AND after2016transactions.CustomerID NOT IN
		(
			SELECT before2016transactions.CustomerID FROM Sales.CustomerTransactions AS before2016transactions 
			WHERE before2016transactions.TransactionDate < '2016-01-01'
		)
)

--Question 4
SELECT Items.StockItemName, SUM(Transactions.Quantity) FROM Warehouse.StockItems AS Items 
LEFT JOIN Warehouse.StockItemTransactions AS Transactions
ON Items.StockItemID = Transactions.StockItemID
WHERE (Transactions.TransactionOccurredWhen >='2013-01-01' AND Transactions.TransactionOccurredWhen <'2013-12-31')
GROUP BY Items.StockItemName

--Question 5
SELECT Stocks.StockItemName, Stocks.SearchDetails FROM Warehouse.StockItems AS Stocks WHERE LEN(Stocks.SearchDetails) >= 10

--Question 7
SELECT States.StateProvinceName, AVG(DATEDIFF(day, Orders.OrderDate, Invoices.ConfirmedDeliveryTime))
AS AverageDuration FROM Sales.Invoices AS Invoices 
INNER JOIN Sales.Orders AS Orders ON (Invoices.OrderID = Orders.OrderID AND Invoices.CustomerID = Orders.CustomerID)
INNER JOIN Sales.Customers AS Customers ON Invoices.CustomerID = Customers.CustomerID
INNER JOIN Application.Cities AS Cities ON Cities.CityID = Customers.DeliveryCityID
INNER JOIN Application.StateProvinces AS States ON States.StateProvinceID = Cities.StateProvinceID
GROUP BY States.StateProvinceName;

--Question 8
SELECT States.StateProvinceName, MONTH(Invoices.ConfirmedDeliveryTime) AS DeliveryMonth,
AVG(DATEDIFF(day, Orders.OrderDate, Invoices.ConfirmedDeliveryTime))
AS AverageDuration FROM Sales.Invoices AS Invoices 
INNER JOIN Sales.Orders AS Orders ON (Invoices.OrderID = Orders.OrderID AND Invoices.CustomerID = Orders.CustomerID)
INNER JOIN Sales.Customers AS Customers ON Invoices.CustomerID = Customers.CustomerID
INNER JOIN Application.Cities AS Cities ON Cities.CityID = Customers.DeliveryCityID
INNER JOIN Application.StateProvinces AS States ON States.StateProvinceID = Cities.StateProvinceID
GROUP BY States.StateProvinceName,  MONTH(Invoices.ConfirmedDeliveryTime)
ORDER BY States.StateProvinceName, DeliveryMonth;

--Question 9
--These two queries have to be combined to get the end result.
--Names of Items and Total Purchase in 2015
SELECT TOP 1 StockItems.StockItemName, SUM(OrderLines.ReceivedOuters) AS TotalPurchase FROM Purchasing.PurchaseOrderLines AS OrderLines
INNER JOIN Warehouse.StockItems AS StockItems ON (OrderLines.StockItemID = StockItems.StockItemID)
WHERE YEAR(OrderLines.LastReceiptDate ) = 2015
GROUP BY StockItems.StockItemName
ORDER BY TotalPurchase ASC;

--Names of Items and Total Sales in 2015
SELECT TOP 1 StockItems.StockItemName, SUM(InvoiceLines.Quantity) AS TotalSale FROM Warehouse.StockItems AS StockItems
INNER JOIN Sales.InvoiceLines AS InvoiceLines ON InvoiceLines.StockItemID = StockItems.StockItemID
INNER JOIN Sales.Invoices ON InvoiceLines.InvoiceID = Sales.Invoices.InvoiceID AND YEAR(Sales.Invoices.InvoiceDate) = 2015
GROUP BY StockItems.StockItemName
ORDER BY TotalSale ASC;

--Question 10
--Partially done but not completed

-- INVOICES AND INVOICE LINES
GO
SELECT TOP 10 Invoices.CustomerID, SUM(InvoiceLines.Quantity) AS TotalMugSold FROM Sales.Invoices AS Invoices
INNER JOIN Sales.InvoiceLines AS InvoiceLines ON (Invoices.InvoiceID = InvoiceLines.InvoiceID)
INNER JOIN Sales.Customers AS Customers ON (Customers.CustomerID = Invoices.CustomerID)
INNER JOIN Sales.Customers AS CustomersPrimary ON (Customers.PrimaryContactPersonID = CustomersPrimary.CustomerID)
WHERE YEAR(Invoices.InvoiceDate) = 2016 AND InvoiceLines.Description LIKE '%mug%' 
GROUP BY Invoices.CustomerID
--HAVING TotalMugSold <= 10
GO


SELECT Warehouse.StockItems.StockItemName FROM Warehouse.StockItems WHERE Warehouse.StockItems.StockItemName LIKE '%MUG%' GROUP BY Warehouse.StockItems.StockItemName;
-- 10 mugs per person
SELECT TOP 10 
	Customers.CustomerID, Customers.CustomerName, Customers.PhoneNumber, CustomersPrimary.CustomerID AS PrimaryContactPersonID,
	CustomersPrimary.CustomerName AS PrimaryContactPersonName --, SUM(InvoiceLines.Quantity) AS TotalMugsSold 
FROM Sales.Customers AS Customers
INNER JOIN Sales.Customers AS CustomersPrimary ON (Customers.PrimaryContactPersonID = CustomersPrimary.CustomerID)
INNER JOIN Sales.Invoices as Invoices ON (Customers.CustomerID = Invoices.CustomerID) 
AND YEAR(Invoices.InvoiceDate) = 2016 AND
Invoices.InvoiceID IN 
(
	SELECT InvoiceLines.InvoiceID FROM Sales.InvoiceLines AS InvoiceLines
	WHERE InvoiceLines.Description LIKE '%mug%'
);
--INNER JOIN Sales.InvoiceLines AS InvoiceLines ON (Invoices.InvoiceID = InvoiceLines.InvoiceID)
--GROUP BY Customers.CustomerID;
--(
--	SELECT Invoices.CustomerID AS TotalMugsSold FROM Sales.Invoices AS Invoices
--	INNER JOIN Sales.InvoiceLines AS InvoiceLines 
--	ON (Invoices.InvoiceID = InvoiceLines.InvoiceID) 
--	WHERE YEAR(Invoices.InvoiceDate) = 2016 AND InvoiceLines.Description LIKE '%mug%'
--	GROUP BY Invoices.CustomerID
--	HAVING InvoiceLines.Quantity <=10
--);


--still not working
SELECT TOP 10 
	Customers.CustomerID, Customers.CustomerName, Customers.PhoneNumber, CustomersPrimary.CustomerID AS PrimaryContactPersonID,
	CustomersPrimary.CustomerName AS PrimaryContactPersonName --, SUM(InvoiceLines.Quantity) AS TotalMugsSold 
FROM Sales.Customers AS Customers
INNER JOIN Sales.Customers AS CustomersPrimary ON (Customers.PrimaryContactPersonID = CustomersPrimary.CustomerID)
INNER JOIN Sales.Invoices as Invoices ON (Customers.CustomerID = Invoices.CustomerID)
INNER JOIN Sales.InvoiceLines AS InvoiceLines ON (Invoices.InvoiceID = InvoiceLines.InvoiceID)
WHERE YEAR(Invoices.InvoiceDate) = 2016 AND InvoiceLines.Description LIKE '%mug%';
--GROUP BY Customers.CustomerID;
--(
--	SELECT Invoices.CustomerID AS TotalMugsSold FROM Sales.Invoices AS Invoices
--	INNER JOIN Sales.InvoiceLines AS InvoiceLines 
--	ON (Invoices.InvoiceID = InvoiceLines.InvoiceID) 
--	WHERE YEAR(Invoices.InvoiceDate) = 2016 AND InvoiceLines.Description LIKE '%mug%'
--	GROUP BY Invoices.CustomerID
--	HAVING InvoiceLines.Quantity <=10
--);
-- still not working
SELECT TOP 10 
	Customers.CustomerID , Customers.CustomerName, Customers.PhoneNumber, CustomersPrimary.CustomerID AS PrimaryContactPersonID,
	CustomersPrimary.CustomerName AS PrimaryContactPersonName --, COUNT(InvoiceLines.Quantity) AS TotalMugsSold 
FROM Sales.Customers AS Customers
INNER JOIN Sales.Customers AS CustomersPrimary ON (Customers.PrimaryContactPersonID = CustomersPrimary.CustomerID)
INNER JOIN Sales.Invoices AS Invoices ON (Customers.CustomerID = Invoices.CustomerID) WHERE Customers.CustomerID IN
(
	SELECT Invoices.CustomerID, SUM(InvoiceLines.Quantity) AS TotalMugsSold FROM Sales.Invoices AS Invoices
	INNER JOIN Sales.InvoiceLines AS InvoiceLines 
	ON (Invoices.InvoiceID = InvoiceLines.InvoiceID) 
	WHERE YEAR(Invoices.InvoiceDate) = 2016 AND InvoiceLines.Description LIKE '%mug%'
	GROUP BY Invoices.CustomerID
	--HAVING InvoiceLines.Quantity <=10
);
--GROUP BY Customers.CustomerID
--HAVING InvoiceLines.Quantity <=10;


-- still not working
SELECT TOP 10 
	Customers.CustomerID , Customers.CustomerName, Customers.PhoneNumber, CustomersPrimary.CustomerID AS PrimaryContactPersonID,
	CustomersPrimary.CustomerName AS PrimaryContactPersonName --, COUNT(InvoiceLines.Quantity) AS TotalMugsSold 
FROM Sales.Customers AS Customers
INNER JOIN Sales.Customers AS CustomersPrimary ON (Customers.PrimaryContactPersonID = CustomersPrimary.CustomerID)
WHERE Customers.CustomerID IN
(
	SELECT Invoices.CustomerID, SUM(InvoiceLines.Quantity) AS TotalMugsSold FROM Sales.Invoices AS Invoices
	INNER JOIN Sales.InvoiceLines AS InvoiceLines 
	ON (Invoices.InvoiceID = InvoiceLines.InvoiceID) 
	WHERE YEAR(Invoices.InvoiceDate) = 2016 AND InvoiceLines.Description LIKE '%mug%'
	GROUP BY Invoices.CustomerID
	--HAVING InvoiceLines.Quantity <=10
);
--GROUP BY Customers.CustomerID
--HAVING InvoiceLines.Quantity <=10;

-- works but 10 mugs per person is not taken into consideration
SELECT TOP 10 
	Customers.CustomerID , Customers.CustomerName, Customers.PhoneNumber, CustomersPrimary.CustomerID AS PrimaryContactPersonID,
	CustomersPrimary.CustomerName AS PrimaryContactPersonName --, COUNT(InvoiceLines.Quantity) AS TotalMugsSold 
FROM Sales.Customers AS Customers
LEFT JOIN Sales.Customers AS CustomersPrimary ON (Customers.PrimaryContactPersonID = CustomersPrimary.CustomerID)
WHERE Customers.CustomerID IN
(
	SELECT Invoices.CustomerID FROM Sales.Invoices AS Invoices
	WHERE YEAR(Invoices.InvoiceDate) = 2016 AND Invoices.InvoiceID IN
	(
		SELECT InvoiceLines.InvoiceID FROM Sales.InvoiceLines InvoiceLines WHERE InvoiceLines.Description LIKE '%mug%'
	)
)

INNER JOIN Sales.Invoices AS Invoices ON (Customers.CustomerID = Invoices.CustomerID)
INNER JOIN Sales.InvoiceLines AS InvoiceLines ON (Invoices.InvoiceID = InvoiceLines.InvoiceID AND InvoiceLines.Description LIKE '%mug%')
WHERE YEAR(Invoices.InvoiceDate) = 2016
--GROUP BY Customers.CustomerID
--HAVING InvoiceLines.Quantity <=10;

--Question 10
SELECT * FROM Application.Cities FOR SYSTEM_TIME AS OF '2015-01-01 00:00:00';

--Question 15
SELECT * FROM Sales.Orders AS Orders
WHERE Orders.OrderID in
(
	SELECT Invoices.OrderID FROM Sales.Invoices AS Invoices
	WHERE JSON_QUERY(Invoices.ReturnedDeliveryData, '$."Events"') LIKE N'%not present%'
)


