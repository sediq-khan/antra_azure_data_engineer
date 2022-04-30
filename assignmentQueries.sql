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




