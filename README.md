# Описание проекта stockmann.ru #

## Основная  информация

#### Code style
- С логами и настройками сайта мы работаем только через DI: 

`\Aero\Tools\Module::initContainer (www/local/modules/aero.tools/lib/module.php:109)`

  Напрямую обращаться в коде к `Registry::getInstance(), new AeroSettingsConfig()` не допускается!
  
  Пример получения настроек из DI в вашем коде:
  
 - `\Aero\Tools\Module::$DI->get('SftpLogger');`
  
 - `\Aero\Tools\Module::$DI->get('MainSettings');`

#### ПО на сервере
- rar (https://rarlab.com/rar/rarlinux-x64-5.6.b5.tar.gz)

#### Сomposer
**Aero**

- aero.main
- aero.elastic
- aero.sale
- aero.bunit
- aero.rest
- aero.fias
    
**libs**

- notamedia/console-jedi
- notamedia/monolog-adapter
- php-di/php-di
- aeroidea/aeroidea.settings
- illuminate/queue
- illuminate/events
- geoip2/geoip2
    

#### Submodules

- Frontend - www/frontend


#### Порядок установки
1. Подтянуть git
2. composer update - подтянет модули и их зависимости
3. ./vendor/bin/jedi init - инициализируем консольный джедай если нужно
4. Подтягиваем с сервера composer.lock, .jedi.php, environments/ - настраиваем окружения
5. ./vendor/bin/jedi env:init dev - подтянет окружение для джедая (ключи и модули)
6. Устанавливаем модули в админке. **Сначала ставим aero.main**, только потом остальные
7. Удаляем из корня сайта файл robots.txt и под рутом в файл /etc/nginx/conf.d/#HTTP_HOST#.conf добавляем/изменяем следующую директиву:
    ```
    location = /robots.txt {
        allow 127.0.0.1;
        rewrite ^/robots.txt$ robots.php;
        access_log off;
        log_not_found off;
    }
    ```
8. Перезагружаем nginx командой systemctl restart nginx
9. выставить и проверить все задания на cron


#### gitlab ci

1. Настраиваем .gitlab-ci.yml
2. Устанавливаем и регистрирем gitlab-runer, если нужно что-то делать на сервере


#### Дополнительные PHP-расширения

1. SSH2 (pecl ssh2-1 https://pecl.php.net/package/ssh2)
2. ZIP


#### Действия после переноса на прод
1. Включить логировани входа/выхода в Главном модуле

#### Логи ####
/app/log/тип_логгера/
логи реализованы через интерфейс psr/log
Подключаются через DI

### Список заданий на cron

**Bitrix**
- */5 * * * * /usr/bin/php -f /app/www/bitrix/php_interface/cron_events.php

**Download exchange from ftp**
- */10 * * * * lftp -f /app/sync/download_exchange.x

**Download photos from ftp**
- 0 23 * * * lftp -f /app/sync/download_photos.x

**Upload archives to ftp**
- 15 * * * * lftp -f /app/sync/upload.x

**Обновляет статус 'в архиве' для Новостей и акций**
- 7 * * * * /app/www/local/modules/aero.tools/cron/updatenewsarchivestatus.sh

**Отправка задач в КЦ**
- */10 * * * * /app/www/local/modules/aero.tools/cron/sendtaskstocc.sh

**Отправка статусов в ERP**
- */8 * * * * /app/www/local/modules/aero.tools/cron/sendstatusestoerp.sh

**Очистка таблицы с дополнительными данными по заказу для старых заказов**
- 0 0 * * * /app/www/local/modules/aero.tools/cron/clearoldorderinfo.sh

**Очистка таблицы с информацией об отправленных sms**
- 30 1 */7 * * /app/www/local/modules/aero.tools/cron/clearoldsmsinfo.sh

**Преиндексируем сортировки**
- 30 4 * * * /app/www/local/modules/aero.tools/cron/reindexsort.sh

**Проверяет есть ли задания в очереди на импорт**
- 0 * * * * /app/www/local/modules/aero.tools/cron/checkqueue.sh

**Очистка таблицы с хешами пользователей(избранное, просмотренные)**
- 0 1 * * * /app/www/local/modules/aero.tools/cron/hashrevomeold.sh

**Обновление данных для shopLogistic**
- 0 2 * * * /app/www/local/modules/aero.tools/cron/updateshoplogistics.sh

**бэкапы**
- 0 3 * * * /opt/backup

**переиндексация поиска**
- 0 4 * * * /app/www/local/modules/aero.tools/cron/reindexsearch.sh

**генерация сайтмапов**
- 0 5 * * * /app/www/local/modules/aero.tools/cron/generatesitemap.sh

**генерация сайтмапа с фильтрами**
- 30 5 */3 * * /app/www/local/modules/idex.tools/cron/makesitemapfortagscloud.sh

**генерация yml файлов**
- 0 6 * * * /app/www/local/modules/aero.tools/cron/generateyml.sh

**отправка push-уведомлений**
- 0 */5 * * * REQUEST_SCHEME="http" SERVER_NAME="stockmann.aeroidea.ru" /app/www/local/modules/aero.tools/cron/checknewspush.sh

**3 скрипта от подрядчиков клиента на отправку просмотренных**
- */1 * * * * /app/www/local/modules/idex.mailgen/cron/mailgencheckbasket.sh

- */10 * * * * /app/www/local/modules/idex.mailgen/cron/mailgencheckproducts.sh

- */1 * * * * /app/www/local/modules/idex.mailgen/cron/mailgenchecksubscription.sh

**генерация yml-фидов**
- 10 * * * * /app/www/local/modules/idex.tools/cron/makexmlformerchant.sh

- 30 5 */3 * * /app/www/local/modules/idex.tools/cron/makesitemapfortagscloud.sh


## Релизы, git workflow
### Релиз спринта
Список изменений к релизу собираются в отдельной задаче, сливаем по 1 задаче.
1. Актуализируем сервер предпрода
2. Сливаем в predprod master, сливаем release(тут хотфиксы) в predprod
3. Создаем ветку от predprod releases/release-DD-MM-YY
4. Сливаем все задачи в нее, ставим тег. пишем краткое описание по задачам к коммиту.
5. Сливаем ветку в predprod, передаем в тест
6. После тестирования, сливаем в master, передаем в тест

### Релиз хотфиксов
Хотфикс это срочное исправление ошибки на проде, имеет наибольшей приоритет
1. создаем ветку с хотфиксом от master hotfix/branchname
2. Актуализируем ветку release от master
3. Сливаем ветку с хотфиксом в release
4. release в predprod, смотрим все ли работает там
5. Если все ок, release в master, тестим на бою
6. master в develop и stable