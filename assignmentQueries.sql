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

--Question 16
SELECT * FROM Warehouse.StockItems AS StockItems
WHERE JSON_QUERY(StockItems.CustomFields) LIKE N'%China%'

--Question 17
SELECT 
	JSON_VALUE(StockItems.CustomFields,'$.CountryOfManufacture') AS Country,
	StockItems.StockItemName AS StockItemName, SUM(StockItemTransactions.Quantity)
FROM Warehouse.StockItems AS StockItems
INNER JOIN Warehouse.StockItemTransactions AS StockItemTransactions ON (StockItems.StockItemID = StockItemTransactions.StockItemID)
WHERE YEAR( StockItemTransactions.TransactionOccurredWhen) = 2015
GROUP BY JSON_VALUE(StockItems.CustomFields,'$.CountryOfManufacture'), StockItemName
ORDER BY JSON_VALUE(StockItems.CustomFields,'$.CountryOfManufacture'), StockItemName;

--Question 18
GO
if exists(SELECT 1 FROM SYS.views WHERE NAME='TotalStockItemSale' AND  TYPE='v')
DROP VIEW TotalStockItemSale 
GO
CREATE VIEW TotalStockItemSale AS
SELECT StockGroups.StockGroupName AS StockGroupNames , YEAR(OrderLines.PickingCompletedWhen) AS SalesYear, OrderLines.Quantity AS TotalSales 
FROM Sales.OrderLines AS OrderLines
INNER JOIN Warehouse.StockItems AS StockItems ON (OrderLines.StockItemID = StockItems.StockItemID)
INNER JOIN Warehouse.StockItemStockGroups AS StockItemStockGroups ON (StockItems.StockItemID = StockItemStockGroups.StockItemID)
INNER JOIN Warehouse.StockGroups AS StockGroups ON (StockItemStockGroups.StockGroupID = StockGroups.StockGroupID)
WHERE YEAR(OrderLines.PickingCompletedWhen) IS NOT NULL
GO
SELECT TotalStockItemSale.StockGroupNames, TotalStockItemSale.SalesYear, SUM(TotalStockItemSale.TotalSales)  
FROM TotalStockItemSale
GROUP BY TotalStockItemSale.StockGroupNames, TotalStockItemSale.SalesYear
ORDER BY TotalStockItemSale.StockGroupNames, TotalStockItemSale.SalesYear
GO

--Question 19
GO
IF EXISTS(SELECT 1 FROM SYS.views WHERE NAME='TotalStockItemSaleOrdered' AND  TYPE='v')
DROP VIEW TotalStockItemSaleOrdered
GO
CREATE VIEW TotalStockItemSaleOrdered AS
SELECT StockGroups.StockGroupName AS StockGroupNames , YEAR(OrderLines.PickingCompletedWhen) AS SalesYear, OrderLines.Quantity AS TotalSales 
FROM Sales.OrderLines AS OrderLines
INNER JOIN Warehouse.StockItems AS StockItems ON (OrderLines.StockItemID = StockItems.StockItemID)
INNER JOIN Warehouse.StockItemStockGroups AS StockItemStockGroups ON (StockItems.StockItemID = StockItemStockGroups.StockItemID)
INNER JOIN Warehouse.StockGroups AS StockGroups ON (StockItemStockGroups.StockGroupID = StockGroups.StockGroupID)
WHERE YEAR(OrderLines.PickingCompletedWhen) IS NOT NULL
GO
SELECT TotalStockItemSaleOrdered.SalesYear, TotalStockItemSaleOrdered.StockGroupNames, SUM(TotalStockItemSaleOrdered.TotalSales)  
FROM TotalStockItemSaleOrdered
GROUP BY TotalStockItemSaleOrdered.SalesYear, TotalStockItemSaleOrdered.StockGroupNames
ORDER BY TotalStockItemSaleOrdered.SalesYear, TotalStockItemSaleOrdered.StockGroupNames
GO

--Question 20
USE WideWorldImporters

IF OBJECT_ID (N'dbo.ufnCalcTotalOfInvoice', N'FN') IS NOT NULL  
    DROP FUNCTION ufnCalcTotalOfInvoice;    
GO
CREATE FUNCTION dbo.ufnCalcTotalOfInvoice(@orderID INT)  
RETURNS DECIMAL(5,2)
AS   
BEGIN  
	DECLARE @RowCnt INT;
	DECLARE @TotalUnitIntoQuanity DECIMAL(5,2)
	DECLARE @TotalTax DECIMAL(5,2)
	DECLARE @INTERIMVAL DECIMAL(5,2)
	DECLARE @Quantity DECIMAL(5,2)
	DECLARE @UnitPrice DECIMAL(5,2)
	DECLARE @TaxRate DECIMAL(5,2)
	DECLARE @TotalPrice DECIMAL(5,2)
	SET @TotalUnitIntoQuanity = 0
	SET @TotalTax = 0
	SET @TotalPrice = 0
	SELECT @RowCnt = COUNT(OrderLines.OrderLineID) FROM Sales.OrderLines AS OrderLines WHERE OrderLines.OrderID = @orderID
	WHILE @RowCnt >= 0
	BEGIN
		SELECT 
			@Quantity = OrderLines.Quantity,
			@UnitPrice = OrderLines.UnitPrice,
			@TaxRate = OrderLines.TaxRate
		FROM Sales.OrderLines AS OrderLines WHERE OrderLines.OrderID = @orderID
		SET @INTERIMVAL = (@Quantity * @UnitPrice * @TaxRate)/100
		SET @TotalTax = @TotalTax + @INTERIMVAL
		SET @TotalUnitIntoQuanity = @TotalUnitIntoQuanity + (@Quantity * @UnitPrice)
		SET @TotalPrice = @TotalPrice + @TotalTax + @TotalUnitIntoQuanity
		SET @TotalUnitIntoQuanity = 0
		SET @INTERIMVAL = 0
		SET @TotalTax = 0
		SET @RowCnt = @RowCnt - 1
	END
    RETURN @TotalPrice
END; 
GO

--Question 21
USE WideWorldImporters

-- Verify that the stored procedure does not exist.  
IF OBJECT_ID ( N'usp_InsertOrders', N'P' ) IS NOT NULL   
    DROP PROCEDURE usp_InsertOrders;

GO  
-- Create procedure to retrieve error information.  
CREATE PROCEDURE usp_InsertOrders @OrderDatePara DATE
AS  
	DECLARE @OrderDate DATE 
	SET @OrderDate = @OrderDatePara
	GO
		DROP TABLE IF EXISTS Ods.Orders
		DROP SCHEMA IF EXISTS Ods
	GO
	GO
		CREATE SCHEMA Ods
	GO
	GO
		CREATE TABLE Ods.Orders (OrderID INT NOT NULL PRIMARY KEY IDENTITY, OrderDate DATE NOT NULL, OrderTotal INT NOT NULL)
	GO
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	DECLARE @TotalOrders INT
	SELECT @TotalOrders = COUNT(Orders.OrderID) FROM Sales.Orders AS Orders WHERE Orders.OrderDate = @OrderDatePara --'''+CONVERT(nvarchar, @OrderDate)+'''
	SET XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO Ods.Orders (OrderID, OrderDate, OrderTotal)
			SELECT Orders.OrderID, Orders.OrderDate, @TotalOrders
			FROM Sales.Orders AS Orders
			WHERE Orders.OrderDate = @OrderDatePara --'''+CONVERT(nvarchar, @OrderDate)+''';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		-- Test XACT_STATE:  
        -- If 1, the transaction is committable.  
        -- If -1, the transaction is uncommittable and should   
        --     be rolled back.  
        -- XACT_STATE = 0 means that there is no transaction and  
        --     a commit or rollback operation would generate an error.  
  
		-- Test whether the transaction is uncommittable.  
		IF (XACT_STATE()) = -1  
		BEGIN  
			PRINT  
				N'The transaction is in an uncommittable state.' +  
				'Rolling back transaction.'  
			ROLLBACK TRANSACTION;  
		END;  
  
		-- Test whether the transaction is committable.
		-- You may want to commit a transaction in a catch block if you want to commit changes to statements that ran prior to the error.
		IF (XACT_STATE()) = 1  
		BEGIN  
			PRINT  
				N'The transaction is committable.' +  
				'Committing transaction.'  
			COMMIT TRANSACTION;     
		END;  
	END CATCH
GO

DECLARE @UserDate DATE
SET @UserDate = '2013-01-01'
EXECUTE usp_InsertOrders @OrderDatePara = @UserDate

--Question 22
USE WideWorldImporters

DROP TABLE IF EXISTS ods.StockItems

CREATE TABLE ods.StockItems(StockItemID INT PRIMARY KEY, StockItemName CHAR(180), SupplierID INT, ColorID INT, UnitPackageID INT, OuterPackageID INT, Brand CHAR(180), Size CHAR(180), LeadTimeDays INT, QuantityPerOuter INT, IsChillerStock BIT, Barcode CHAR(180), TaxRate DECIMAL(20,4), UnitPrice DECIMAL(20,4), RecommendedRetailPrice DECIMAL(20,2), TypicalWeightBeforeUnit DECIMAL(20,3), MarketingComments CHAR(2000), InternalComments CHAR(2000), CountryOfManufacture CHAR(180), Range INT NOT NULL, Shelflife INT NOT NULL, 	
	CONSTRAINT OuterPackages FOREIGN KEY (OuterPackageID) REFERENCES Warehouse.PackageTypes (PackageTypeID),
	CONSTRAINT UnitPackages FOREIGN KEY (UnitPackageID) REFERENCES Warehouse.PackageTypes (PackageTypeID),
	CONSTRAINT Suppliers FOREIGN KEY (SupplierID) REFERENCES Purchasing.Suppliers (SupplierID),
	CONSTRAINT Colors FOREIGN KEY (ColorID) REFERENCES Warehouse.Colors (ColorID),
);
INSERT INTO ods.StockItems
SELECT StockItemID, 
	StockItemName, 
	SupplierID, 
	ColorID, 
	UnitPackageID, 
	OuterPackageID, 
	Brand, 
	Size, 
	LeadTimeDays, 
	QuantityPerOuter, 
	IsChillerStock, 
	Barcode, 
	TaxRate, 
	UnitPrice, 
	RecommendedRetailPrice, 
	TypicalWeightPerUnit, 
	MarketingComments, 
	InternalComments, 
	JSON_VALUE(CustomFields, '$."CountryOfManufacture"'), 
	DATEDIFF(DAY, ValidFrom, ValidTo), 
	DATEDIFF(MONTH, ValidFrom, ValidTo)
FROM Warehouse.StockItems;
GO

--Question 24
USE WideWorldImporters

DECLARE @jsonInfo NVARCHAR(MAX)
DECLARE @StockItemName NVARCHAR(32)
DECLARE @Supplier INT
DECLARE @UnitPackageId INT
DECLARE @OuterPackageId INT
DECLARE @Brand NVARCHAR(32)
DECLARE @LeadTimeDays INT
DECLARE @QuantityPerOuter INT
DECLARE @TaxRate INT
DECLARE @UnitPrice DECIMAL(10,2)
DECLARE @RecommendedRetailPrice DECIMAL(10,2)
DECLARE @TypicalWeightPerUnit DECIMAL(10,2)
DECLARE @CountryOfManufacture NVARCHAR(32)
DECLARE @Range NVARCHAR(32)
DECLARE @OrderDate NVARCHAR(32)
DECLARE @DeliveryMethod NVARCHAR(32)
DECLARE @ExpectedDeliveryDate NVARCHAR(32)
DECLARE @SupplierReference NVARCHAR(32)

SET @jsonInfo=N'
{
   "PurchaseOrders":[
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"7",
         "UnitPackageId":"1",
         "OuterPackageId":"6",
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-01",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"WWI2308"
      },
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"5",
         "UnitPackageId":"1",
         "OuterPackageId":"7",
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-025",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"269622390"
      }
   ]
}';
SET @StockItemName=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].StockItemName');
SET @Supplier=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].Supplier');
SET @UnitPackageId=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].UnitPackageId');
SET @Brand=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].Brand');
SET @LeadTimeDays=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].LeadTimeDays');
SET @QuantityPerOuter=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].QuantityPerOuter');
SET @TaxRate=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].TaxRate');
SET @UnitPrice=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].UnitPrice');
SET @RecommendedRetailPrice=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].RecommendedRetailPrice');
SET @TypicalWeightPerUnit=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].TypicalWeightPerUnit');
SET @CountryOfManufacture=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].CountryOfManufacture');
SET @Range=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].Range');
SET @OrderDate=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].OrderDate');
SET @DeliveryMethod=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].DeliveryMethod');
SET @ExpectedDeliveryDate=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].ExpectedDeliveryDate');
SET @SupplierReference=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].SupplierReference');
SET @OuterPackageId=JSON_VALUE(@jsonInfo,'$.PurchaseOrders[0].OuterPackageId');

SELECT @StockItemName AS StockItemName, @Supplier AS Supplied, @UnitPackageId AS UnitePackageId,
@OuterPackageId, @Brand, @LeadTimeDays, @QuantityPerOuter, @TaxRate, @UnitPrice, @RecommendedRetailPrice,
@TypicalWeightPerUnit, @CountryOfManufacture, @Range, @OrderDate, @DeliveryMethod, @ExpectedDeliveryDate, @SupplierReference

INSERT INTO Warehouse.StockItems (StockItemName, SupplierID, UnitPackageID, OuterPackageID, Brand, LeadTimeDays, QuantityPerOuter, TaxRate,
	UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, IsChillerStock, LastEditedBy) 
	VALUES (@StockItemName, @Supplier, @UnitPackageId, @OuterPackageId, @Brand, @LeadTimeDays, @QuantityPerOuter, @TaxRate,
	@UnitPrice, @RecommendedRetailPrice, @TypicalWeightPerUnit, 1, 1)

INSERT INTO Purchasing.PurchaseOrders (SupplierID, OrderDate, DeliveryMethodID, ExpectedDeliveryDate, SupplierReference, ContactPersonID,
	IsOrderFinalized, LastEditedBy) VALUES 
	(@Supplier, @OrderDate, 1, @ExpectedDeliveryDate, @SupplierReference, 6, 1, 6)

--Question 25
--This might not work depending on the security settings of the servers
DECLARE @sql varchar(1000)
SET @sql = 'bcp "SELECT (SELECT StockGroupNames, SalesYear, SUM(TotalSales) AS TotalSale' +
    'FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER) ' +
    'FROM dbo.TotalStockItemSale AS TotalStockItemSale
GROUP BY StockGroupNames, SalesYear" ' +
    'queryout  "F:\Jobs\Azure Data Engineering\Assignment\ViewToJSON.json" ' + 
    '-c -S MACWIN2 -d WideWorldImporters -T'
EXEC sys.XP_CMDSHELL @sql

