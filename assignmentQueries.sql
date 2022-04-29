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







