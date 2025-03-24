
🔹 1. Tüm Çalışanların Ad ve Soyadlarını Listeleyin

SELECT FirstName, LastName
FROM Person.Person
WHERE PersonType = 'EM';

Bu sorgu, Person.Person tablosunda yer alan ve PersonType sütununda "EM" (Employee) olarak tanımlanmış çalışanların ad ve soyad bilgilerini getirir. WHERE ifadesi, koşul belirleyerek filtreleme sağlar.
----------------------------------------------------------------------
🔹 2. İlk 10 Ürünün Adını ve Fiyatını Sıralayın
  
SELECT TOP 10 Name, ListPrice
FROM Production.Product
WHERE ListPrice > 0
ORDER BY ListPrice DESC;

Bu sorgu, liste fiyatı sıfırdan büyük olan ürünler arasından, en pahalı 10 tanesini TOP ifadesiyle seçer ve ORDER BY kullanılarak azalan düzende sıralar.

---------------------------------------------------------------------------
