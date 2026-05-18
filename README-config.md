# Полный справочник параметров app.ini для Forgejo

## 📁 Расположение файла

**Где лежит app.ini:**

| Установка | Путь |
|-----------|------|
| Docker | `/data/gitea/conf/app.ini` |
| Бинарная (Linux) | `/etc/forgejo/conf/app.ini` |
| Бинарная (альтернатива) | `/var/lib/forgejo/custom/conf/app.ini` |
| Windows | `C:\Program Files\Forgejo\custom\conf\app.ini` |

> ⚠️ **Важно:** После изменения файла нужно перезапустить Forgejo:
> - Docker: `docker restart forgejo`
> - systemd: `sudo systemctl restart forgejo`
> - Windows: Перезапустить службу Forgejo

---

## 🔧 Секция [server] — Настройки сервера

### Основные параметры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `PROTOCOL` | `http` | Протокол подключения: `http`, `https`, `fcgi`, `unix`, `http+unix` |
| `DOMAIN` | `localhost` | Доменное имя сервера. Используется в URL ссылок и email |
| `ROOT_URL` | `http://localhost:3000/` | Полный базовый URL. **Критично** для корректной работы ссылок в письмах и API |
| `HTTP_ADDR` | `0.0.0.0` | IP-адрес для прослушивания. `0.0.0.0` = все интерфейсы, `127.0.0.1` = только локально |
| `HTTP_PORT` | `3000` | Порт HTTP-сервера. При использовании reverse proxy можно оставить 3000 |
| `LOCAL_ROOT_URL` | `http://localhost:3000/` | URL для локальных соединений (внутренние API-вызовы) |

### SSH-настройки

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `SSH_DOMAIN` | `DOMAIN` | Домен для SSH-URL. Если отличается от HTTP-домена |
| `SSH_PORT` | `22` | Порт SSH для клонирования репозиториев |
| `SSH_LISTEN_PORT` | `SSH_PORT` | Порт, который слушает встроенный SSH-сервер |
| `START_SSH_SERVER` | `false` | Запускать встроенный SSH-сервер Forgejo. `true` если не используется системный SSH |
| `SSH_ROOT_PATH` | `~/.ssh` | Путь к директории SSH-ключей |
| `SSH_SERVER_HOST_KEYS` | `~/.ssh/ssh_host_*_key` | Пути к хост-ключам SSH (через запятую) |
| `SSH_MINIMUM_KEY_SIZE_CHECK` | `true` | Проверять минимальный размер ключей |
| `SSH_MINIMUM_KEY_SIZES` | `rsa:2048,ed25519:256` | Минимальные размеры для типов ключей |

### SSL/TLS настройки

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `CERT_FILE` | *(пусто)* | Путь к SSL-сертификату для `PROTOCOL = https` |
| `KEY_FILE` | *(пусто)* | Путь к приватному SSL-ключу |
| `ENABLE_ACME` | `false` | Автоматическое получение сертификатов Let's Encrypt |
| `ACME_EMAIL` | *(пусто)* | Email для регистрации в Let's Encrypt |
| `ACME_DIR` | `certificates` | Директория для хранения ACME-сертификатов |
| `ACME_HOSTS` | *(пусто)* | Список хостов для ACME (через запятую) |
| `ACME_HTTP_PORT` | `80` | Порт для HTTP-проверки Let's Encrypt |
| `ACME_TLS_PORT` | `443` | Порт для TLS-проверки Let's Encrypt |
| `REDIRECT_OTHER_PORT` | `false` | Перенаправлять запросы с порта 80 на `HTTP_PORT` |
| `PORT_TO_REDIRECT` | `80` | Порт для перенаправления на HTTPS |
| `PERMANENT_REDIRECT` | `false` | Использовать 301 (постоянный) вместо 302 (временный) редирект |

### Производительность и режимы

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `OFFLINE_MODE` | `false` | Автономный режим: не загружать ресурсы с CDN (Gravatar, шрифты) |
| `ENABLE_GZIP` | `false` | Сжимать ответы Gzip. Рекомендуется `true` для экономии трафика |
| `STATIC_ROOT_PATH` | *(пусто)* | Путь к статическим файлам. По умолчанию встроены в бинарник |
| `STATIC_CACHE_TIME` | `6h` | Время кэширования статики в браузере |
| `LANDING_PAGE` | `home` | Страница по умолчанию: `home`, `explore`, `organizations`, `login` |
| `APP_NAME` | `Forgejo` | Название приложения (отображается в заголовке) |
| `RUN_USER` | `git` | Пользователь, от имени которого работает Forgejo |
| `RUN_MODE` | `prod` | Режим работы: `prod`, `dev`, `test` |

### Git LFS (в секции server)

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `LFS_START_SERVER` | `false` | Включить сервер Git LFS |
| `LFS_CONTENT_PATH` | `data/lfs` | Путь хранения LFS-объектов |
| `LFS_JWT_SECRET` | *(генерируется)* | Секретный ключ для JWT-аутентификации LFS |
| `LFS_MAX_BATCH_SIZE` | `0` | Макс. объектов в batch-запросе (0 = без лимита) |
| `LFS_ALLOW_PURITY_URL` | `false` | Разрешить purity:// URL для LFS |

---

## 🗄️ Секция [database] — Настройки базы данных

### Основные параметры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DB_TYPE` | `sqlite3` | Тип БД: `sqlite3`, `mysql`, `postgres`, `mssql` |
| `HOST` | `127.0.0.1:3306` | Хост и порт БД. Для SQLite не используется |
| `NAME` | *(пусто)* | Имя базы данных. Для SQLite — путь к файлу |
| `USER` | *(пусто)* | Имя пользователя БД (не для SQLite) |
| `PASSWD` | *(пусто)* | Пароль БД (не для SQLite) |
| `SSL_MODE` | `disable` | Режим SSL: `disable`, `require`, `verify-ca`, `verify-full` (PostgreSQL) |
| `PATH` | `data/gitea.db` | Путь к файлу SQLite (только для `sqlite3`) |
| `LOG_SQL` | `false` | Логировать все SQL-запросы (для отладки) |
| `ENABLE_LOG` | `true` | Включить логирование БД |

### Пул соединений

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `MAX_OPEN_CONNS` | `0` | Макс. открытых соединений (0 = без лимита) |
| `MAX_IDLE_CONNS` | `2` | Макс. простаивающих соединений в пуле |
| `CONN_MAX_LIFETIME` | `0` | Время жизни соединения в секундах (0 = без лимита) |
| `SQLITE_TIMEOUT` | `500` | Таймаут блокировки SQLite в миллисекундах |

### Примеры конфигурации

**SQLite (для небольших установок):**
```ini
[database]
DB_TYPE = sqlite3
PATH = /data/forgejo.db
```

**PostgreSQL (для продакшена):**
```ini
[database]
DB_TYPE = postgres
HOST = localhost:5432
NAME = forgejo
USER = forgejo
PASSWD = secure_password
SSL_MODE = require
MAX_OPEN_CONNS = 100
MAX_IDLE_CONNS = 10
```

**MySQL/MariaDB:**
```ini
[database]
DB_TYPE = mysql
HOST = localhost:3306
NAME = forgejo
USER = forgejo
PASSWD = secure_password
SSL_MODE = false
```

---

## 👥 Секция [service] — Основные настройки сервиса

### Регистрация и доступ

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DISABLE_REGISTRATION` | `false` | Полностью отключить регистрацию новых пользователей |
| `REQUIRE_SIGNIN_VIEW` | `false` | Требовать авторизацию для просмотра любых страниц |
| `ALLOW_ONLY_EXTERNAL_REGISTRATION` | `false` | Регистрация только через OAuth2/OpenID |
| `SHOW_REGISTRATION_BUTTON` | `true` | Показывать кнопку регистрации на странице входа |
| `REGISTER_EMAIL_CONFIRM` | `false` | Требовать подтверждение email при регистрации |
| `REGISTER_MANUAL_CONFIRM` | `false` | Ручное подтверждение аккаунта администратором |
| `REGISTER_EMAIL_RESEND_TIME_LIMIT` | `24` | Лимит повторной отправки письма подтверждения (часы) |
| `DEFAULT_KEEP_EMAIL_PRIVATE` | `false` | Скрывать email пользователя по умолчанию |
| `EMAIL_DOMAIN_WHITELIST` | *(пусто)* | Разрешённые домены email (через запятую) |
| `EMAIL_DOMAIN_BLOCKLIST` | *(пусто)* | Запрещённые домены email (через запятую) |

### Уведомления и подписки

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLE_NOTIFY_MAIL` | `false` | Включить email-уведомления о событиях |
| `AUTO_WATCH_NEW_REPOS` | `false` | Автоматически подписываться на созданные репозитории |
| `AUTO_WATCH_ON_CHANGE` | `false` | Автоматически подписываться при участии в обсуждении |
| `DEFAULT_EMAIL_NOTIFICATIONS` | `enabled` | Email-уведомления по умолчанию: `enabled`, `disabled`, `onmention` |

### Видимость и ограничения

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DEFAULT_ORG_VISIBILITY` | `public` | Видимость организаций: `public`, `limited`, `private` |
| `DEFAULT_USER_VISIBILITY` | `public` | Видимость профиля: `public`, `limited`, `private` |
| `ALLOWED_USER_VISIBILITY_SETTINGS` | `public,limited,private` | Доступные варианты видимости |
| `USER_DISABLED_FEATURES` | *(пусто)* | Отключённые функции: `deletion`, `creation`, `organization` |
| `DEFAULT_USER_IS_RESTRICTED` | `false` | Новые пользователи получают ограниченные права |
| `DISABLE_USERS_PAGES` | `false` | Отключить страницы профилей пользователей |
| `USER_RENAME_DISABLED` | `false` | Запретить пользователям менять логин |

### Активность и безопасность

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLE_USER_HEATMAP` | `true` | Показывать тепловую карту активности на профиле |
| `ENABLE_WEBAUTHN` | `true` | Включить WebAuthn (аутентификация ключами безопасности) |
| `ENABLE_CAPTCHA` | `false` | Включить капчу при регистрации |
| `CAPTCHA_TYPE` | `image` | Тип капчи: `image`, `recaptcha`, `hcaptcha`, `mcaptcha`, `cfturnstile` |
| `RECAPTCHA_SECRET` | *(пусто)* | Секретный ключ reCAPTCHA |
| `RECAPTCHA_SITEKEY` | *(пусто)* | Публичный ключ reCAPTCHA |
| `RECAPTCHA_URL` | `https://www.google.com/recaptcha/` | URL сервера reCAPTCHA |
| `SHOW_MILESTONES_DASHBOARD_PAGE` | `true` | Показывать вехи на дашборде |

### Временные параметры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ACTIVE_CODE_LIVE_MINUTES` | `180` | Время жизни кода активации аккаунта (минуты) |
| `RESET_PASSWD_CODE_LIVE_MINUTES` | `180` | Время жизни кода сброса пароля (минуты) |
| `NO_REPLY_ADDRESS` | `noreply.example.org` | Домен для no-reply email |
| `CHANGE_USERNAME_EMAIL_NOTIFICATION` | `false` | Уведомлять о смене имени пользователя |

---

## 🔐 OAuth2/OpenID параметры в [service]

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLE_OPENID_SIGNIN` | `false` | Разрешить вход через OpenID Connect |
| `ENABLE_OPENID_SIGNUP` | `false` | Разрешить регистрацию через OpenID Connect |
| `OPENID_WHITELISTED_URIS` | *(пусто)* | Белый список разрешённых OpenID-провайдеров |
| `OAUTH2_AUTO_REGISTER` | `false` | Автоматически создавать аккаунт при OAuth2-входе |
| `OAUTH2_DEFAULT_GROUP` | *(пусто)* | Назначать группу по умолчанию для OAuth2-пользователей |
| `OAUTH2_ALLOW_SIGNUP` | `true` | Разрешить регистрацию через OAuth2 |

---

## 📧 Секция [mailer] — Настройки почты

### Основные параметры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLED` | `false` | Включить отправку email (уведомления, подтверждение регистрации) |
| `PROTOCOL` | `smtp` | Протокол: `smtp`, `smtps`, `smtp+startls`, `sendmail`, `dummy` |
| `SMTP_ADDR` | *(пусто)* | Адрес SMTP-сервера (например, `smtp.gmail.com`) |
| `SMTP_PORT` | `587` | Порт SMTP-сервера (587 для TLS, 465 для SSL) |
| `USER` | *(пусто)* | Имя пользователя для аутентификации SMTP |
| `PASSWD` | *(пусто)* | Пароль или app-пароль для SMTP |
| `FROM` | *(пусто)* | Email отправителя (отображается в письмах) |
| `FROM_NAME` | `Forgejo` | Имя отправителя в письмах |
| `SUBJECT_PREFIX` | *(пусто)* | Префикс темы письма (например, `[Forgejo]`) |

### Sendmail параметры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `MAILER_TYPE` | `smtp` | Тип почтовой системы: `smtp`, `sendmail`, `dummy` |
| `SENDMAIL_PATH` | `sendmail` | Путь к исполняемому файлу sendmail |
| `SENDMAIL_ARGS` | `-t` | Аргументы для sendmail |

### SMTP настройки

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLE_HELO` | `true` | Включить HELO/EHLO приветствие |
| `HELO_HOSTNAME` | *(пусто)* | Имя хоста для HELO (по умолчанию — системное) |
| `FORCE_TRUST_SERVER_CERT` | `false` | Принимать самоподписанные SSL-сертификаты |
| `USE_CERTIFICATE` | `false` | Использовать клиентский SSL-сертификат |
| `CERT_FILE` | *(пусто)* | Путь к файлу клиентского сертификата |
| `KEY_FILE` | *(пусто)* | Путь к файлу приватного ключа |
| `ENABLE_OPEN_TRACE` | `false` | Подробное логирование SMTP-сессии (для отладки) |
| `ENABLE_AUTH` | `true` | Включить SMTP-аутентификацию |
| `DISABLE_HELO` | `false` | Отключить HELO (не рекомендуется) |
| `SKIP_VERIFY` | `false` | Пропустить проверку SSL-сертификата сервера |

### Примеры конфигурации

**Gmail:**
```ini
[mailer]
ENABLED = true
PROTOCOL = smtp+startls
SMTP_ADDR = smtp.gmail.com
SMTP_PORT = 587
USER = your-email@gmail.com
PASSWD = your-app-password
FROM = your-email@gmail.com
FROM_NAME = Forgejo Server
FORCE_TRUST_SERVER_CERT = false
```

**Office 365:**
```ini
[mailer]
ENABLED = true
PROTOCOL = smtp+startls
SMTP_ADDR = smtp.office365.com
SMTP_PORT = 587
USER = your-email@domain.com
PASSWD = your-password
FROM = your-email@domain.com
```

**Sendmail (локальная доставка):**
```ini
[mailer]
ENABLED = true
MAILER_TYPE = sendmail
SENDMAIL_PATH = /usr/sbin/sendmail
```

---

## 📎 Секция [attachment] — Вложения

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLED` | `true` | Включить прикрепление файлов к комментариям и задачам |
| `ALLOWED_TYPES` | *(список по умолчанию)* | Разрешённые MIME-типы (через запятую). `*` = все типы |
| `MAX_SIZE` | `4` | Максимальный размер одного файла (в МБ) |
| `MAX_FILES` | `5` | Максимальное количество файлов в одной загрузке |
| `STORAGE_PATH` | `data/attachments` | Путь для хранения вложений на диске |
| `STORAGE_TYPE` | `local` | Тип хранилища: `local`, `minio`, `azure` |

> **Примечание:** Для вложений рекомендуется установить `MAX_SIZE` не более 50 МБ, чтобы избежать переполнения диска.

## 🖼️ Секция [picture] — Изображения и аватары

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `AVATAR_UPLOAD_PATH` | `data/avatars` | Путь для хранения загруженных аватаров пользователей |
| `REPOSITORY_AVATAR_UPLOAD_PATH` | `data/repo-avatars` | Путь для аватаров репозиториев |
| `DISABLE_GRAVATAR` | `false` | Отключить использование Gravatar для аватаров |
| `ENABLE_FEDERATED_AVATAR` | `false` | Включить федеративные аватары (через Libravatar) |
| `GRAVATAR_SOURCE` | `gravatar.com` | Источник аватаров: `gravatar.com`, `libravatar.org` |
| `GRAVATAR_SOURCE_URL` | *(пусто)* | Пользовательский URL источника аватаров |
| `AVATAR_RESOLUTION` | `80` | Разрешение аватара в пикселях (максимальный размер отображения) |
| `SIZE` | `128` | Максимальный размер файла аватара (в КБ) |
| `AVATAR_MAX_FILE_SIZE` | `1024` | Максимальный размер загружаемого файла аватара (в КБ) |
| `ENABLE_RANDOM_AVATAR` | `false` | Генерировать случайные аватары при отсутствии Gravatar |

> **Рекомендация:** Для приватных установок установите `DISABLE_GRAVATAR = true`, чтобы не раскрывать email пользователей внешним сервисам.

## 🚀 Секция [repository] — Репозитории

### Основные параметры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ROOT` | `data/gitea-repositories` | Корневая директория для хранения Git-репозиториев |
| `SCRIPT_TYPE` | `bash` | Тип оболочки для хуков: `bash`, `sh`, `fish`, `powershell` |
| `ANSI_CHARSET` | *(пусто)* | Кодировка для ANSI-файлов (устарело) |
| `FORCE_PRIVATE` | `false` | Все создаваемые репозитории будут принудительно приватными |
| `DEFAULT_PRIVATE` | `last` | Приватность по умолчанию: `last`, `private`, `public` |
| `DEFAULT_UNITS` | *(список)* | Модули репозитория по умолчанию (issues, wiki, projects, pulls, releases, packages, actions, code) |
| `DISABLED_UNITS` | *(пусто)* | Отключённые модули для всех репозиториев |
| `MAX_CREATION_LIMIT` | `-1` | Макс. репозиториев на пользователя (-1 = без лимита) |
| `DEFAULT_BRANCH` | `main` | Название ветки по умолчанию для новых репозиториев |
| `DEFAULT_REPO_UNITS` | *(список)* | Модули, доступные по умолчанию при создании репозитория |

### Интерфейс и взаимодействие

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DISABLE_STARS` | `false` | Отключить функцию звёзд (likes) для репозиториев |
| `DEFAULT_PUSH_CREATE_PRIVATE` | `true` | Приватность репозитория при автосоздании через push |
| `PREFERRED_LICENSES` | *(список)* | Список предпочтительных лицензий при создании репозитория |
| `DISABLE_HTTP_GIT` | `false` | Отключить клонирование через HTTP(S) |
| `USE_COMPAT_SSH_URI` | `false` | Использовать совместимый формат SSH-URL |
| `GO_GET_CLONE_URL_PROTOCOL` | *(пусто)* | Протокол для go get: `http`, `https`, `ssh` |

### Очереди и обработка

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `PULL_REQUEST_QUEUE_LENGTH` | `1000` | Длина очереди задач на Pull Request |
| `MIRROR_QUEUE_LENGTH` | `1000` | Длина очереди задач для зеркалирования |
| `MIRROR_DEFAULT_INTERVAL` | `8h` | Интервал обновления зеркал по умолчанию |
| `MIRROR_MIN_INTERVAL` | `10m` | Минимальный интервал обновления зеркал |

### Git-операции

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DISABLE_GIT_HOOKS` | `false` | Запретить пользователям создавать git-хуки (для безопасности) |
| `DISABLE_PUSH_CREATE_USER` | `false` | Отключить автосоздание репозитория при push по URL |
| `DISABLE_PUSH_CREATE_ORG` | `false` | Отключить автосоздание организационного репозитория при push |
| `EDITOR_PREVIEW_LINE_NUMBERS` | `true` | Показывать номера строк в предпросмотре |

> **Важно:** `DISABLE_GIT_HOOKS = true` рекомендуется для публичных инстансов, так как пользовательские хуки могут выполнять произвольный код на сервере.

## 🎯 Секция [repository.pull-request] — Pull Request

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `WORK_IN_PROGRESS_PREFIXES` | `WIP:,[WIP]` | Префиксы заголовков PR, блокирующие слияние (через запятую) |
| `DEFAULT_MERGE_STYLE` | `merge` | Тип слияния по умолчанию: `merge`, `rebase`, `rebase-merge`, `squash` |
| `ALLOWED_MERGE_STYLES` | *(все)* | Доступные типы слияния (через запятую) |
| `DISABLE_MERGE_PULL_REQUEST` | `false` | Полностью отключить слияние PR |
| `DISABLE_REBASE_PULL_REQUEST` | `false` | Отключить rebase-слияние |
| `DISABLE_SQUASH_PULL_REQUEST` | `false` | Отключить squash-слияние |
| `DISABLE_MANUALLY_MERGED_PULL_REQUESTS` | `false` | Запретить помечать PR как "слитый вручную" |
| `DEFAULT_DELETE_BRANCH_AFTER_MERGE` | `false` | Автоматически удалять ветку после слияния PR |
| `DEFAULT_UPDATE_STYLE` | `merge` | Способ обновления ветки PR: `merge`, `rebase` |
| `PULL_REQUEST_WORK_IN_PROGRESS_REGEXES` | *(пусто)* | Регулярные выражения для определения WIP-статуса |

> **Совет:** `WORK_IN_PROGRESS_PREFIXES` позволяет предотвратить случайное слияние незавершённых PR. Если заголовок начинается с `WIP:` или `[WIP]`, кнопка слияния будет заблокирована.

## 🌿 Секция [repository.issue] — Задачи (Issues)

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `LOCK_REASONS` | `too heated,off-topic,resolved,spam` | Причины блокировки обсуждения (через запятую) |
| `MAX_PINNED` | `3` | Максимальное количество закреплённых задач на репозиторий |
| `DEFAULT_CLOSE_ISSUES` | `false` | Автоматически закрывать задачи при слиянии PR |
| `ASSUME_CLOSE_STATUS_BY_COMMITS` | `false` | Автоматически закрывать задачи по коммитам с ключевыми словами |
| `ENABLE_DEPENDENCY` | `true` | Включить зависимости между задачами |
| `ENABLE_TIMETRACKING` | `true` | Включить учёт времени в задачах |
| `DEFAULT_ENABLE_TIMETRACKING` | `true` | Учёт времени включён по умолчанию в новых репозиториях |
| `ENABLE_ISSUE_TEMPLATES` | `true` | Разрешить шаблоны задач |
| `ENABLE_COMMIT_TO_ISSUE` | `true` | Связывать коммиты с задачами по ключевым словам |

> **Ключевые слова для закрытия задач:** `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved` + номер задачи (например, `Fixes #123`).

## 💬 Секция [repository.signing] — Подпись коммитов

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `SIGNING_KEY` | `default` | GPG-ключ для подписи: `default`, `<key-id>`, или путь к ключу |
| `SIGNING_NAME` | *(пусто)* | Имя подписанта (по умолчанию — имя пользователя) |
| `SIGNING_EMAIL` | *(пусто)* | Email подписанта (по умолчанию — email пользователя) |
| `INITIAL_COMMIT` | `always` | Подпись первого коммита: `always`, `never`, `pubkey` |
| `CRUD_COMMITS` | `always` | Подпись CRUD-коммитов (создание/удаление файлов): `always`, `never`, `pubkey` |
| `WIKI_COMMITS` | `never` | Подпись коммитов Wiki: `always`, `never`, `pubkey` |
| `MERGES` | `always` | Подпись слияний: `always`, `never`, `pubkey` |
| `DEFAULT_TRUST_MODEL` | `collaborator` | Модель доверия: `collaborator`, `committer`, `collaboratorcommitter` |
| `GPG_PATH` | *(пусто)* | Путь к исполняемому файлу GPG (если не в PATH) |
| `GPG_HOME` | *(пусто)* | Домашняя директория GPG для ключей |
| `GPG_KEYSERVER` | `keyserver.ubuntu.com` | Сервер ключей для импорта публичных ключей |
| `GPG_TIMEOUT` | `60` | Таймаут GPG-операций (секунды) |

> **Модели доверия:**
> - `collaborator` — доверять подписям соавторов репозитория
> - `committer` — доверять подписям коммиттера
> - `collaboratorcommitter` — требовать совпадения обоих

## 👑 Секция [admin] — Параметры администратора

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DISABLE_REGULAR_ORG_CREATION` | `false` | Запретить обычным пользователям создавать организации (только администраторы) |
| `DEFAULT_EMAIL_NOTIFICATIONS` | `enabled` | Уведомления по умолчанию для администраторов |
| `SEND_NOTIFICATION_EMAIL_ON_NEW_USER` | `false` | Отправлять email администраторам при регистрации нового пользователя |

> **Рекомендация:** Для корпоративных установок установите `DISABLE_REGULAR_ORG_CREATION = true`, чтобы контролировать создание организаций через администраторов.

## 🌍 Секция [i18n] — Язык и локализация

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `LANGS` | `en-US,zh-CN,...` | Список доступных языков (коды через запятую) |
| `NAMES` | `English,简体中文,...` | Названия языков для отображения в UI (через запятую) |
| `DEFAULT_LANG` | `en-US` | Язык интерфейса по умолчанию |
| `SHOW_FOOTER_LANGUAGE_SWITCH` | `true` | Показывать переключатель языков в футере |
| `ALLOW_ONLY_INTERNAL_TRANSLATIONS` | `false` | Использовать только встроенные переводы (без пользовательских) |

> **Примечание:** Полный список кодов языков доступен в документации Forgejo. Порядок в `LANGS` должен соответствовать порядку в `NAMES`.

## 📊 Секция [ui] — Интерфейс

### Пагинация и отображение

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `EXPLORE_PAGING_NUM` | `20` | Количество элементов на странице Explore |
| `ISSUE_PAGING_NUM` | `10` | Задач на странице списка issues |
| `REPO_SEARCH_PAGING_NUM` | `10` | Результатов поиска репозиториев на странице |
| `NOTIFY_PAGING_NUM` | `20` | Уведомлений на странице |
| `FEED_MAX_COMMIT_NUM` | `5` | Коммитов в ленте активности |
| `FEED_PAGING_NUM` | `20` | Элементов в ленте активности на странице |
| `COMMITS_PAGING_NUM` | `30` | Коммитов на странице истории |
| `GRAPH_MAX_COMMIT_NUM` | `100` | Макс. коммитов в графе сети |

### Темы оформления

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DEFAULT_THEME` | `auto` | Тема по умолчанию: `auto`, `gitea`, `forgejo`, `arc-green` |
| `THEMES` | `auto,gitea,forgejo,arc-green` | Список доступных тем (через запятую) |
| `SHOW_FOOTER_TEMPLATE_LOAD_TIME` | `true` | Показывать время генерации страницы в футере |
| `SHOW_FOOTER_POWERED_BY` | `true` | Показывать "Powered by Forgejo" в футере |
| `SHOW_USER_EMAIL` | `true` | Показывать email пользователя на странице профиля |
| `ONLY_SHOW_RELEVANT_REPOS` | `false` | Показывать только релевантные репозитории в профиле |

### Поведение интерфейса

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `DEFAULT_SHOW_FULL_NAME` | `false` | Показывать полное имя вместо логина по умолчанию |
| `SEARCH_DESCRIPTION` | `true` | Искать в описаниях репозиториев |
| `USE_SERVICE_WORKER` | `true` | Использовать Service Worker для кэширования |
| `MINIMUM_KEY_SIZE_CHECK` | `true` | Проверять минимальный размер SSH/GPG ключей в UI |
| `CODE_COMMENT_LINES` | `4` | Количество строк контекста для комментариев к коду |
| `REACTION_MAX_USER_NUM` | `10` | Макс. пользователей в подсказке реакции |
| `MAX_DISPLAY_FILE_SIZE` | `8388608` | Макс. размер файла для отображения (8 МБ) |
| `SVG_RENDERING_MODE` | `auto` | Режим рендеринга SVG: `auto`, `img`, `inline` |

> **Рекомендация:** Для производственных установок установите `SHOW_FOOTER_TEMPLATE_LOAD_TIME = false` и `SHOW_FOOTER_POWERED_BY = false` для более чистого вида.

## 🔐 Секция [security] — Безопасность

### Основные настройки

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `INSTALL_LOCK` | `false` | Блокировка повторной установки (после первичной настройки) |
| `SECRET_KEY` | *(генерируется)* | Секретный ключ для сессий и CSRF-защиты |
| `INTERNAL_TOKEN` | *(генерируется)* | Внутренний токен для API-вызовов между компонентами |
| `LOGIN_REMEMBER_DAYS` | `7` | Срок действия "запомнить меня" (дни) |
| `COOKIE_REMEMBER_NAME` | `gitea_incredible` | Имя cookie для "запомнить меня" |
| `COOKIE_USERNAME` | `gitea_awesome` | Имя cookie для имени пользователя |
| `COOKIE_SECURE` | `false` | Установить Secure-флаг для cookie (только HTTPS) |

### Пароли и аутентификация

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `MIN_PASSWORD_LENGTH` | `6` | Минимальная длина пароля |
| `PASSWORD_COMPLEXITY` | `off` | Требования к сложности: `off`, `lower`, `upper`, `digit`, `special` (через запятую) |
| `PASSWORD_HASH_ALGO` | `pbkdf2` | Алгоритм хэширования: `pbkdf2`, `argon2`, `bcrypt`, `scrypt` |
| `ARGON2_PARAMS` | `memory=65536,iterations=3,parallelism=4,key_length=32` | Параметры Argon2 |
| `BCRYPT_COST` | `12` | Стоимость хэширования для Bcrypt (4-31) |
| `SCRYPT_N` | `65536` | Параметр N для Scrypt |
| `SCRYPT_R` | `8` | Параметр R для Scrypt |
| `SCRYPT_P` | `1` | Параметр P для Scrypt |
| `PBKDF2_ITERATIONS` | `32000` | Количество итераций PBKDF2 |
| `PBKDF2_SHA256_ITERATIONS` | `32000` | Количество итераций PBKDF2-SHA256 |

### Обратный прокси и заголовки

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `REVERSE_PROXY_AUTHENTICATION` | `false` | Включить аутентификацию через заголовки прокси |
| `REVERSE_PROXY_AUTHENTICATION_USER` | `X-WEBAUTH-USER` | Заголовок с именем пользователя |
| `REVERSE_PROXY_AUTHENTICATION_EMAIL` | `X-WEBAUTH-EMAIL` | Заголовок с email пользователя |
| `REVERSE_PROXY_AUTHENTICATION_FULLNAME` | `X-WEBAUTH-FULLNAME` | Заголовок с полным именем |
| `REVERSE_PROXY_LIMIT` | `1` | Количество доверенных прокси-серверов |
| `REVERSE_PROXY_TRUSTED_PROXIES` | `127.0.0.1,::1` | Список доверенных IP прокси (через запятую) |

### Дополнительные настройки безопасности

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLE_LOGIN_STATUS_CODE` | `false` | Возвращать специальный статус-код при неудачном входе |
| `LOGIN_STATUS_CODE` | `401` | HTTP-код для неудачного входа |
| `PASSWORD_CHECK_PWN` | `false` | Проверять пароли через Have I Been Pwned API |
| `PASSWORD_PWN_API_URL` | `https://api.pwnedpasswords.com` | URL API для проверки паролей |
| `PASSWORD_CHECK_PWN_MAX_FREQUENCY` | `60` | Макс. частота запросов к Pwned API (секунды) |
| `CSRF_COOKIE_HTTP_ONLY` | `true` | HttpOnly флаг для CSRF-cookie |
| `CSRF_COOKIE_SECURE` | `false` | Secure флаг для CSRF-cookie |
| `CSRF_COOKIE_SAME_SITE` | `lax` | SameSite атрибут: `strict`, `lax`, `none` |
| `REFRESH_TOKEN_REMINDER_DAYS` | `7` | Напоминать о смене refresh-токена через (дни) |

> **Важно:** После первичной установки обязательно установите `INSTALL_LOCK = true` для предотвращения повторной настройки. При использовании HTTPS установите `COOKIE_SECURE = true`.

## 📦 Секция [packages] — Управление пакетами

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLED` | `true` | Включить реестр пакетов (NuGet, npm, Maven, Docker, и др.) |
| `CHUNKED_UPLOAD_PATH` | `tmp/package-upload` | Временный путь для загрузки больших пакетов |
| `LIMIT_TOTAL_OWNER_COUNT` | `-1` | Макс. количество пакетов на владельца (-1 = без лимита) |
| `LIMIT_SIZE_ALPINE` | `-1` | Макс. размер Alpine-пакетов (МБ) |
| `LIMIT_SIZE_CARGO` | `-1` | Макс. размер Cargo-пакетов (МБ) |
| `LIMIT_SIZE_COMPOSER` | `-1` | Макс. размер Composer-пакетов (МБ) |
| `LIMIT_SIZE_CONAN` | `-1` | Макс. размер Conan-пакетов (МБ) |
| `LIMIT_SIZE_CONDA` | `-1` | Макс. размер Conda-пакетов (МБ) |
| `LIMIT_SIZE_CONTAINER` | `-1` | Макс. размер Container-пакетов (МБ) |
| `LIMIT_SIZE_CRAN` | `-1` | Макс. размер CRAN-пакетов (МБ) |
| `LIMIT_SIZE_DEBIAN` | `-1` | Макс. размер Debian-пакетов (МБ) |
| `LIMIT_SIZE_GENERIC` | `-1` | Макс. размер Generic-пакетов (МБ) |
| `LIMIT_SIZE_GO` | `-1` | Макс. размер Go-пакетов (МБ) |
| `LIMIT_SIZE_HELM` | `-1` | Макс. размер Helm-чартов (МБ) |
| `LIMIT_SIZE_MAVEN` | `-1` | Макс. размер Maven-артефактов (МБ) |
| `LIMIT_SIZE_NPM` | `-1` | Макс. размер NPM-пакетов (МБ) |
| `LIMIT_SIZE_NUGET` | `-1` | Макс. размер NuGet-пакетов (МБ) |
| `LIMIT_SIZE_PUB` | `-1` | Макс. размер Pub-пакетов (МБ) |
| `LIMIT_SIZE_PYPI` | `-1` | Макс. размер PyPI-пакетов (МБ) |
| `LIMIT_SIZE_RPM` | `-1` | Макс. размер RPM-пакетов (МБ) |
| `LIMIT_SIZE_RUBY` | `-1` | Макс. размер RubyGems-пакетов (МБ) |
| `LIMIT_SIZE_SWIFT` | `-1` | Макс. размер Swift-пакетов (МБ) |
| `LIMIT_SIZE_VAGRANT` | `-1` | Макс. размер Vagrant-пакетов (МБ) |
| `STORAGE_TYPE` | `local` | Тип хранилища: `local`, `minio`, `azure` |
| `STORAGE_PATH` | `data/packages` | Путь для локального хранения пакетов |

> **Рекомендация:** Для production-установок с Docker-пакетами используйте внешнее хранилище (MinIO/S3) из-за большого размера образов.

## 💾 Секция [lfs] — Git LFS

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `STORAGE_TYPE` | `local` | Тип хранилища: `local`, `minio`, `azure` |
| `SERVE_DIRECT` | `false` | Прямая отдача файлов клиенту без проксирования через Forgejo |
| `OBJECTS_BATCH_SIZE` | `20` | Размер пакета объектов в batch-запросе |
| `PATH` | `data/lfs` | Путь для локального хранения LFS-объектов |
| `MINIO_ENDPOINT` | *(пусто)* | Адрес MinIO/S3 сервера (для `STORAGE_TYPE = minio`) |
| `MINIO_ACCESS_KEY_ID` | *(пусто)* | Access Key для MinIO |
| `MINIO_SECRET_ACCESS_KEY` | *(пусто)* | Secret Key для MinIO |
| `MINIO_BUCKET` | *(пусто)* | Имя S3-бакета |
| `MINIO_LOCATION` | `us-east-1` | Регион S3 |
| `MINIO_BASE_PATH` | *(пусто)* | Базовый путь внутри бакета |
| `MINIO_USE_SSL` | `true` | Использовать HTTPS для MinIO |
| `MINIO_INSECURE_SKIP_VERIFY` | `false` | Пропустить проверку SSL-сертификата MinIO |

> **Примечание:** Параметры `LFS_START_SERVER` и `LFS_CONTENT_PATH` устарели и перенесены в секцию `[server]`. Рекомендуется использовать секцию `[lfs]` для новых установок.
> 
> При `SERVE_DIRECT = true` и MinIO-совместимом хранилище Forgejo возвращает прямую ссылку на объект, разгружая сервер.

## 📝 Секция [markdown] — Markdown

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ENABLE_HARD_LINE_BREAK` | `false` | Преобразовать одинарный перенос строки в `<br>` (как в Slack) |
| `CUSTOM_URL_SCHEMES` | `*` | Разрешённые URL-схемы для автоссылок (через запятую). `*` = все |
| `FILE_EXTENSIONS` | `.md,.markdown` | Расширения файлов, обрабатываемых как Markdown (через запятую) |
| `ENABLE_MATH` | `true` | Поддержка LaTeX-формул в Markdown (MathJax) |
| `RENDER_CONTENT_NETWORK` | `true` | Разрешить загрузку внешних ресурсов при рендеринге |
| `SANITIZE` | `true` | Очищать HTML от потенциально опасных тегов |
| `SANITIZE_POLICY` | *(пусто)* | Пользовательская политика HTML-санитизации |
| `ENABLE_ANCHOR_HEADING` | `true` | Добавлять якоря к заголовкам (для прямых ссылок) |
| `ANCHOR_PREFIX` | *(пусто)* | Префикс для якорей заголовков |
| `ENABLE_TASK_LIST` | `true` | Поддержка чекбоксов в списках задач |
| `ENABLE_STRIKETHROUGH` | `true` | Поддержка зачёркивания `~~текст~~` |
| `ENABLE_TABLES` | `true` | Поддержка таблиц Markdown |
| `ENABLE_FENCED_CODE` | `true` | Поддержка блоков кода с указанием языка |
| `ENABLE_AUTO_LINK` | `true` | Автоматические ссылки на URL и email |
| `ENABLE_MENTIONS` | `true` | Подсвечивать упоминания `@username` |
| `MENTION_JAVASCRIPT_URL` | *(пусто)* | URL JavaScript для обработки упоминаний |

> **Совет:** Для корпоративных установок ограничьте `CUSTOM_URL_SCHEMES` списком необходимых (например, `http,https,mailto,ssh`), чтобы предотвратить использование опасных протоколов.

## 🔄 Секция [migrations] — Миграции репозиториев

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `ALLOW_LOCALNETWORKS` | `false` | Разрешить миграцию из локальных сетей (192.168.x.x, 10.x.x.x) |
| `ALLOWED_DOMAINS` | *(пусто)* | Список разрешённых доменов для миграции (через запятую) |
| `IGNORED_DOMAINS` | *(пусто)* | Список заблокированных доменов (через запятую) |
| `SKIP_TLS_VERIFY` | `false` | Пропустить проверку SSL-сертификата при миграции |
| `MAX_ATTEMPTS` | `3` | Максимальное количество попыток миграции |
| `SKIP_AUTH` | `false` | Пропустить проверку прав доступа при миграции |
| `CUSTOM_ENDPOINTS` | *(пусто)* | Пользовательские API-эндпоинты для миграции (GitHub Enterprise и др.) |

> **Важно:** `ALLOW_LOCALNETWORKS = true` представляет риск SSRF-атак. Включайте только в доверенных сетях.
> 
> **Пример:** Для миграции только с GitHub и GitLab:
> ```ini
> [migrations]
> ALLOWED_DOMAINS = github.com,gitlab.com
> ```

## ⚡ Пример полной конфигурации

### Минимальная конфигурация (SQLite, локальная)

```ini
APP_NAME = Forgejo
RUN_USER = git
RUN_MODE = prod

[server]
PROTOCOL = http
DOMAIN = git.mysite.ru
ROOT_URL = http://git.mysite.ru:3000/
HTTP_ADDR = 0.0.0.0
HTTP_PORT = 3000
LANDING_PAGE = explore
LFS_START_SERVER = true
LFS_CONTENT_PATH = /data/lfs

[database]
DB_TYPE = sqlite3
PATH = /data/forgejo.db

[service]
DISABLE_REGISTRATION = true
REQUIRE_SIGNIN_VIEW = true
ENABLE_NOTIFY_MAIL = true
ENABLE_CAPTCHA = true
DEFAULT_KEEP_EMAIL_PRIVATE = true

[mailer]
ENABLED = true
PROTOCOL = smtp+startls
SMTP_ADDR = smtp.gmail.com
SMTP_PORT = 587
USER = my@email.com
PASSWD = secure_app_password
FROM = forgejo@mysite.ru

[security]
INSTALL_LOCK = true
MIN_PASSWORD_LENGTH = 8
PASSWORD_COMPLEXITY = lower,upper,digit,special
COOKIE_SECURE = false

[repository]
ROOT = /data/repositories
FORCE_PRIVATE = false
DEFAULT_PRIVATE = private
DISABLE_GIT_HOOKS = true
DEFAULT_BRANCH = main

[ui]
DEFAULT_THEME = arc-green
THEMES = auto,forgejo,arc-green
SHOW_FOOTER_POWERED_BY = true

[markdown]
ENABLE_HARD_LINE_BREAK = false
CUSTOM_URL_SCHEMES = http,https,mailto,ssh

[migrations]
ALLOW_LOCALNETWORKS = false
ALLOWED_DOMAINS = github.com,gitlab.com,bitbucket.org
```

### Production-конфигурация (PostgreSQL + Nginx)

```ini
[server]
PROTOCOL = http
DOMAIN = forgejo.company.com
ROOT_URL = https://forgejo.company.com/
HTTP_ADDR = 127.0.0.1
HTTP_PORT = 3000
LANDING_PAGE = home
ENABLE_GZIP = true
LFS_START_SERVER = true

[database]
DB_TYPE = postgres
HOST = /var/run/postgresql
NAME = forgejo
USER = forgejo
PASSWD = 
SSL_MODE = disable
MAX_OPEN_CONNS = 100
MAX_IDLE_CONNS = 10
CONN_MAX_LIFETIME = 3600

[service]
DISABLE_REGISTRATION = true
REQUIRE_SIGNIN_VIEW = true
ENABLE_NOTIFY_MAIL = true
DEFAULT_ORG_VISIBILITY = limited
DEFAULT_USER_VISIBILITY = limited
ENABLE_WEBAUTHN = true

[security]
INSTALL_LOCK = true
SECRET_KEY = generate_random_32_char_key
INTERNAL_TOKEN = generate_random_token
MIN_PASSWORD_LENGTH = 10
PASSWORD_COMPLEXITY = lower,upper,digit,special
PASSWORD_HASH_ALGO = argon2
COOKIE_SECURE = true
CSRF_COOKIE_SECURE = true
REVERSE_PROXY_AUTHENTICATION = false

[repository]
ROOT = /var/lib/forgejo/repositories
DISABLE_GIT_HOOKS = true
DEFAULT_BRANCH = main
FORCE_PRIVATE = true

[lfs]
STORAGE_TYPE = minio
MINIO_ENDPOINT = s3.company.com:9000
MINIO_ACCESS_KEY_ID = forgejo-lfs
MINIO_SECRET_ACCESS_KEY = secure-key
MINIO_BUCKET = forgejo-lfs
MINIO_USE_SSL = true
```

## 🔄 Применение изменений

### Перезапуск службы

**Docker:**
```bash
# Перезапуск контейнера
docker restart forgejo

# Или через docker-compose
docker-compose restart forgejo
```

**systemd (Linux):**
```bash
# Проверка статуса
sudo systemctl status forgejo

# Перезапуск
sudo systemctl restart forgejo

# Перезагрузка конфигурации (если поддерживается)
sudo systemctl reload forgejo
```

**Windows:**
```powershell
# Перезапуск службы
Restart-Service -Name Forgejo

# Или через services.msc
```

### Проверка конфигурации

**1. Через веб-интерфейс:**
```
https://ваш-сервер/admin/config
```
Показывает текущие активные параметры конфигурации.

**2. Проверка логов:**
```bash
# Docker
docker logs forgejo | grep -i "error\|fatal"

# systemd
sudo journalctl -u forgejo -n 50 --no-pager

# Файл логов
tail -f /var/log/forgejo/forgejo.log
```

**3. Проверка подключения к БД:**
```bash
# SQLite
sqlite3 /data/forgejo.db ".tables"

# PostgreSQL
psql -U forgejo -d forgejo -c "\dt"

# MySQL/MariaDB
mysql -u forgejo -p forgejo -e "SHOW TABLES;"
```

### Откат изменений

Если после изменений Forgejo не запускается:

```bash
# 1. Остановить службу
docker stop forgejo
# или
sudo systemctl stop forgejo

# 2. Восстановить резервную копию конфигурации
cp /path/to/backup/app.ini /data/gitea/conf/app.ini

# 3. Запустить заново
docker start forgejo
# или
sudo systemctl start forgejo
```

### Полезные команды

```bash
# Генерация SECRET_KEY
openssl rand -hex 32

# Генерация INTERNAL_TOKEN
forgejo generate secret INTERNAL_TOKEN

# Проверка прав доступа к файлам
ls -la /data/gitea/conf/app.ini
chown git:git /data/gitea/conf/app.ini
chmod 640 /data/gitea/conf/app.ini
```

---

## 📚 Дополнительные ресурсы

- [Официальная документация Forgejo](https://forgejo.org/docs/)
- [Примеры конфигурации app.ini](https://github.com/go-gitea/gitea/blob/main/custom/conf/app.example.ini)
- [Forgejo Discord-сообщество](https://discord.gg/forgejo)
- [Форум сообщества](https://forum.forgejo.org/)

---

*Справочник составлен на основе Forgejo 10.x. Некоторые параметры могут отличаться в зависимости от версии.*