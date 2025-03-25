Bölüm Özeti:
Bu bölümde SQL Serverda veri güvenliğini sağlamak, erişimleri yönetmek, veri şifrelemek ve kullanıcı aktivitelerini izlemek için kullanılabilecek temel T-SQL yapıları üzerinde durduk. Kim neye erişebilir?Veri şifreli mi saklanıyor? Kim, ne zaman, ne yaptı?sorularının cevapları bu yapıların doğru kullanımıyla sağlanır.

1.Basit İzleme Trigger

CREATE TABLE SalesLog (
    UserName NVARCHAR(100),
    ActionTime DATETIME,
    ActionType NVARCHAR(50),
    CustomerID INT
);

CREATE TRIGGER trg_AuditInsert
ON Sales.Customer
AFTER INSERT
AS
BEGIN
    INSERT INTO SalesLog (UserName, ActionTime, ActionType, CustomerID)
    SELECT SYSTEM_USER, GETDATE(), 'INSERT', CustomerID FROM inserted;
END;


Müşteri tablosuna yeni kayıt eklendiğinde hangi kullanıcı, ne zaman, hangi veriyi girmiş loglanır.
________________________________________________________________________________________________________________________
2.Trigger ile Güncelleme İzleme

CREATE TRIGGER trg_AuditUpdate
ON Sales.Customer
AFTER UPDATE
AS
BEGIN
    INSERT INTO SalesLog (UserName, ActionTime, ActionType, CustomerID)
    SELECT SYSTEM_USER, GETDATE(), 'UPDATE', CustomerID FROM inserted;
END;

Güncellemeleri de benzer şekilde izlemek mümkündür. Gerçek senaryolarda eski ve yeni değerler de kaydedilebilir.

________________________________________________________________________________________________________________________

3.Hangi Kullanıcının Nerede Yetkisi Var?

SELECT dp.name AS PrincipalName, 
       o.name AS ObjectName, 
       p.permission_name AS Permission
FROM sys.database_permissions p
JOIN sys.objects o ON p.major_id = o.object_id
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id;

Kullanıcıların hangi tablo üzerinde hangi yetkiye sahip olduğunu görsel olarak kontrol edebilirsin.

________________________________________________________________________________________________________________________

4.Bağlı Kullanıcıyı Tespit Etmek

SELECT SYSTEM_USER AS 'SQL Login', USER_NAME() AS 'Database User';

O an oturumda olan kullanıcının login ve veritabanı kimliğini verir.











