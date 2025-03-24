Bölüm Özeti:
Bu bölümde, T-SQLde kurumsal uygulamalar için önemli olan:Stored Procedure (kodun kapsüllenmesi ve tekrar kullanılabilirlik) Transaction (veri bütünlüğü ve güvenliği) Hata Yönetimi (TRY…CATCH ile sağlam yapı kurma)v Performans Analizi (Execution Plan, Index, STATISTICS) konularını ele aldık. Artık sadece veriyi sorgulamakla kalmayıp, onu profesyonel düzeyde güvenli ve verimli şekilde yönetebileceksin.

1. Basit Stored Procedure Oluşturma
  
CREATE PROCEDURE GetTopProducts
AS
BEGIN
    SELECT TOP 5 Name, ListPrice
    FROM Production.Product
    WHERE ListPrice > 0
    ORDER BY ListPrice DESC;
END;

Tekrar tekrar çalıştırılabilir bir sorgu olarak tanımlanmıştır. Uygulamalar bu prosedürü çağırarak aynı sorguyu yeniden kullanabilir.

__________________________________________________________________________________________________________________________________________
2.Parametre Alan Procedure

CREATE PROCEDURE GetCustomerOrders @CustomerID INT
AS
BEGIN
    SELECT SalesOrderID, OrderDate, TotalDue
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID;
END;

Kullanıcının verdiği müşteri numarasına göre siparişleri döndürür. Parametreli prosedürler genellikle kullanıcıya özel veri çekmek için kullanılır.

__________________________________________________________________________________________________________________________________________
