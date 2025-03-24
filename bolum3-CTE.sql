Bölüm Özeti:
  Bu bölümde, t-sql de veri analizini ileri düzeye taşıyan iki güçlü yapı olan  CTE (WITH yapısı)(yapısı) ve Window Function fonksiyonlarını öğrendik. Bu yapılar, karmaşık alt sorgulara olan ihtiyacı azaltırken performanslı ve okunabilir sorgular yazmaya olanak sağlar.
_________________________________________________________________________________________________________
1.Temel CTE Kullanımı

WITH HighValueOrders AS (
    SELECT SalesOrderID, CustomerID, TotalDue
    FROM Sales.SalesOrderHeader
    WHERE TotalDue > 10000
)
SELECT * FROM HighValueOrders;

_________________________________________________________________________________________________________

2.CTE ile Gruplama ve Filtreleme

WITH ProductSales AS (
    SELECT ProductID, SUM(LineTotal) AS TotalSales
    FROM Sales.SalesOrderDetail
    GROUP BY ProductID
)
SELECT * FROM ProductSales WHERE TotalSales > 100000;

CTE kullanarak toplulaştırma yapılmış ve sonrasında bu sonuçlar filtrelenmiştir.

_________________________________________________________________________________________________________

3.Recursive CTE ile Sayı Üretme

WITH Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numbers WHERE n < 10
)
SELECT * FROM Numbers;


Recursive CTE, kendi kendini çağırarak 1den 10a kadar sayı üretir. MAXRECURSION varsayılan değeri 100dür (gerekirse ayarlanabilir).


_________________________________________________________________________________________________________

4.Recursive CTE ile Ürün Hiyerarşisi (BOM)

WITH BOM_CTE AS (
    SELECT ProductAssemblyID, ComponentID, 1 AS Level
    FROM Production.BillOfMaterials
    WHERE ProductAssemblyID = 800

    UNION ALL

    SELECT b.ProductAssemblyID, b.ComponentID, Level + 1
    FROM Production.BillOfMaterials b
    JOIN BOM_CTE c ON b.ProductAssemblyID = c.ComponentID
)
SELECT * FROM BOM_CTE;

Malzeme ağaçları gibi yapılar için recursive CTE kullanılarak hiyerarşik veri çözümlenir.

_________________________________________________________________________________________________________

5.CTE ile İlk Sipariş Tarihini Getirme

WITH FirstOrders AS (
    SELECT CustomerID, MIN(OrderDate) AS FirstOrder
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT * FROM FirstOrders ORDER BY FirstOrder;

Her müşterinin ilk sipariş tarihi belirlenmiştir.
_________________________________________________________________________________________________________
  
6.Satışlara Sıra Numarası Verme (ROW_NUMBER)

SELECT 
    SalesOrderID, CustomerID, OrderDate,
    ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS RowNum
FROM Sales.SalesOrderHeader;


Her müşteri için siparişlerine kronolojik sıra numarası verilmiştir.

_________________________________________________________________________________________________________

7.Sıralı Değerlendirme (RANK)

SELECT 
    SalesOrderID, CustomerID, TotalDue,
    RANK() OVER(PARTITION BY CustomerID ORDER BY TotalDue DESC) AS RankInCustomer
FROM Sales.SalesOrderHeader;

Müşteri bazında yapılan siparişler, tutara göre sıralanır.

_________________________________________________________________________________________________________

8.Yoğunluk Sıralama (DENSE_RANK)

SELECT 
    ProductID, UnitPrice,
    DENSE_RANK() OVER(ORDER BY UnitPrice DESC) AS PriceRank
FROM Sales.SalesOrderDetail;

Fiyatı aynı olan ürünler aynı sırada yer alır; sıra atlaması olmaz.


9.Önceki Satırın Değerini Getirme (LAG)













