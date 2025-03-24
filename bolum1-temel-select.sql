
 1. Tüm Çalışanların Ad ve Soyadlarını Listeleyin

SELECT FirstName, LastName
FROM Person.Person
WHERE PersonType = 'EM';

Bu sorgu, Person.Person tablosunda yer alan ve PersonType sütununda "EM" (Employee) olarak tanımlanmış çalışanların ad ve soyad bilgilerini getirir. WHERE ifadesi, koşul belirleyerek filtreleme sağlar.
____________________________________________________________________________________________________________
 2. İlk 10 Ürünün Adını ve Fiyatını Sıralayın
  
SELECT TOP 10 Name, ListPrice
FROM Production.Product
WHERE ListPrice > 0
ORDER BY ListPrice DESC;

Bu sorgu, liste fiyatı sıfırdan büyük olan ürünler arasından, en pahalı 10 tanesini TOP ifadesiyle seçer ve ORDER BY kullanılarak azalan düzende sıralar.

____________________________________________________________________________________________________________
 3. Farklı Ürün Renklerini Gösterin
  
SELECT DISTINCT Color
FROM Production.Product
WHERE Color IS NOT NULL;

DISTINCT ifadesi, tekrar eden kayıtları eleyerek yalnızca farklı Color değerlerini getirir. IS NOT NULL koşulu, boş (null) olan renkleri hariç tutar.

____________________________________________________________________________________________________________

4.Müşteri Tablolarında Belirli Şehirlerdeki Kişileri Sorgulayın

SELECT FirstName, LastName, City
FROM Person.Person p
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Seattle', 'Toronto');

Bu örnekte JOIN ifadeleri kullanılarak kişi bilgileri, adresler ile ilişkilendirilmiştir. IN operatörü, birden fazla koşul arasında seçim yapmayı sağlar.

____________________________________________________________________________________________________________

5. Ürün Adı "Mountain" ile Başlayanları Getirin

SELECT Name
FROM Production.Product
WHERE Name LIKE 'Mountain%';

LIKE ifadesi, belirli bir desenle eşleşen kayıtları getirir. % karakteri, herhangi bir karakter dizisini temsil eder.
___________________________________________________________________________________________________________

6. Fiyatı 500 ile 1000 Arasında Olan Ürünleri Listeleyin

SELECT Name, ListPrice
FROM Production.Product
WHERE ListPrice BETWEEN 500 AND 1000;

BETWEEN operatörü, belirtilen iki değer arasındaki kayıtları getirir. Hem alt hem de üst sınır dahildir.
