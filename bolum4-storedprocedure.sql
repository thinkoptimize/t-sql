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
3.Procedure Çağırmak

EXEC GetCustomerOrders @CustomerID = 11000;

__________________________________________________________________________________________________________________________________________
4.Basit Transaction Kullanımı

BEGIN TRANSACTION;

UPDATE Production.Product
SET ListPrice = ListPrice * 1.10
WHERE ProductSubcategoryID = 1;

COMMIT;


Bir işlem başlatılmış ve tüm sorgular başarıyla çalışırsa kalıcı hale getirilmiştir (COMMIT). Eğer hata olursa geri alınmalıdır.

__________________________________________________________________________________________________________________________________________
5.Transaction + Hata Yönetimi (TRY…CATCH)

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Production.Product
    SET ListPrice = -100 -- Hatalı değer
    WHERE ProductID = 100;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Hata oluştu: ' + ERROR_MESSAGE();
END CATCH;


Veri bütünlüğü sağlamak amacıyla, hata durumunda tüm işlem geri alınır. TRY...CATCH bloğu, SQL Serverda hata kontrolü sağlar.

__________________________________________________________________________________________________________________________________________

6.Transaction İçinde Birden Fazla İşlem

BEGIN TRANSACTION;

UPDATE Production.Product
SET SafetyStockLevel = SafetyStockLevel + 10
WHERE ProductSubcategoryID = 3;

DELETE FROM Sales.SalesOrderDetail
WHERE ProductID = 99999; -- Yoksa hata verir

COMMIT;

İşlemdeki ikinci komut başarısız olursa tüm işlem geri alınır. Transactionlar “ya hep ya hiç” prensibiyle çalışır.

__________________________________________________________________________________________________________________________________________

7.Hata Bilgilerini Detaylı Gösterme
  
BEGIN TRY
    -- Hatalı bölme
    SELECT 1 / 0;
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;

Hata bilgileri fonksiyonlar aracılığıyla detaylı şekilde yakalanabilir. Gelişmiş hata raporlama mümkündür.

__________________________________________________________________________________________________________________________________________

8.Transaction ve Hata Kontrolünü Procedure İçine Almak

CREATE PROCEDURE UpdatePriceSafe
    @ProductID INT,
    @NewPrice MONEY
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Production.Product
        SET ListPrice = @NewPrice
        WHERE ProductID = @ProductID;

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RAISERROR('İşlem başarısız oldu.', 16, 1);
    END CATCH;
END;

Hatalı güncellemelerde rollback sağlanır, ayrıca özel hata mesajı üretilebilir.

__________________________________________________________________________________________________________________________________________

9.Execution Plan Kullanımı (SSMS)

-- SSMSte bu sorguyu çalıştırmadan önce: 
-- Actual Execution Plan seçili olmalı
  
SELECT * FROM Sales.SalesOrderHeader WHERE CustomerID = 11000;

Execution Plan, sorgunun SQLServer tarafından nasıl çalıştırıldığını grafiksel olarak gösterir. Performans darboğazlarını görmeye yarar.
__________________________________________________________________________________________________________________________________________
10.Indexin Etkisini Gözlemleme

-- Örnek olarak bir index oluşturalım
CREATE NONCLUSTERED INDEX IX_Product_Name
ON Production.Product(Name);


Sorguların WHERE veya JOIN koşullarında kullanılan sütunlara index eklenmesi, büyük veri kümelerinde ciddi hız artışı sağlar.

__________________________________________________________________________________________________________________________________________

11.Kullanıcıdan gelen müşteri ID’sine göre siparişleri getiren dinamik bir yapı kur

CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        SalesOrderID,
        OrderDate,
        TotalDue
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID;
END;


EXEC GetCustomerOrders @CustomerID = 11000;

Gerçek kullanım senaryosu: Raporlama ekranlarında müşteriye özel sipariş geçmişi göstermek.
__________________________________________________________________________________________________________________________________________

12.Sadece pozitif değer girilmesine izin veren güvenli güncelleme prosedürü- Fiyat güncelleme

CREATE PROCEDURE UpdateProductPrice
    @ProductID INT,
    @NewPrice MONEY
AS
BEGIN
    IF @NewPrice <= 0
    BEGIN
        PRINT 'Geçersiz fiyat! Pozitif değer girilmelidir.';
        RETURN;
    END

    UPDATE Production.Product
    SET ListPrice = @NewPrice
    WHERE ProductID = @ProductID;

    PRINT 'Fiyat başarıyla güncellendi.';
END;

EXEC UpdateProductPrice @ProductID = 101, @NewPrice = 1500;

Güvenli uygulama örneği: CRUD işlemlerinde hata riskini azaltmak.
__________________________________________________________________________________________________________________________________________

13.Veri tutarlılığını sağlamak için işlem sırasında oluşan hatayı yakalayıp işlemi geri almak.

CREATE PROCEDURE SafeStockUpdate
    @ProductID INT,
    @NewStock INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Production.ProductInventory
        SET Quantity = @NewStock
        WHERE ProductID = @ProductID;

        -- Zorlama hata örneği: negatif stok hatası
        IF @NewStock < 0
            THROW 50001, 'Stok negatif olamaz!', 1;

        COMMIT;
        PRINT 'Stok güncellendi.';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Hata oluştu: ' + ERROR_MESSAGE();
    END CATCH;
END;


EXEC SafeStockUpdate @ProductID = 100, @NewStock = -10;

Kurumsal senaryo: Veritabanı hatalarını yöneterek veri bütünlüğünü koruma.
__________________________________________________________________________________________________________________________________________
  
14.OUT parametresi ile sorgu sonucu bir değişkene dışarıya aktarılsın.

CREATE PROCEDURE GetSalespersonTotalSales
    @SalesPersonID INT,
    @TotalSales MONEY OUTPUT
AS
BEGIN
    SELECT @TotalSales = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID = @SalesPersonID;
END;


DECLARE @Total MONEY;
EXEC GetSalespersonTotalSales @SalesPersonID = 279, @TotalSales = @Total OUTPUT;
SELECT @Total AS TotalSales;

Gelişmiş örnek: Fonksiyon benzeri çıktı üretme, prosedürü diğer işlemlerde kullanmak.


