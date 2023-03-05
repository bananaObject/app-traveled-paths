# Traveled paths
Приложение позволяет отображать текущее местоположение пользователя, сохранять пройденные маршруты и просматривать их на карте.

<h2>Оглавление</h2>

1. [Скриншоты](#%D1%81%D0%BA%D1%80%D0%B8%D0%BD%D1%88%D0%BE%D1%82%D1%8B)
2. [Демо видео](#%D0%B4%D0%B5%D0%BC%D0%BE-%D0%B2%D0%B8%D0%B4%D0%B5%D0%BE)
3. [Описание](#%D0%BE%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5)
4. [Технологии](#%D1%82%D0%B5%D1%85%D0%BD%D0%BE%D0%BB%D0%BE%D0%B3%D0%B8%D0%B8)

<div>  
<h2>Скриншоты</h2>
  
<img height="600" alt="1" src="https://user-images.githubusercontent.com/75171952/222956068-5f56d56d-411c-4d89-ba4a-8c6393203d17.png">
<img height="600" alt="2" src="https://user-images.githubusercontent.com/75171952/222956070-207b60c4-7cae-422d-a26f-d951ad1a8c3e.png">
<img height="600" alt="3" src="https://user-images.githubusercontent.com/75171952/222956072-50a836fb-e5b0-447d-8c29-8a40108d56c8.png">
<img height="600" alt="4" src="https://user-images.githubusercontent.com/75171952/222956073-be29b9fd-7b50-4712-ae8d-729be7e6ddbd.png">
<img height="600" alt="5" src="https://user-images.githubusercontent.com/75171952/222956074-d91d7971-f2f6-46be-9896-5bdbefc7f87d.png">

<h2>Демо видео</h2>
<details>
  <summary><h2>Видео (Кликнуть чтоб увидеть)</h2></summary>
<b>Регистрация и авторизация</b>
  
video |
:-: |
<video src='https://user-images.githubusercontent.com/75171952/222959632-bf4190d6-1907-4db8-b064-e751060c4ccb.mov'/>  |
  
<b>Просмотр пройденных маршрутов из локальной базы данных</b>

video | video
:-: | :-:
<video src='https://user-images.githubusercontent.com/75171952/222960636-97b8d726-ca1f-4f2c-b2bd-5cdec791e63b.mov'/> |  <video src='https://user-images.githubusercontent.com/75171952/222960808-30b65b5c-6d99-4745-a7e6-aed181353237.mov'/>
 
<b>Отслеживание местоположения | Сохранение пройденного пути</b>

video | video | video
:-: | :-: | :-: 
<video src='https://user-images.githubusercontent.com/75171952/222959928-70724266-e295-4707-a635-00a87ce7b69c.mov'/> | <video src='https://user-images.githubusercontent.com/75171952/222959636-7edfd9dc-bb99-4b32-ad5a-e19df1e69f71.mov'/> | <video src='https://user-images.githubusercontent.com/75171952/222960230-2d10a9d8-075c-423e-aab8-836aad0d6372.mov'/> 
</details>
</div>

## Описание

Поддерживает **iOS 13 и выше**. Для работы приложения используются **CoreLocation** и **Google Map**.

**В свернутом режиме приложение скрывает информацию на экране, но продолжает отслеживать маршрут пользователя**, если функция отслеживания запущена.

Для обеспечения безопасности данных **реализована регистрация и авторизация пользователей**. Идентификаторы пользователей и пройденные маршруты **сохраняются в локальной базе данных приложения**, а данные для авторизации пользователей **хранятся в защищенном пространстве Keychain**.

Для обновления данных и их отображения на экране **частично используется реактивное программирование с использованием фреймворка Combine**.

В качестве примера в приложении реализованы следующие функции:
- **Локальное пуш уведомление**, которое напоминает пользователю о необходимости запуска приложения, если оно не было использовано в течение определенного времени (каждые 10 минут).
- Навигация в приложении реализована с помощью **паттерна Coordinator**.

***При первом запуске приложения требуется ввести API-ключ от Google Maps для работы карты. Так как исходный код приложения доступен в открытом репозитории**, не безопасно хранить API-ключ от карт в приложении. Ключ сохраняется в User Defaults, чтобы в последующие запуски приложения не требовался повторный ввод ключа. **Сохранение ключа в User Defaults является мерой для демонстрации функциональности приложения.***

# Технологии
* UIKit (UI programmatically | Auto Layout)
* MVP + Coordinator
* Google map + Core location
* Combine 
* Realm swift (Database)
* Background mode
* Keychain
* Local push notification (в качестве примера)
