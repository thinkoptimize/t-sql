Bölüm Özeti:
Bu bölümde T-SQLin gelişmiş veri işleme yeteneklerini keşfettik:PIVOT ve UNPIVOT ile veriyi döndürdük,JSON ve XML ile modern veri formatlarını işledik,Dynamic SQL ile esnek sorgular oluşturduk,View ve Function ile sorguları modüler hale getirdik.Bu araçlar sayesinde T-SQL sadece bir sorgulama dili değil, aynı zamanda güçlü bir veri işleme platformuna dönüşmektedir.

1.Satırları Sütunlara Çevirme (PIVOT)

SELECT *
FROM (
    SELECT ProductID, YEAR(OrderDate) AS SalesYear, LineTotal
    FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
) AS SourceTable
PIVOT (
    SUM(LineTotal) FOR SalesYear IN ([2011], [2012], [2013])
) AS PivotTable;


Yıllara göre ürünlerin satış tutarları sütunlara dönüştürülmüştür. PIVOT, toplu analizlerde tabloyu "Excel vari" göstermek için kullanılır.

____________________________________________________________________________________________________________________________

2.Veriyi JSON Olarak Döndürmek

SELECT SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
FOR JSON AUTO;

Sorgu sonucunu JSON formatında döndürür. Uygulamalarla veri paylaşımı için idealdir.

____________________________________________________________________________________________________________________________

3.Daha Kontrollü JSON (PATH ile)

SELECT SalesOrderID AS 'Order.OrderID', OrderDate AS 'Order.Date'
FROM Sales.SalesOrderHeader
FOR JSON PATH;


JSON PATH ile daha kontrollü bir hiyerarşi oluşturulabilir.

____________________________________________________________________________________________________________________________

4. JSON Verisini Okuma

DECLARE @json NVARCHAR(MAX) = 
'[
  { "ProductID": 1, "Price": 100 },
  { "ProductID": 2, "Price": 150 }
]';

SELECT *
FROM OPENJSON(@json)
WITH (
    ProductID INT,
    Price MONEY
);

JSON içeriği tabloya dönüştürülmüştür. OPENJSON() ile dış sistemlerden gelen veriler işlenebilir.

____________________________________________________________________________________________________________________________

5.XML Verisini Okuma

DECLARE @xml XML = '
<Products>
  <Product><ID>1</ID><Price>100</Price></Product>
  <Product><ID>2</ID><Price>200</Price></Product>
</Products>';

SELECT 
    x.value('(ID)[1]', 'INT') AS ProductID,
    x.value('(Price)[1]', 'MONEY') AS Price
FROM @xml.nodes('/Products/Product') AS T(x);

XML verisi nodes() fonksiyonu ile parçalara ayrılır ve içeriği value() ile okunur.

____________________________________________________________________________________________________________________________

6.Basit Dinamik SQL

DECLARE @sql NVARCHAR(MAX) = 
'SELECT Name, ListPrice FROM Production.Product WHERE Color = ''Red'';';
EXEC(@sql);

Dinamik SQL, sorgu içeriğinin kod içerisinde oluşturulup çalıştırılmasını sağlar.

____________________________________________________________________________________________________________________________

7.Parametreli Dinamik SQL (sp_executesql)

DECLARE @color NVARCHAR(20) = 'Black';
DECLARE @sql NVARCHAR(MAX) = 
'SELECT Name, ListPrice FROM Production.Product WHERE Color = @color';

EXEC sp_executesql @sql, N'@color NVARCHAR(20)', @color;


sp_executesql, parametreli sorguların güvenli ve performanslı bir şekilde çalışmasını sağlar.

____________________________________________________________________________________________________________________________

8.View Oluşturma (Görünümler)

CREATE VIEW vw_TopSellingProducts
AS
SELECT TOP 10 ProductID, SUM(LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY TotalSales DESC;


SELECT * FROM vw_TopSellingProducts;

VIEW, sık kullanılan bir sorgunun adlandırılmış halidir. Bir tablo gibi çağrılabilir.

____________________________________________________________________________________________________________________________

9.Scalar Function Tanımlama

CREATE FUNCTION dbo.CalcVAT (@price MONEY)
RETURNS MONEY
AS
BEGIN
    RETURN @price * 0.20;
END;

Girdi olarak fiyat alır ve %20 KDV uygular. Scalar Function tek bir değer döner.
    
SELECT Name, ListPrice, dbo.CalcVAT(ListPrice) AS VAT
FROM Production.Product;
____________________________________________________________________________________________________________________________
10.Inline Table-Valued Function

CREATE FUNCTION dbo.GetOrdersByCustomer (@CustomerID INT)
RETURNS TABLE
AS
RETURN (
    SELECT SalesOrderID, OrderDate, TotalDue
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID
);

Birden fazla satır dönen fonksiyonlardır. İçerik RETURN() ile tek sorguda verilir.

____________________________________________________________________________________________________________________________

11.Kullanıcı, belirli bir yıl seçtiğinde, o yılın ay bazında müşteri sipariş toplamlarını görmek istiyor. Ay isimleri sütun olacak, satırlar müşteri olacak. Yeni bir ay eklenirse sistem otomatik algılayacak.

Adım 1. Ayları Dinamik Sütun Olarak Oluştur
    
DECLARE @columns NVARCHAR(MAX);

SELECT @columns = STRING_AGG(QUOTENAME(MonthName), ',')
FROM (
    SELECT DISTINCT DATENAME(MONTH, OrderDate) AS MonthName
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
) AS MonthList;


Adım 2 . Dinamik PIVOT Yapısını Kur

DECLARE @sql NVARCHAR(MAX);

SET @sql = '
SELECT CustomerID, ' + @columns + '
FROM (
    SELECT CustomerID,
           DATENAME(MONTH, OrderDate) AS OrderMonth,
           TotalDue
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
) AS SourceTable
PIVOT (
    SUM(TotalDue) FOR OrderMonth IN (' + @columns + ')
) AS PivotResult
ORDER BY CustomerID;
';

EXEC sp_executesql @sql;


Çıktı Örneği:
    
CustomerID	January	   February	     March	
11000	    1200.50	     NULL	    890.00





