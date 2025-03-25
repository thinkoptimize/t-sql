1 – Temel Sorgular

“Liste fiyatı 1000in üzerinde olan ürünlerin adını ve fiyatını getir, ardından bu ürünleri üreten alt kategorilerin adını da ekle. Sonuç, fiyata göre azalan sıralansın.”

SELECT 
    p.Name AS ProductName,
    p.ListPrice,
    psc.Name AS SubcategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE p.ListPrice > 1000
ORDER BY p.ListPrice DESC;

_______________________________________________________________________________________________________________

2 - JOIN ve GROUP BY

Her müşterinin kaç sipariş verdiğini ve toplam harcamasını listele. Sadece 3’ten fazla sipariş verenleri göster

SELECT 
    c.CustomerID,
    COUNT(soh.SalesOrderID) AS OrderCount,
    SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
HAVING COUNT(soh.SalesOrderID) > 3
ORDER BY TotalSpent DESC;

_______________________________________________________________________________________________________________

3.CTE ve Window Functions

Müşterilerin siparişlerine kronolojik sıra numarası ver. Her müşterinin 2.siparişi hangisi, onu bul.

WITH RankedOrders AS (
    SELECT 
        CustomerID,
        SalesOrderID,
        OrderDate,
        ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS rn
    FROM Sales.SalesOrderHeader
)
SELECT *
FROM RankedOrders
WHERE rn = 2;

_______________________________________________________________________________________________________________

4.Stored Procedure, Transaction, Error Handling

Yeni fiyat girilen bir ürün için güncelleme işlemi yapan, ancak fiyat 0 veya negatifse işlemi iptal eden stored procedure yaz

CREATE PROCEDURE UpdateProductPriceSafe
    @ProductID INT,
    @NewPrice MONEY
AS
BEGIN
    BEGIN TRY
        IF @NewPrice <= 0
            THROW 50000, 'Geçersiz fiyat!', 1;

        BEGIN TRANSACTION;

        UPDATE Production.Product
        SET ListPrice = @NewPrice
        WHERE ProductID = @ProductID;

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
_______________________________________________________________________________________________________________

5.PIVOT, JSON, Fonksiyonlar

2013 yılında ürünlerin ay bazında toplam satışlarını pivot tablo ile göster. Aylar sütun, ürünler satır olsun.

SELECT *
FROM (
    SELECT 
        p.Name AS ProductName,
        DATENAME(MONTH, soh.OrderDate) AS SalesMonth,
        sod.LineTotal
    FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    WHERE YEAR(soh.OrderDate) = 2013
) AS SourceTable
PIVOT (
    SUM(LineTotal) FOR SalesMonth IN ([January], [February], [March], [April], [May])
) AS PivotResult;

_______________________________________________________________________________________________________________
6.CASE WHEN Örneği

müşterilerini yıllık toplam harcamalarına göre 3 farklı segmente ayırmak istiyor.Ayrıca müşteri adı, sipariş sayısı ve toplam harcaması da raporda yer alacak.
birinci → 100.000 TL ve üzeri harcayanlar
ikinci → 50.000 – 99.999 TL arası harcayanlar
ucuncu → 50.000 TL altı harcayanlar

SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS FullName,
    COUNT(soh.SalesOrderID) AS OrderCount,
    SUM(soh.TotalDue) AS TotalSpent,
    CASE 
        WHEN SUM(soh.TotalDue) >= 100000 THEN 'birinci'
        WHEN SUM(soh.TotalDue) >= 50000 THEN 'ikinci'
        ELSE 'ucuncu'
    END AS CustomerSegment
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalSpent DESC;

  
CustomerID	FullName	OrderCount	TotalSpent	CustomerSegment
11000	    Ayşe Yılmaz	12	          142,300	      birinci
11001	    Mehmet Kaya	8	            78,900	      ikinci
11002	    Zeynep Demir	3	          32,450	      ucuncu
