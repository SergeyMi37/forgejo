# Инструкция по установке и запуску Forgejo Runner на самохостируемом сервере

## Содержание

- [Что такое Forgejo Runner?](#что-такое-forgejo-runner)
- [Предварительные требования](#предварительные-требования)
- [Способы установки](#способы-установки)
  - [Способ 1: Docker Compose](#способ-1-установка-runner-с-помощью-docker-compose)
  - [Способ 2: Бинарный файл на Linux](#способ-2-установка-runner-как-бинарного-файла-на-linux)
  - [Способ 3: Готовый образ с Docker-in-Docker](#способ-3-использование-готового-образа-с-docker-in-docker)
  - [Способ 4: Windows](#способ-4-установка-runner-на-windows)
- [Настройка меток (labels)](#настройка-меток-labels)
- [Регистрация Runner](#регистрация-runner)
- [Проверка работы](#проверка-работы)
- [Устранение неполадок](#устранение-неполадок)
- [Полезные команды](#полезные-команды)
- [Дополнительные ресурсы](#дополнительные-ресурсы)

## Что такое Forgejo Runner?

Forgejo Runner — это демон, который подключается к вашему экземпляру Forgejo и выполняет задания (jobs) для непрерывной интеграции (CI/CD) через Forgejo Actions. Forgejo сам не запускает задания, он полагается на Runner для их выполнения.

## Предварительные требования

Перед установкой убедитесь, что:

- Forgejo установлен и запущен (версия 11.0+ для Actions)
- Включены Actions в Forgejo — добавьте в `app.ini`:

  ```ini
  [actions]
  ENABLED = true
  ```

- Docker установлен на сервере, где будет запускаться Runner (если планируете использовать контейнеры)
- Доступность Forgejo по сети — Runner должен иметь доступ к вашему Forgejo-инстансу

## Способы установки

### Способ 1: Установка Runner с помощью Docker Compose

Это самый простой и рекомендуемый способ для большинства пользователей.

#### Шаг 1: Создайте структуру директорий

```bash
mkdir -p ~/forgejo-runner/data
cd ~/forgejo-runner
```

#### Шаг 2: Создайте файл docker-compose.yml

```yaml
services:
  docker-in-docker:
    image: docker:dind
    container_name: docker_dind
    privileged: true
    command: ["dockerd", "-H", "tcp://0.0.0.0:2375", "--tls=false"]
    restart: unless-stopped

  runner:
    image: code.forgejo.org/forgejo/runner:latest
    container_name: forgejo-runner
    privileged: true
    environment:
      DOCKER_HOST: tcp://docker-in-docker:2375
      FORGEJO_INSTANCE_URL: https://forgejo.example.com    # Замените на ваш URL
      FORGEJO_REGISTRATION_TOKEN: ваш_токен_регистрации     # Замените на токен
    volumes:
      - ./data:/data
    depends_on:
      - docker-in-docker
    restart: unless-stopped
```

> **Важно:** `privileged: true` требуется для работы Docker-in-Docker.

#### Шаг 3: Получите регистрационный токен в Forgejo

1. Войдите в ваш Forgejo как администратор
2. Перейдите в **Панель управления → Actions → Раннеры** (`/admin/actions/runners`)
3. Нажмите кнопку **"Создать новый раннер"**
4. Скопируйте сгенерированный токен

#### Шаг 4: Запустите Runner

```bash
docker-compose up -d
```

Проверьте логи:

```bash
docker logs forgejo-runner
```

### Способ 2: Установка Runner как бинарного файла на Linux

Подходит для сред, где не нужно запускать Docker-контейнеры внутри Runner.

#### Шаг 1: Скачайте бинарный файл

```bash
# Скачайте последнюю версию (замените URL на актуальный)
wget -O forgejo-runner https://code.forgejo.org/forgejo/runner/releases/download/v3.2.0/forgejo-runner-amd64
chmod +x forgejo-runner
```

#### Шаг 2: Создайте конфигурационный файл

```bash
./forgejo-runner generate-config > config.yml
```

Отредактируйте `config.yml`. Минимальная конфигурация:

```yaml
server:
  connections:
    example:
      url: https://forgejo.example.com    # URL вашего Forgejo
      token: ваш_токен_регистрации
      labels:
        - docker:docker://node:20-bullseye
        - self-hosted:host://-self-hosted
container:
  privileged: true
  docker_host: automount
```

#### Шаг 3: Зарегистрируйте Runner

```bash
./forgejo-runner register --no-interactive \
  --instance https://forgejo.example.com \
  --token ваш_токен_регистрации \
  --name my-runner \
  --labels docker:docker://node:20-bullseye,self-hosted
```

После регистрации создастся файл `.runner` с параметрами подключения.

#### Шаг 4: Запустите Runner как демон

```bash
./forgejo-runner daemon
```

#### Шаг 5: Настройка как systemd-сервис (опционально)

Создайте файл `/etc/systemd/system/forgejo-runner.service`:

```ini
[Unit]
Description=Forgejo Runner
After=syslog.target network.target

[Service]
User=runner
Group=runner
Type=exec
ExecStart=/usr/local/bin/forgejo-runner --config=/etc/forgejo-runner/config.yml daemon
WorkingDirectory=/home/runner

[Install]
WantedBy=multi-user.target
```

Активируйте и запустите:

```bash
systemctl daemon-reload
systemctl enable forgejo-runner
systemctl start forgejo-runner
```

### Способ 3: Использование готового образа с Docker-in-Docker

Существует готовый образ `alex3305/forgejo-runner-dind`, который объединяет Runner и Docker-in-Docker в одном контейнере.

```yaml
services:
  forgejo-runner:
    image: alex3305/forgejo-runner-dind:latest
    privileged: true
    volumes:
      - ./forgejo-runner:/config
    environment:
      FORGEJO_INSTANCE_URL: https://forgejo.example.com
      FORGEJO_REGISTRATION_TOKEN: ваш_токен_регистрации
```

Этот образ поддерживает архитектуры `amd64` и `arm64`, а также rootless-режим.

### Способ 4: Установка Runner на Windows

Для Windows доступен предварительно скомпилированный бинарный файл.

#### Шаг 1: Скачайте бинарный файл

Скачайте `forgejo-runner-windows-amd64.exe` из релизов.

#### Шаг 2: Зарегистрируйте Runner

```cmd
forgejo-runner-windows-amd64.exe register
```

В интерактивном режиме укажите:

- URL экземпляра Forgejo
- Токен регистрации
- Имя раннера
- Метки (например, `windows`)

#### Шаг 3: Запустите Runner

```cmd
forgejo-runner-windows-amd64.exe daemon
```

Для запуска как службы используйте Планировщик задач Windows.

## Настройка меток (labels)

Метки определяют, какие задания (`runs-on`) может выполнять ваш Runner.

### Что такое метки

Метка — это идентификатор, который вы назначаете Runner'у, чтобы указать Forgejo, какие типы заданий он может выполнять.

Когда вы пишете в файле `.forgejo/workflows/test.yml`:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest  # <-- Это метка
```

Forgejo ищет среди всех зарегистрированных Runner'ов тот, у которого в списке меток есть `ubuntu-latest`.

### Формат меток

Метка состоит из двух частей, разделённых двоеточием:

```
НАЗВАНИЕ_МЕТКИ:ТИП_ВЫПОЛНИТЕЛЯ
```

Где:

- **НАЗВАНИЕ_МЕТКИ** — то, что вы указываете в `runs-on` (например, `ubuntu-latest`, `docker`, `self-hosted`)
- **ТИП_ВЫПОЛНИТЕЛЯ** — среда, в которой Runner будет выполнять ваши команды

### Типы выполнения

| Тип | Формат | Пример | Описание |
|-----|--------|--------|----------|
| Docker-контейнер | `docker://` | `docker:docker://node:20-bullseye` | Создаёт контейнер из образа, выполняет job внутри, затем удаляет |
| Локальное выполнение | `host://` | `self-hosted:host://-self-hosted` | Выполняет команды напрямую на сервере Runner'а |
| LXC-контейнер | `lxc://` | `linux:lxc://debian:bullseye` | Создаёт LXC-контейнер (легковесная ВМ) |

**Когда использовать Docker-контейнер:** когда нужна чистая изолированная среда с определёнными инструментами.

**Когда использовать локальное выполнение:** когда нужен доступ к специфическому оборудованию, монтированным дискам или Docker не подходит.

**Когда использовать LXC:** когда нужна полноценная система (systemd, init) внутри контейнера.

### Создание и управление метками

**При регистрации Runner'а:**

```bash
./forgejo-runner register \
  --instance https://forgejo.example.com \
  --token ваш_токен \
  --labels ubuntu:docker://ubuntu:22.04 \
  --labels node:docker://node:18-alpine
```

**В файле `config.yml`:**

```yaml
server:
  connections:
    example:
      url: https://forgejo.example.com
      token: ваш_токен
      labels:
        - ubuntu:docker://ubuntu:22.04
        - python:docker://python:3.11-slim
        - self-hosted:host://-self-hosted
```

**Уже зарегистрированному Runner'у:**

1. В Forgejo перейдите в **Панель управления → Actions → Раннеры**
2. Найдите нужный Runner и нажмите **Редактировать**
3. Добавьте метки в поле **Метки** (через запятую)
4. Сохраните изменения

### Примеры меток и их использования

| `runs-on` | Метка Runner'а | Что произойдёт |
|-----------|----------------|----------------|
| `ubuntu-latest` | `ubuntu-latest:docker://ubuntu:24.04` | Запустит новый Ubuntu-контейнер |
| `macos` | `macos:host://-macos` | Выполнит команды на сервере с macOS |
| `linux` | `linux:lxc://debian:bookworm` | Запустит LXC-контейнер с Debian |
| `windows-2022` | `windows-2022:host://-windows-2022` | Выполнит команды на Windows-сервере |

### Практический пример

**Шаг 1:** Зарегистрируйте Runner со своей меткой

```bash
./forgejo-runner register \
  --labels custom-python:docker://python:3.11-slim
```

**Шаг 2:** Напишите workflow-файл `.forgejo/workflows/test.yml`:

```yaml
on: [push]
jobs:
  my-job:
    runs-on: custom-python
    steps:
      - name: Check Python version
        run: python --version
```

**Шаг 3:** Запустите Runner

```bash
./forgejo-runner daemon
```

**Шаг 4:** Отправьте изменения

```bash
git add .forgejo/workflows/test.yml
git commit -m "Add workflow"
git push
```

Forgejo найдёт Runner с меткой `custom-python` и выполнит job внутри свежего Python-контейнера.

### Настройка версий через метки

Версию ПО определяет Docker-образ, который вы привязываете к метке.

**При регистрации:**

```bash
./forgejo-runner register \
  --labels custom-python:docker://python:3.11-slim   # Python 3.11
```

**В `config.yml`:**

```yaml
runner:
  labels:
    - "custom-python:docker://python:3.11-slim"
    - "python-3-12:docker://python:3.12-bookworm"
    - "python-3-13:docker://python:3.13-rc-slim"
```

**В Docker Compose:**

```yaml
services:
  runner:
    environment:
      FORGEJO_RUNNER_LABELS: "custom-python:docker://python:3.11-slim"
```

> **Важно:** файл `.runner` не предназначен для ручного редактирования. Для изменения меток удалите файл и перерегистрируйте Runner.

### Популярные Docker-образы

| Образ | Описание |
|-------|----------|
| `python:3.13-rc-slim` | Python 3.13 RC, минимальный размер |
| `python:3.12-slim` | Python 3.12, минимальный |
| `python:3.12-bookworm` | Python 3.12 на Debian Bookworm |
| `python:3.11-slim` | Python 3.11, минимальный |
| `python:3.10-slim` | Python 3.10 LTS |
| `ghcr.io/catthehacker/ubuntu:act-latest` | Образ для GitHub Actions |

### Создание собственного образа

Если вам нужен Python + дополнительные инструменты (AWS CLI, Terraform и т.д.), создайте свой образ:

```dockerfile
FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    awscli \
    terraform \
    && rm -rf /var/lib/apt/lists/*

RUN pip install pytest black flake8
```

Соберите и опубликуйте образ в своём реестре Forgejo, а затем используйте его в метке:

```bash
--labels custom-python:docker://forgejo.example.com/пользователь/образ:latest
```

### Полезные советы

**Хорошие практики:**

- Давайте меткам понятные имена, отражающие окружение (`ubuntu`, `python3.11`, `postgres`)
- Используйте Docker-контейнеры для изоляции, если возможно
- Не используйте одну метку для разных типов выполнения

**Осторожно с `host://`:**

- Скрипты имеют доступ ко всей файловой системе сервера
- Конфигурацию сложнее переиспользовать на другом сервере
- Задания могут конфликтовать между собой

**Автоматические метки:**

- Для Docker-in-Docker автоматически добавляется метка `docker`
- Для самохостинга Runner создаёт метку с именем хоста

## Регистрация Runner

### Нужно ли регистрировать Runner в Docker

Да, регистрация необходима в любом случае — даже если Runner запущен в Docker. Регистрация связывает Runner с конкретным экземпляром Forgejo.

Процесс регистрации создаёт файл `.runner`, который служит "удостоверением личности" Runner'а и хранит данные для безопасного подключения.

### Процесс регистрации в Docker

1. Получите токен регистрации в веб-интерфейсе Forgejo (**Панель управления → Actions → Раннеры**)
2. Передайте токен в контейнер через переменную окружения `FORGEJO_REGISTRATION_TOKEN` в `docker-compose.yml`
3. При первом запуске контейнер использует токен для связи с Forgejo и прохождения регистрации

После успешной регистрации Runner сохраняет данные в файл `.runner` внутри контейнера. При последующих запусках переменная `FORGEJO_REGISTRATION_TOKEN` больше не используется.

### Перерегистрация

Если нужно перерегистрировать Runner:

1. Остановите и удалите контейнер Runner'а
2. Удалите файл `.runner` из монтируемой директории (обычно `~/forgejo-runner/data`)
3. Получите новый токен регистрации в Forgejo
4. Запустите контейнер заново с новым токеном

## Проверка работы

### 1. Проверьте статус Runner в Forgejo

Перейдите в **Панель управления → Actions → Раннеры** — ваш Runner должен быть в статусе "Online".

### 2. Создайте тестовый workflow

В любом репозитории создайте файл `.forgejo/workflows/test.yml`:

```yaml
on: [push]
jobs:
  test:
    runs-on: docker
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Run a command
        run: echo "Runner работает!"
```

### 3. Отправьте изменения в репозиторий

После `git push` перейдите во вкладку **Actions** репозитория — вы увидите выполнение задания.

## Устранение неполадок

### Проблема: Runner не может подключиться к Forgejo

**Решение:**

- Проверьте URL в `FORGEJO_INSTANCE_URL` — он должен быть доступен из сети Runner
- Проверьте, не блокирует ли файрвол соединение

### Проблема: Ошибка доступа к Docker

**Решение:**

- Убедитесь, что Runner запущен с `privileged: true`
- Проверьте переменную `DOCKER_HOST`:

  ```bash
  docker exec forgejo-runner echo $DOCKER_HOST
  ```

### Проблема: Runner зарегистрирован, но не выполняет задания

**Решение:**

- Убедитесь, что метки Runner соответствуют `runs-on` в workflow-файле
- Проверьте логи Runner: `docker logs forgejo-runner`

### Проблема: После регистрации Runner не использует переменные окружения

**Решение:**

После успешной регистрации создаётся файл `/data/.runner`. Переменные окружения больше не используются. Чтобы перенастроить, удалите этот файл и перезапустите Runner.

## Полезные команды

```bash
# Генерация конфигурационного файла
./forgejo-runner generate-config > config.yml

# Регистрация с явными параметрами
./forgejo-runner register --no-interactive \
  --instance https://forgejo.example.com \
  --token ваш_токен \
  --name my-runner

# Запуск в режиме демона
./forgejo-runner daemon

# Просмотр версии
./forgejo-runner --version
```

## Дополнительные ресурсы

- Официальная документация Forgejo
- Репозиторий Forgejo Runner
- Примеры workflow


# 🏗️ Полный процесс: от Dockerfile до метки Runner


📝 Шаг 1: Создание Dockerfile
Создайте файл Dockerfile с описанием вашего образа. Например, создадим образ с Python 3.11 и дополнительными инструментами:

dockerfile
# Базовый образ с Python 3.11
FROM python:3.11-slim

# Установка дополнительных системных пакетов
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Установка Python-пакетов
RUN pip install --no-cache-dir \
    pytest==7.4.3 \
    black==23.12.1 \
    ruff==0.1.8

# Установка рабочей директории
WORKDIR /workspace

# Команда по умолчанию (можно переопределить)
CMD ["python", "--version"]
🔧 Шаг 2: Сборка образа локально
Соберите образ с тегом, который будет указывать на ваш реестр:

bash
# Формат тега: <URL_реестра>/<владелец>/<имя_образа>:<версия>
# Например, если ваш Forgejo доступен по адресу forgejo.example.com
docker build -t forgejo.example.com/myuser/custom-python:3.11 .
Что означает тег:

forgejo.example.com — URL вашего Forgejo-сервера

myuser — ваше имя пользователя или название организации 

custom-python — имя образа

3.11 — тег версии (можно использовать latest)

🚀 Шаг 3: Публикация образа в реестре Forgejo
3.1 Вход в реестр
Сначала нужно аутентифицироваться в реестре контейнеров Forgejo :

bash
# Используйте ваш логин и персональный токен доступа (не пароль!)
docker login forgejo.example.com
Важно: Для входа используйте персональный токен доступа с правами write:packages или repo вместо пароля, особенно если у вас включена двухфакторная аутентификация .

bash
# Пример с токеном
docker login forgejo.example.com -u myuser -p your_personal_access_token
3.2 Загрузка образа
bash
# Отправка образа в реестр
docker push forgejo.example.com/myuser/custom-python:3.11
После успешной загрузки образ станет доступен в веб-интерфейсе Forgejo в разделе Packages.

⚙️ Шаг 4: Настройка метки Runner'а для использования образа
Теперь нужно научить Runner использовать этот образ при получении заданий с соответствующей меткой.

Способ A: Через конфигурационный файл Runner'а (config.yml)
Откройте файл конфигурации Runner'а и добавьте метку в секцию runner.labels :

yaml
runner:
  # ... другие настройки ...
  labels:
    # Стандартная метка Docker
    - docker:docker://alpine:3.19
    
    # НАША КАСТОМНАЯ МЕТКА!
    - custom-python:docker://forgejo.example.com/myuser/custom-python:3.11
Что здесь происходит:

custom-python — имя метки, которое вы будете указывать в runs-on

docker://forgejo.example.com/myuser/custom-python:3.11 — полный путь к вашему образу в реестре Forgejo

Способ B: При регистрации Runner'а (через командную строку)
bash
./forgejo-runner register \
  --instance https://forgejo.example.com \
  --token ваш_токен_регистрации \
  --labels custom-python:docker://forgejo.example.com/myuser/custom-python:3.11 \
  --labels ubuntu-latest:docker://ubuntu:22.04
Способ C: В Docker Compose (через переменную окружения)
yaml
services:
  runner:
    image: code.forgejo.org/forgejo/runner:latest
    environment:
      FORGEJO_RUNNER_LABELS: "custom-python:docker://forgejo.example.com/myuser/custom-python:3.11,docker:docker://alpine:3.19"
📄 Шаг 5: Использование в workflow-файле
После настройки Runner'а создайте в репозитории файл .forgejo/workflows/test.yml:

yaml
name: Python CI Test
on: [push, pull_request]

jobs:
  test:
    # Используем нашу кастомную метку!
    runs-on: custom-python
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Check Python version
        run: python --version   # Выведет: Python 3.11.x
      
      - name: Run tests
        run: |
          pip install -r requirements.txt
          pytest tests/
      
      - name: Lint check
        run: black --check .
Когда Runner получит это задание, он :

Найдёт метку custom-python в своей конфигурации

Определит, что это тип docker://

Выполнит docker run forgejo.example.com/myuser/custom-python:3.11

Запустит все шаги внутри этого контейнера

🔄 Альтернатива: Автоматическая сборка через CI/CD
Вместо ручной сборки, можно настроить автоматическую публикацию образа при каждом push'е в репозиторий с Dockerfile .

Пример workflow для автоматической сборки и публикации
Создайте .forgejo/workflows/build-and-push.yml:

yaml
name: Build and Push Docker Image
on:
  push:
    branches: [main]
    paths:
      - 'Dockerfile'
      - '**.py'

jobs:
  build:
    runs-on: docker
    container:
      image: codeberg.org/0x2321/ci:latest  # Образ с предустановленным Docker
      
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Login to Forgejo Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.FORGEJO_SERVER_URL }}
          username: ${{ env.FORGEJO_REPOSITORY_OWNER }}
          password: ${{ secrets.PACKAGE_TOKEN }}   # Токен с правами write:packages
      
      - name: Build and Push
        uses: docker/build-push-action@v6
        with:
          push: true
          tags: |
            ${{ env.FORGEJO_SERVER_URL }}/${{ env.FORGEJO_REPOSITORY_OWNER }}/custom-python:latest
            ${{ env.FORGEJO_SERVER_URL }}/${{ env.FORGEJO_REPOSITORY_OWNER }}/custom-python:${{ github.sha }}
          context: .
Необходимые секреты:

В настройках репозитория создайте секрет PACKAGE_TOKEN с персональным токеном, имеющим права write:packages 

📊 Полная схема всех шагов
Шаг	Действие	Необходимые инструменты
1	Создать Dockerfile	Любой редактор
2	Собрать образ: docker build -t ...	Docker CLI
3	Войти в реестр: docker login ...	Токен доступа Forgejo
4	Загрузить образ: docker push ...	Docker CLI
5	Настроить метку в config.yml Runner'а	Доступ к конфигурации Runner'а
6	Использовать в workflow: runs-on: custom-python	Редактор кода
💡 Важные нюансы
Кэширование образов: Runner, однажды скачав образ, не обновляет его автоматически . Чтобы гарантировать использование последней версии, рекомендуется использовать уникальные теги (например, myimage:2025-01-15-abc123de) вместо latest.

Приватные образы: Если ваш репозиторий приватный, Runner должен быть аутентифицирован для доступа к образу. В Forgejo это происходит автоматически, так как Runner использует те же учётные данные, что и для доступа к репозиторию.

Права токена: Для загрузки образов в реестр необходим токен доступа с правами write:packages .

Переопределение образа в workflow: Можно переопределить образ, даже если метка уже задана :

yaml
jobs:
  test:
    runs-on: custom-python
    container:
      image: forgejo.example.com/myuser/another-image:latest
Если на каком-то из этапов возникнут сложности или понадобится уточнить конкретные детали для вашей настройки, напишите — я помогу разобраться!

