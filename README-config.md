# Полный справочник параметров app.ini для Forgejo

📁 Расположение файла
Где лежит app.ini:

Docker-установка: /data/gitea/conf/app.ini
Бинарная установка: /etc/forgejo/conf/app.ini или /var/lib/forgejo/custom/conf/app.ini

Важно: После изменения файла нужно перезапустить Forgejo (docker restart forgejo или systemctl restart forgejo).

## 🔧 Секция [server] — Настройки сервера
Параметр	По умолчанию	Описание
PROTOCOL	http	Протокол: http, https, fcgi, unix
DOMAIN	localhost	Домен сервера
ROOT_URL	http://localhost:3000/	Полный URL сервера (важно для ссылок)
HTTP_ADDR	0.0.0.0	IP адрес для прослушивания
HTTP_PORT	3000	Порт HTTP
SSH_DOMAIN	localhost	Домен для SSH
SSH_PORT	22	Порт SSH
START_SSH_SERVER	false	Запускать встроенный SSH-сервер
OFFLINE_MODE	false	Автономный режим (без внешних ресурсов)
CERT_FILE	(пусто)	Путь к SSL-сертификату
KEY_FILE	(пусто)	Путь к SSL-ключу
STATIC_ROOT_PATH	(пусто)	Путь к статическим файлам
STATIC_CACHE_TIME	6h	Время кэширования статики
ENABLE_GZIP	false	Сжимать ответы Gzip
LANDING_PAGE	home	Начальная страница: home, explore, organizations, login
LFS_START_SERVER	false	Включить Git LFS
LFS_CONTENT_PATH	data/lfs	Путь для хранения LFS-файлов
LFS_JWT_SECRET	(генерируется)	Секрет для JWT LFS
REDIRECT_OTHER_PORT	false	Перенаправлять порт 80 на HTTP_PORT
PORT_TO_REDIRECT	80	Порт для перенаправления
PERMANENT_REDIRECT	false	Постоянное перенаправление (301 vs 302)
ENABLE_ACME	false	Автоматические SSL-сертификаты через Let's Encrypt
ACME_EMAIL	(пусто)	Email для Let's Encrypt
ACME_HTTP_PORT	80	Порт для проверки Let's Encrypt

## 🗄️ Секция [database] — Настройки базы данных
Параметр	По умолчанию	Описание
DB_TYPE	sqlite3	Тип БД: sqlite3, mysql, postgres, mssql
HOST	127.0.0.1:3306	Хост и порт БД
NAME	(пусто)	Имя базы данных
USER	(пусто)	Имя пользователя БД
PASSWD	(пусто)	Пароль
SSL_MODE	disable	SSL режим: disable, require, verify-ca, verify-full
PATH	data/gitea.db	Путь к SQLite (только для sqlite3)
SQLITE_TIMEOUT	500	Таймаут SQLite (мс)
MAX_OPEN_CONNS	0	Макс. открытых соединений (0 = без лимита)
MAX_IDLE_CONNS	2	Макс. простаивающих соединений
CONN_MAX_LIFETIME	0	Время жизни соединения (сек)
LOG_SQL	false	Логировать SQL-запросы
ENABLE_LOG	true	Включить логирование БД

## 👥 Секция [service] — Основные настройки сервиса
Параметр	По умолчанию	Описание
DISABLE_REGISTRATION	false	Отключить регистрацию новых пользователей
REQUIRE_SIGNIN_VIEW	false	Требовать авторизацию для просмотра страниц
ALLOW_ONLY_EXTERNAL_REGISTRATION	false	Только внешняя регистрация (OAuth2/OpenID)
SHOW_REGISTRATION_BUTTON	true	Показывать кнопку "Регистрация"
REGISTER_EMAIL_CONFIRM	false	Требовать подтверждение email
REGISTER_MANUAL_CONFIRM	false	Ручное подтверждение администратором
ENABLE_NOTIFY_MAIL	false	Включить email-уведомления
DEFAULT_KEEP_EMAIL_PRIVATE	false	Скрывать email по умолчанию
EMAIL_DOMAIN_WHITELIST	(пусто)	Разрешённые домены email (через запятую)
EMAIL_DOMAIN_BLOCKLIST	(пусто)	Запрещённые домены email
SHOW_MILESTONES_DASHBOARD_PAGE	true	Показывать вехи на дашборде
AUTO_WATCH_NEW_REPOS	false	Автоподписка на свои репозитории
AUTO_WATCH_ON_CHANGE	false	Автоподписка при участии
DEFAULT_ORG_VISIBILITY	public	Видимость организаций: public, limited, private
DEFAULT_USER_VISIBILITY	public	Видимость профиля: public, limited, private
ALLOWED_USER_VISIBILITY_SETTINGS	public,limited,private	Доступные варианты видимости
USER_DISABLED_FEATURES	(пусто)	Отключённые функции: deletion, creation
DEFAULT_USER_IS_RESTRICTED	false	Новые пользователи сразу Restricted
ENABLE_USER_HEATMAP	true	Тепловая карта активности
ENABLE_WEBAUTHN	true	Включить WebAuthn (ключи безопасности)
DISABLE_USERS_PAGES	false	Отключить страницы пользователей
REGISTER_EMAIL_RESEND_TIME_LIMIT	24	Лимит повторной отправки письма (часы)
ENABLE_CAPTCHA	false	Включить капчу
CAPTCHA_TYPE	image	Тип капчи: image, recaptcha
RECAPTCHA_SECRET	(пусто)	Секретный ключ reCAPTCHA
RECAPTCHA_SITEKEY	(пусто)	Публичный ключ reCAPTCHA
RECAPTCHA_URL	https://www.google.com/recaptcha/	URL сервера reCAPTCHA
ACTIVE_CODE_LIVE_MINUTES	180	Время жизни кода активации (минуты)
RESET_PASSWD_CODE_LIVE_MINUTES	180	Время жизни кода сброса пароля
NO_REPLY_ADDRESS	noreply.example.org	Домен для no-reply
USER_RENAME_DISABLED	false	Запретить смену логина
CHANGE_USERNAME_EMAIL_NOTIFICATION	false	Уведомление о смене логина

## 🔐 OAuth2/OpenID параметры в [service]
Параметр	По умолчанию	Описание
ENABLE_OPENID_SIGNIN	false	Вход через OpenID
ENABLE_OPENID_SIGNUP	false	Регистрация через OpenID
OPENID_WHITELISTED_URIS	(пусто)	Белый список URI OpenID
OAUTH2_AUTO_REGISTER	false	Автосоздание пользователя через OAuth2
OAUTH2_DEFAULT_GROUP	false	Назначение группы по умолчанию

## 📧 Секция [mailer] — Настройки почты
Параметр	По умолчанию	Описание
ENABLED	false	Включить отправку почты
PROTOCOL	(пусто)	Протокол: smtp, smtps, smtp+startls, sendmail
SMTP_ADDR	(пусто)	SMTP сервер
SMTP_PORT	(пусто)	SMTP порт
USER	(пусто)	Имя пользователя SMTP
PASSWD	(пусто)	Пароль SMTP
FROM	(пусто)	Email отправителя
SUBJECT_PREFIX	(пусто)	Префикс темы письма
MAILER_TYPE	(пусто)	Тип: smtp, sendmail, dummy
SENDMAIL_PATH	sendmail	Путь к sendmail
ENABLE_HELO	true	Включить HELO
HELO_HOSTNAME	(пусто)	HELO-имя хоста
FORCE_TRUST_SERVER_CERT	false	Принимать самоподписанные сертификаты
USE_CERTIFICATE	false	Использовать клиентский сертификат
CERT_FILE	(пусто)	Файл сертификата
KEY_FILE	(пусто)	Файл ключа
ENABLE_OPEN_TRACE	false	Подробный лог SMTP
ENABLE_AUTH	true	Включить аутентификацию

## 📎 Секция [attachment] — Вложения
Параметр	По умолчанию	Описание
ENABLED	true	Включить вложения
ALLOWED_TYPES	(по умолчанию)	MIME-типы вложений
MAX_SIZE	4	Макс. размер (MB)
MAX_FILES	5	Макс. количество файлов
STORAGE_PATH	data/attachments	Путь хранения

## 🖼️ Секция [picture] — Изображения и аватары
Параметр	По умолчанию	Описание
AVATAR_UPLOAD_PATH	data/avatars	Путь для аватаров
REPOSITORY_AVATAR_UPLOAD_PATH	data/repo-avatars	Путь для аватаров репозиториев
DISABLE_GRAVATAR	false	Отключить Gravatar
ENABLE_FEDERATED_AVATAR	false	Включить федеративные аватары
GRAVATAR_SOURCE	gravatar.com	Источник Gravatar
GRAVATAR_SOURCE_URL	(пусто)	URL источника
AVATAR_RESOLUTION	80	Разрешение аватара (пикс.)
SIZE	128	Макс. размер файла аватара (KB)

## 🚀 Секция [repository] — Репозитории
Параметр	По умолчанию	Описание
ROOT	data/gitea-repositories	Корневая папка репозиториев
SCRIPT_TYPE	bash	Тип скрипта
ANSI_CHARSET	(пусто)	Кодировка ANSI
FORCE_PRIVATE	false	Все репозитории принудительно приватные
DEFAULT_PRIVATE	"last"	Приватность по умолчанию: "last", "private", "public"
DEFAULT_UNITS	(список)	Включённые модули репозитория
DISABLED_UNITS	(пусто)	Отключённые модули
MAX_CREATION_LIMIT	-1	Макс. репозиториев на пользователя (-1 = без лимита)
PREFERRED_LICENSES	(список)	Предпочтительные лицензии
DISABLE_STARS	false	Отключить звёзды
DEFAULT_BRANCH	main	Ветка по умолчанию
PULL_REQUEST_QUEUE_LENGTH	1000	Длина очереди PR
MIRROR_QUEUE_LENGTH	1000	Длина очереди зеркал

## 🎯 Секция [repository.pull-request] — Pull Request
Параметр	По умолчанию	Описание
WORK_IN_PROGRESS_PREFIXES	WIP:,[WIP]	Префиксы для WIP
DEFAULT_MERGE_STYLE	merge	Тип слияния: merge, rebase, rebase-merge, squash
ALLOWED_MERGE_STYLES	(список)	Доступные типы слияния

## 🌿 Секция [repository.issue] — Задачи (Issues)
Параметр	По умолчанию	Описание
LOCK_REASONS	(список)	Причины блокировки задач
MAX_PINNED	3	Макс. закреплённых задач

## 💬 Секция [repository.signing] — Подпись коммитов
Параметр	По умолчанию	Описание
SIGNING_KEY	(пусто)	GPG ключ для подписи
SIGNING_NAME	(пусто)	Имя подписанта
SIGNING_EMAIL	(пусто)	Email подписанта
INITIAL_COMMIT	always	Подпись первого коммита
CRUD_COMMITS	always	Подпись CRUD-коммитов
WIKI_COMMITS	never	Подпись коммитов Wiki
MERGES	always	Подпись слияний
DEFAULT_TRUST_MODEL	collaborator	Модель доверия

## 👑 Секция [admin] — Параметры администратора
Параметр	По умолчанию	Описание
DISABLE_REGULAR_ORG_CREATION	false	Запретить создание организаций обычным пользователям
DEFAULT_EMAIL_NOTIFICATIONS	enabled	Email уведомления по умолчанию

## 🌍 Секция [i18n] — Язык и локализация
Параметр	По умолчанию	Описание
LANGS	(список)	Доступные языки
NAMES	(список)	Названия языков
DEFAULT_LANG	en-US	Язык по умолчанию

## 📊 Секция [ui] — Интерфейс
Параметр	По умолчанию	Описание
EXPLORE_PAGING_NUM	20	Элементов на странице Explore
ISSUE_PAGING_NUM	10	Задач на странице
REPO_SEARCH_PAGING_NUM	10	Результатов поиска репозиториев
NOTIFY_PAGING_NUM	20	Уведомлений на странице
FEED_MAX_COMMIT_NUM	5	Коммитов в ленте
DEFAULT_THEME	auto	Тема по умолчанию
THEMES	auto,gitea,arc-green	Доступные темы
SHOW_FOOTER_TEMPLATE_LOAD_TIME	true	Показывать время загрузки
SHOW_FOOTER_POWERED_BY	true	Показывать "Powered by"

## 🔐 Секция [security] — Безопасность
Параметр	По умолчанию	Описание
INSTALL_LOCK	false	Блокировка установки (после завершения)
SECRET_KEY	(генерируется)	Секретный ключ
LOGIN_REMEMBER_DAYS	7	Дней "запомнить меня"
COOKIE_REMEMBER_NAME	gitea_incredible	Имя cookie "запомнить"
COOKIE_USERNAME	gitea_awesome	Имя cookie логина
COOKIE_SECURE	false	Secure флаг cookie
ENABLE_LOGIN_STATUS_CODE	false	Статус код при неудачном входе
MIN_PASSWORD_LENGTH	6	Мин. длина пароля
PASSWORD_COMPLEXITY	off	Сложность пароля
PASSWORD_HASH_ALGO	pbkdf2	Алгоритм хэширования паролей
INTERNAL_TOKEN	(генерируется)	Внутренний токен API
REVERSE_PROXY_AUTHENTICATION	false	Аутентификация через обратный прокси
REVERSE_PROXY_AUTHENTICATION_NAME	HTTP_REMOTE_USER	Заголовок для аутентификации

## 📦 Секция [packages] — Управление пакетами
Параметр	По умолчанию	Описание
ENABLED	true	Включить реестр пакетов
CHUNKED_UPLOAD_PATH	tmp/package-upload	Временный путь для загрузки
LIMIT_TOTAL_OWNER_COUNT	-1	Макс. пакетов на владельца
LIMIT_SIZE_ALPINE	-1	Макс. размер Alpine пакетов (MB)

## 💾 Секция [lfs] — Git LFS
Параметр	По умолчанию	Описание
STORAGE_TYPE	local	Тип хранения: local, minio
SERVE_DIRECT	false	Прямая отдача файлов
OBJECTS_BATCH_SIZE	20	Размер пакета объектов

## 📝 Секция [markdown] — Markdown
Параметр	По умолчанию	Описание
ENABLE_HARD_LINE_BREAK	false	Жёсткий перенос строк
CUSTOM_URL_SCHEMES	(список)	Пользовательские URL схемы
FILE_EXTENSIONS	(список)	Расширения для MD

## 🔄 Секция [migrations] — Миграции репозиториев
Параметр	По умолчанию	Описание
ALLOW_LOCALNETWORKS	false	Разрешить локальные сети
ALLOWED_DOMAINS	(пусто)	Разрешённые домены
SKIP_TLS_VERIFY	false	Пропустить проверку TLS
MAX_ATTEMPTS	3	Макс. попыток миграции

## ⚡ Пример полной конфигурации
ini
[server]
PROTOCOL = http
DOMAIN = git.mysite.ru
ROOT_URL = http://git.mysite.ru:3000/
HTTP_PORT = 3000

[database]
DB_TYPE = sqlite3
PATH = /data/forgejo.db

[service]
DISABLE_REGISTRATION = true
REQUIRE_SIGNIN_VIEW = true
REGISTER_EMAIL_CONFIRM = true
ENABLE_CAPTCHA = true

[mailer]
ENABLED = true
PROTOCOL = smtp
SMTP_ADDR = smtp.gmail.com
SMTP_PORT = 587
USER = my@email.com
PASSWD = password
FROM = forgejo@mysite.ru

[security]
INSTALL_LOCK = true
MIN_PASSWORD_LENGTH = 8
PASSWORD_COMPLEXITY = strong

[repository]
ROOT = /data/repositories
FORCE_PRIVATE = false
DEFAULT_PRIVATE = private

[ui]
DEFAULT_THEME = arc-green

[migrations]
ALLOW_LOCALNETWORKS = true
ALLOWED_DOMAINS = github.com,gitlab.com,bitbucket.org

## 🔄 Применение изменений
После редактирования app.ini:

bash
### Для Docker
docker restart forgejo

### Для бинарной установки с systemd
sudo systemctl restart forgejo
Проверка: Зайдите в http://ваш_сервер:3000/admin/config для просмотра текущей конфигурации.

Справочник составлен на основе Forgejo 10.x