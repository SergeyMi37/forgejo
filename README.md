# Forgejo — Docker Compose

Локальный запуск Forgejo через Docker Compose с SQLite.

---

## Настройка адреса

Перед запуском создайте файл `.env` из env-example и укажите актуальные значения:

```dotenv
# Адрес или домен, по которому Forgejo доступен извне
FORGEJO_DOMAIN=171.12.0.23

# Порт веб-интерфейса на хосте
FORGEJO_HTTP_PORT=3000

# Порт SSH для Git-операций на хосте
FORGEJO_SSH_PORT=2222
```

Измените `FORGEJO_DOMAIN` на IP-адрес вашего сервера или доменное имя.  
Порты меняйте только если стандартные заняты.

---

## Быстрый старт

```bash
cd forgejo
docker compose up -d
```

Откройте в браузере: http://localhost:3000/install  
Пройдите первоначальную настройку (создание администратора, проверка путей и т.д.).

После установки обязательно заблокируйте страницу установки:

```bash
# 1. В docker-compose.yml измените:
# FORGEJO__security__INSTALL_LOCK=false  →  true

# 2. Пересоздайте контейнер:
docker compose up -d --force-recreate
```

---

## Основные команды

### Запуск и остановка

```bash
# Запуск в фоне
docker compose up -d

# Остановка
docker compose down

# Остановка с удалением volume (ВСЕ данные будут потеряны!)
docker compose down -v

# Перезапуск
docker compose restart

# Пересоздание контейнера (после изменения compose-файла)
docker compose up -d --force-recreate
```

### Просмотр логов

```bash
# Логи в реальном времени
docker compose logs -f forgejo

# Последние 100 строк
docker compose logs --tail=100 forgejo

# Логи с метками времени
docker compose logs -f --timestamps forgejo
```

### Состояние контейнера

```bash
# Статус
docker compose ps

# Проверка healthcheck
docker compose ps forgejo

# Использование ресурсов
docker stats forgejo
```

---

## Работа с данными (volume)

Все данные хранятся в именованном Docker-volume `forgejo-data`:
- `/data/forgejo.db` — база данных SQLite
- `/data/gitea-repositories` — Git-репозитории
- `/data/forgejo/conf/app.ini` — конфигурация
- `/data/forgejo/avatars`, `/data/forgejo/attachments` — загружаемые файлы

### Просмотр содержимого volume

```bash
# Запуск вспомогательного контейнера для доступа к данным
docker run --rm -it -v forgejo-forgejo-data:/data alpine sh

# Внутри контейнера:
cd /data && ls -la
```

### Копирование файлов

```bash
# Скопировать БД из контейнера на хост
docker compose cp forgejo:/data/forgejo.db ./forgejo-backup.db

# Скопировать конфиг с хоста в контейнер (осторожно!)
docker compose cp ./app.ini forgejo:/data/forgejo/conf/app.ini
```

---

## Резервное копирование

### Полный бэкап volume

```bash
# Архивирование всего volume
docker run --rm -v forgejo-forgejo-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/forgejo-backup-$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
```

### Бэкап только базы данных (SQLite)

```bash
# Создание дампа БД
docker compose exec forgejo sh -c "sqlite3 /data/forgejo.db '.backup /data/forgejo.db.backup'"
docker compose cp forgejo:/data/forgejo.db.backup ./forgejo-db-backup.db

# Или напрямую через sqlite3 в контейнере (если установлен)
docker compose exec forgejo sqlite3 /data/forgejo.db ".dump" > forgejo-dump-$(date +%Y%m%d).sql
```

### Бэкап репозиториев

Репозитории хранятся как обычные Git-репозитории в `/data/gitea-repositories`.

```bash
# Архивирование директории репозиториев
docker run --rm -v forgejo-forgejo-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/forgejo-repos-$(date +%Y%m%d_%H%M%S).tar.gz -C /data/gitea-repositories .
```

### Автоматический бэкап (пример скрипта)

```bash
#!/bin/bash
# backup-forgejo.sh
BACKUP_DIR="/opt/backups/forgejo"
mkdir -p "$BACKUP_DIR"
DATE=$(date +%Y%m%d_%H%M%S)

# Остановка контейнера для консистентности
docker compose -f /path/to/forgejo/docker-compose.yml down

# Бэкап volume
docker run --rm \
  -v forgejo-forgejo-data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf "/backup/forgejo-full-${DATE}.tar.gz" -C /data .

# Запуск
docker compose -f /path/to/forgejo/docker-compose.yml up -d

# Удаление старых бэкапов (старше 30 дней)
find "$BACKUP_DIR" -name "forgejo-full-*.tar.gz" -mtime +30 -delete
```

---

## Восстановление из резервной копии

### Полное восстановление volume

```bash
# Остановка и удаление старого контейнера
docker compose down

# Удаление старого volume (ВНИМАНИЕ: все текущие данные будут уничтожены)
docker volume rm forgejo-forgejo-data

# Создание нового volume и распаковка бэкапа
docker volume create forgejo-forgejo-data
docker run --rm \
  -v forgejo-forgejo-data:/data \
  -v $(pwd):/backup alpine \
  sh -c "cd /data && tar xzf /backup/forgejo-backup-YYYYMMDD_HHMMSS.tar.gz"

# Запуск
docker compose up -d
```

### Восстановление только БД

```bash
# Остановка сервиса
docker compose stop forgejo

# Копирование файла БД в контейнер
docker compose cp ./forgejo-backup.db forgejo:/data/forgejo.db

# Перезапуск
docker compose start forgejo
```

---

## Управление базой данных (SQLite)

### Интерактивная консоль SQLite

```bash
docker compose exec forgejo sqlite3 /data/forgejo.db
```

### Полезные SQL-запросы

```sql
-- Список пользователей
SELECT id, lower_name, email, is_admin, created_unix FROM user;

-- Список репозиториев
SELECT id, owner_name, lower_name, updated_unix FROM repository;

-- Количество репозиториев
SELECT count(*) FROM repository;

-- Список организаций
SELECT id, name FROM user WHERE type = 1;
```

### Оптимизация БД (VACUUM)

```bash
# VACUUM перестраивает БД и уменьшает размер файла
docker compose exec forgejo sqlite3 /data/forgejo.db "VACUUM;"
```

### Проверка целостности БД

```bash
docker compose exec forgejo sqlite3 /data/forgejo.db "PRAGMA integrity_check;"
```

---

## Управление репозиториями

### Структура хранения

Репозитории находятся в volume по пути:
```
/data/gitea-repositories/<пользователь_или_организация>/<репозиторий>.git
```

### Ручное резервирование отдельного репозитория

```bash
# Создание bare-копии репозитория
REPO_USER="username"
REPO_NAME="myrepo"
docker compose exec forgejo sh -c \
  "cd /data/gitea-repositories/${REPO_USER} && \
   git clone --mirror ${REPO_NAME}.git /tmp/${REPO_NAME}-mirror.git && \
   cd /tmp/${REPO_NAME}-mirror.git && \
   git bundle create /tmp/${REPO_NAME}.bundle --all"

# Копирование bundle на хост
docker compose cp forgejo:/tmp/${REPO_NAME}.bundle ./${REPO_NAME}.bundle
```

### Git-операции через хук (администратор)

```bash
# Вход в контейнер под root для обслуживания
docker compose exec -u 0 forgejo sh

# Пример: принудительный garbage collect для всех репозиториев
find /data/gitea-repositories -name "*.git" -type d -exec git -C {} gc --aggressive \;
```

---

## Обновление Forgejo

```bash
# 1. Создать бэкап
docker compose down
docker run --rm -v forgejo-forgejo-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/forgejo-pre-update-$(date +%Y%m%d).tar.gz -C /data .

# 2. Обновить образ
docker compose pull

# 3. Пересоздать контейнер
docker compose up -d --force-recreate

# 4. Проверить логи на предмет миграций
docker compose logs -f --tail=50 forgejo
```

---

## Сеть и SSH

### SSH-доступ к репозиториям

Порт `2222` проброшен на хост. Для клонирования через SSH:

```bash
git clone ssh://git@localhost:2222/username/repo.git
```

Добавьте SSH-ключ в веб-интерфейсе Forgejo: **Настройки → SSH / GPG Keys**.

### Изменение порта SSH

Если порт `2222` занят, измените в `docker-compose.yml`:

```yaml
ports:
  - "3000:3000"
  - "2223:22"   # <-- новый порт на хосте
```

И обновите переменную окружения:

```yaml
environment:
  - FORGEJO__server__SSH_PORT=2223
```

---

## Переменные окружения

Настраиваются в файле `.env`:

| Переменная | Описание | Пример |
|------------|----------|--------|
| `FORGEJO_DOMAIN` | IP-адрес или домен сервера | `171.12.0.23` или `git.example.com` |
| `FORGEJO_HTTP_PORT` | Порт веб-интерфейса на хосте | `3000` |
| `FORGEJO_SSH_PORT` | Порт SSH для Git на хосте | `2222` |

Внутри контейнера Forgejo использует стандартные порты (3000 и 22).

Полный список опций конфигурации: https://forgejo.org/docs/latest/admin/config-cheat-sheet/

---

## Кастомизация

### Замена иконки сайта (favicon)

**1. Подготовьте иконку:**

- Формат: PNG (рекомендуется 32×32 или 64×64 пикселей)
- Имя файла: `logo.png`

**2. Скопируйте в контейнер:**

```bash
# Создать директорию для кастомных файлов
docker compose exec forgejo mkdir -p /data/gitea/custom/public/img

# Заменить favicon (иконка вкладки браузера)
docker compose cp ./favicon.png forgejo:/data/gitea/custom/public/img/logo.png

# Перезапустить Forgejo
docker compose restart forgejo
```

**3. Очистите кэш браузера:** `Ctrl+Shift+R` (Windows/Linux) или `Cmd+Shift+R` (macOS).

---

### Замена логотипа в шапке сайта

```bash
# Логотип в верхней панели (рекомендуемый размер: 32×32 или 150×40)
docker compose cp ./my-logo.png forgejo:/data/gitea/custom/public/img/logo.png
docker compose restart forgejo
```

---

### Другие кастомные файлы

```
/data/gitea/custom/
├── public/
│   └── img/
│       ├── logo.png       # Логотип в шапке + favicon
│       └── favicon.ico    # Favicon в формате ICO (альтернатива)
└── templates/             # Кастомные HTML-шаблоны (продвинутое)
```

Для сброса к оригинальным значениям удалите кастомные файлы:

```bash
docker compose exec forgejo rm -rf /data/gitea/custom
docker compose restart forgejo
```

---

## Устранение неполадок

### Контейнер не запускается

```bash
# Проверить логи
docker compose logs forgejo

# Проверить права на volume
docker compose exec forgejo ls -la /data/

# Сброс прав (если нужно)
docker compose exec -u 0 forgejo chown -R 1000:1000 /data
```

### Потеря пароля администратора

```bash
# Сброс пароля через CLI Forgejo
docker compose exec forgejo forgejo admin user change-password --username admin --password "NEW_PASS"
```

### Создание администратора через CLI

```bash
docker compose exec forgejo forgejo admin user create \
  --username admin \
  --password "SecurePass123" \
  --email admin@localhost \
  --admin
```

### Очистка неиспользуемых образов

```bash
docker image prune -f
```

---

## Полезные ссылки

- Официальная документация: https://forgejo.org/docs/
- Docker-образ: https://codeberg.org/forgejo/-/packages/container/forgejo/latest
- Конфигурация: https://forgejo.org/docs/latest/admin/config-cheat-sheet/
