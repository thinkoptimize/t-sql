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

