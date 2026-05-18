# Полное руководство по Git LFS в Forgejo

## Содержание

1. [Что такое Git LFS](#что-такое-git-lfs)
2. [Настройка LFS на сервере Forgejo](#настройка-lfs-на-сервере-forgejo)
3. [Настройка LFS у клиента](#настройка-lfs-у-клиента)
4. [Параметры конфигурации](#параметры-конфигурации)
5. [Ограничения LFS](#ограничения-lfs)
6. [Хранение LFS-файлов](#хранение-lfs-файлов)
7. [Работа с LFS в репозитории](#работа-с-lfs-в-репозитории)
8. [Миграция существующих файлов в LFS](#миграция-существующих-файлов-в-lfs)
9. [Резервное копирование](#резервное-копирование)
10. [Устранение неполадок](#устранение-неполадок)

---

## Что такое Git LFS

**Git Large File Storage (LFS)** — это расширение Git, которое заменяет большие файлы текстовыми указателями, а сами файлы хранит отдельно на сервере.

**Преимущества:**
- Ускорение клонирования и fetch-операций
- Уменьшение размера репозитория
- Экономия дискового пространства
- Предотвращение раздувания истории

**Когда использовать LFS:**
- Файлы от 5 МБ до нескольких ГБ
- Бинарные файлы (изображения, видео, архивы)
- Скомпилированные артефакты
- Файлы дизайна (PSD, AI, Figma)

---

## Настройка LFS на сервере Forgejo

### 1. Включение LFS в конфигурации

Отредактируйте файл `app.ini`:

```ini
[server]
; Включение поддержки LFS
LFS_START_SERVER = true

[lfs]
; Путь хранения LFS-файлов
PATH = /data/lfs

; Тип хранилища: local, minio (опционально)
STORAGE_TYPE = local
```

### 2. Настройка Nginx (если используется)

Если Forgejo работает за Nginx, добавьте в конфигурацию:

```nginx
server {
    client_max_body_size 512M;  # Достаточно для большинства LFS-файлов

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 3. Перезапуск Forgejo

```bash
# Docker
docker restart forgejo

# Бинарная установка (systemd)
sudo systemctl restart forgejo
```

### 4. Проверка работы LFS

```bash
# Проверить, что LFS endpoint доступен
curl http://localhost:3000/api/v1/version
```

Или через веб-интерфейс: перейдите в настройки репозитория → **Git LFS Management**.

---

## Настройка LFS у клиента

### 1. Установка Git LFS

**Linux:**

```bash
sudo apt install git-lfs        # Ubuntu/Debian
sudo yum install git-lfs        # CentOS/RHEL
sudo dnf install git-lfs        # Fedora
```

**macOS:**

```bash
brew install git-lfs
```

**Windows:**  
Скачайте установщик с https://git-lfs.com/

### 2. Инициализация LFS

```bash
# Глобально (для всех репозиториев)
git lfs install

# Или для конкретного репозитория
cd /path/to/repo
git lfs install --local
```

### 3. Настройка типов файлов для LFS

```bash
# Отслеживать определённые расширения
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "*.tar.gz"
git lfs track "*.iso"

# Отслеживать файлы по маске
git lfs track "assets/*.png"

# Просмотр отслеживаемых типов
git lfs track
```

После выполнения команды создаётся файл `.gitattributes`. Не забудьте его закоммитить:

```bash
git add .gitattributes
git commit -m "Add LFS tracking"
```

---

## Параметры конфигурации

### Серверные параметры (app.ini)

| Параметр           | Раздел     | Значение по умолчанию | Описание                        |
|--------------------|------------|-----------------------|---------------------------------|
| LFS_START_SERVER   | [server]   | false                 | Включить LFS на сервере         |
| LFS_CONTENT_PATH   | [server]   | data/lfs              | Путь хранения LFS (устаревший)  |
| LFS_MAX_BATCH_SIZE | [server]   | 0 (без лимита)        | Макс. объектов в batch-запросе  |
| PATH               | [lfs]      | data/lfs              | Путь хранения LFS               |
| STORAGE_TYPE       | [lfs]      | local                 | local, minio, azure             |
| SERVE_DIRECT       | [lfs]      | false                 | Прямая отдача файлов            |

### Клиентские параметры

```bash
# Установить глобальные настройки
git config --global lfs.concurrenttransfers 10  # Количество параллельных загрузок
git config --global lfs.batch true               # Пакетная обработка
git config --global lfs.dialtimeout 30           # Таймаут соединения (сек)
git config --global lfs.tlstimeout 30            # Таймаут TLS (сек)

# Настройки для конкретного репозитория
git config lfs.url http://your-forgejo.com/user/repo.git/info/lfs
```

---

## Ограничения LFS

### Настраиваемые ограничения

| Тип ограничения         | Значение по умолчанию | Способ настройки              |
|-------------------------|-----------------------|-------------------------------|
| Размер отдельного файла | безлимит              | client_max_body_size в Nginx  |
| Общий объём хранилища   | безлимит              | Квоты ФС / Docker Volume      |
| Объектов в batch-запросе| безлимит              | LFS_MAX_BATCH_SIZE            |
| Параллельных загрузок   | 3                     | lfs.concurrenttransfers       |

### Рекомендуемые лимиты

```nginx
# Nginx — для больших файлов
client_max_body_size 2G;
```

```ini
# Forgejo — для ограничения batch-запросов
[server]
LFS_MAX_BATCH_SIZE = 100
```

### Квоты (экспериментальная функция)

```ini
[quota]
# Лимит для обычных пользователей (10 ГБ)
DEFAULT_USER_ASSET_QUOTA = 10737418240

# Лимит для организаций
DEFAULT_ORGANIZATION_ASSET_QUOTA = 53687091200  # 50 ГБ
```

### Практические ограничения

| Размер файла | Рекомендация                              |
|--------------|-------------------------------------------|
| 0-10 МБ      | Без LFS                                   |
| 10 МБ - 1 ГБ | ✓ LFS подходит                            |
| 1-5 ГБ       | ✓ LFS работает, проверьте таймауты        |
| 5-10 ГБ      | ⚠️ Возможны проблемы, настройте nginx     |
| > 10 ГБ      | ⚠️ Не рекомендуется, используйте внешние хранилища |

---

## Хранение LFS-файлов

### Локальное хранение (по умолчанию)

```ini
[lfs]
STORAGE_TYPE = local
PATH = /data/lfs
```

Структура локального хранилища:

```
/data/lfs/
├── lfs/
│   ├── 12/
│   │   └── 345abcdef...
│   ├── ab/
│   │   └── cd123456...
│   └── ...
```

### MinIO (S3-совместимое хранилище)

```ini
[lfs]
STORAGE_TYPE = minio
MINIO_ENDPOINT = minio.example.com:9000
MINIO_ACCESS_KEY_ID = your-access-key
MINIO_SECRET_ACCESS_KEY = your-secret-key
MINIO_BUCKET = forgejo-lfs
MINIO_LOCATION = us-east-1
MINIO_BASE_PATH = lfs/
MINIO_USE_SSL = false
```

### Azure Blob Storage

```ini
[lfs]
STORAGE_TYPE = azure
AZURE_ACCOUNT_NAME = storageaccount
AZURE_ACCOUNT_KEY = your-key
AZURE_CONTAINER = forgejo-lfs
AZURE_BASE_PATH = lfs/
```

---

## Работа с LFS в репозитории

### Основные команды

```bash
# Отслеживать файлы
git lfs track "*.bin"
git add .gitattributes

# Просмотр отслеживаемых файлов
git lfs ls-files

# Показать LFS-файлы в текущем коммите
git lfs ls-files --all

# Вытащить LFS-файлы
git lfs pull

# Показать статус LFS
git lfs status

# Мигрировать существующие файлы в LFS
git lfs migrate import --include="*.zip" --everything
```

### Пример рабочего процесса

```bash
# 1. Клонировать репозиторий с LFS-файлами
git clone http://forgejo/user/repo.git
cd repo

# 2. Добавить LFS-отслеживание для новых типов файлов
git lfs track "*.mp4"
git lfs track "docs/*.pdf"

# 3. Добавить большие файлы
cp ~/video.mp4 .
git add video.mp4

# 4. Обычный коммит (LFS обрабатывает файлы автоматически)
git commit -m "Add video file"

# 5. Отправить на сервер
git push origin main
```

---

## Миграция существующих файлов в LFS

### Миграция всей истории

```bash
# Мигрировать все .psd и .zip файлы за всю историю
git lfs migrate import --include="*.psd,*.zip" --everything

# С информацией о прогрессе
git lfs migrate import --include="*.bin" --everything --verbose
```

### Миграция только последних коммитов

```bash
# Только последние 10 коммитов
git lfs migrate import --include="*.iso" --include-ref=refs/heads/main --migrate-commits=10
```

### Проверка перед миграцией

```bash
# Показать, что будет перенесено
git lfs migrate info --include="*.zip,*.tar.gz"
```

---

## Резервное копирование

### Бэкап LFS-файлов

```bash
# Скопировать директорию LFS
cp -r /home/user123/repo-forgejo/lfs /backup/lfs-$(date +%Y%m%d)

# Или через tar
tar -czf lfs-backup.tar.gz /home/user123/repo-forgejo/lfs
```

### Полный бэкап Forgejo с LFS

```bash
# Создать полный дамп (включая LFS)
sudo -u git forgejo dump --type lfs

# Восстановление
sudo -u git forgejo restore /path/to/dump.zip
```

---

## Устранение неполадок

### Проблема: batch response: Access denied

**Решение:**

```bash
# Проверить права доступа
git config lfs.url http://user:token@forgejo/repo.git/info/lfs

# Или использовать SSH
git remote set-url origin git@forgejo:user/repo.git
```

### Проблема: Timeout during LFS upload

**Решение:**

```bash
# Увеличить таймауты
git config lfs.dialtimeout 300
git config lfs.tlstimeout 300
git config http.postBuffer 524288000  # 500 MB
```

### Проблема: LFS-файлы не загружаются

**Проверка:**

```bash
# Проверить статус LFS в репозитории
git lfs env

# Принудительно загрузить LFS-файлы
git lfs push --all origin main

# Проверить настройки сервера
docker exec forgejo curl http://localhost:3000/api/v1/version
```

### Логирование LFS на сервере

```ini
[lfs]
; Включить подробное логирование LFS
LOG = true
```

```bash
# Просмотр логов
docker logs forgejo | grep -i lfs
tail -f /var/log/forgejo/lfs.log
```

---

## Полезные команды (шпаргалка)

```bash
# === КЛИЕНТ ===
git lfs install                  # Установка LFS
git lfs track "*.ext"            # Отслеживать расширение
git lfs ls-files                 # Список LFS-файлов
git lfs pull                     # Скачать LFS-файлы
git lfs push --all               # Отправить все LFS-файлы
git lfs migrate import           # Миграция в LFS
git lfs prune                    # Очистить старые LFS-файлы

# === СЕРВЕР ===
docker exec forgejo cat /data/gitea/conf/app.ini | grep -A 2 "\[lfs\]"
docker restart forgejo
curl http://localhost:3000/api/v1/version

# === ПРОВЕРКА ===
du -sh /home/user123/repo-forgejo/lfs
git lfs env
```

---

## Ссылки

- [Официальная документация Forgejo по LFS](https://forgejo.org/docs/)
- [Git LFS официальный сайт](https://git-lfs.com/)
- [Документация Git LFS](https://github.com/git-lfs/git-lfs/wiki)