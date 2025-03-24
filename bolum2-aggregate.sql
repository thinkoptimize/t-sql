Bölüm Özeti:
Bu bölümde, ilişkisel veritabanı yapısının temelini oluşturan JOIN ifadeleriyle birden fazla tabloyu nasıl birleştirebileceğimizi ve GROUP BY ile nasıl toplu veri analizleri yapabileceğimizi gördük. Ayrıca, HAVING ifadesi ile gruplandırılmış veriler üzerinde nasıl koşul uygulanabileceğini öğrendik. Bu sorgular, veri ambarı raporlaması ve iş zekâsı uygulamaları için temel oluşturur.

1. Sipariş Bilgilerini Müşteri Adı ile Birlikte Getirin

SELECT soh.SalesOrderID, soh.OrderDate, p.FirstName, p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;

Sipariş başlık bilgisi (SalesOrderHeader) ile müşteri bilgisi (Customer) ve kişi detayları (Person) arasında JOIN kullanılarak ilişki kurulmuştur.

_______________________________________________________________________________________________________________________

2.Her Ürünün Kategorisini Gösterin

SELECT p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID;

Ürünler ile alt kategori ve kategori tabloları arasında çok seviyeli bir JOIN ilişkisi kurulmuştur.

_______________________________________________________________________________________________________________________

3.Satılan Ürünlerin Adet ve Tutar Bilgilerini Getirin

SELECT sod.SalesOrderID, p.Name AS ProductName, sod.OrderQty, sod.LineTotal
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID;

Sipariş detayları (SalesOrderDetail) ile ürün bilgileri ilişkilendirilerek her satırdaki ürün adı ve tutarı gösterilmiştir.

_______________________________________________________________________________________________________________________

4.Müşterilerin Toplam Sipariş Sayısını Getirin

SELECT c.CustomerID, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
GROUP BY c.CustomerID;

GROUP BY, her müşteri için bir grup oluşturarak toplam sipariş sayısını hesaplamayı sağlar. COUNT fonksiyonu ile satır sayısı belirlenmiştir.

_______________________________________________________________________________________________________________________

5.Her Ürünün Ortalama Satış Tutarını Hesaplayın

SELECT p.Name AS ProductName, AVG(sod.LineTotal) AS AvgSales
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name;

AVG fonksiyonu ile her ürün için ortalama satış tutarı hesaplanmıştır. GROUP BY sayesinde ürün bazlı gruplanma sağlanmıştır.

_______________________________________________________________________________________________________________________

6.Kategori Bazında Toplam Satış Tutarını Gösterin

SELECT pc.Name AS CategoryName, SUM(sod.LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name;

Çok seviyeli JOIN ile ürünlerin kategorileri belirlenmiş, SUM fonksiyonu ile kategori başına toplam satış hesaplanmıştır.
  
_______________________________________________________________________________________________________________________

7.Yıl Bazında Sipariş Sayısını Hesaplayın

SELECT YEAR(OrderDate) AS OrderYear, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate);

Tarih alanından YEAR() fonksiyonu ile yıl bilgisi ayrıştırılmış ve GROUP BY ile yıllık bazda toplam sipariş sayısı hesaplanmıştır.

_______________________________________________________________________________________________________________________

8.Sadece 5'ten Fazla Siparişi Olan Müşterileri Gösterin

SELECT CustomerID, COUNT(SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(SalesOrderID) > 5;

HAVING ifadesi, GROUP BY sonrası filtreleme yapmak için kullanılır. WHERE yerine kullanılmaz çünkü agregat fonksiyonlar sonrası süzme gerektirir.


_______________________________________________________________________________________________________________________

