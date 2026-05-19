# Команды управления Generic-пакетами в Forgejo

Управление Generic-пакетами в Forgejo осуществляется через стандартные HTTP-методы. Все операции выполняются с использованием базового URL-шаблона:

```
https://forgejo.example.com/api/packages/{owner}/generic/{package_name}/{package_version}/{file_name}
```

## Операции

### 1. Публикация пакета

**Метод:** `PUT`

```bash
curl --user username:token \
     --upload-file /path/to/file.bin \
     https://forgejo.example.com/api/packages/owner/package_name/1.0.0/file.bin
```

**Коды ответа:**

| Код | Значение |
|-----|----------|
| 201 Created | Пакет успешно опубликован |
| 400 Bad Request | Неверное имя пакета, версии или файла |
| 409 Conflict | Файл с таким именем уже существует |

> **Ограничение:** Нельзя повторно загрузить файл с тем же именем — необходимо сначала удалить существующий.

### 2. Скачивание пакета

**Метод:** `GET`

```bash
curl --user username:token \
     https://forgejo.example.com/api/packages/owner/package_name/1.0.0/file.bin \
     --output downloaded-file.bin
```

**Коды ответа:**

| Код | Значение |
|-----|----------|
| 200 OK | Успешно, файл в теле ответа |
| 404 Not Found | Пакет или файл не найден |

**Тип содержимого в ответе:** `application/octet-stream`

### 3. Удаление версии пакета

**Метод:** `DELETE`

Удаляет все файлы указанной версии пакета.

```bash
curl --user username:token -X DELETE \
     https://forgejo.example.com/api/packages/owner/package_name/1.0.0
```

**Коды ответа:**

| Код | Значение |
|-----|----------|
| 204 No Content | Успешно |
| 404 Not Found | Пакет не найден |

### 4. Удаление отдельного файла

**Метод:** `DELETE`

```bash
curl --user username:token -X DELETE \
     https://forgejo.example.com/api/packages/owner/package_name/1.0.0/file.bin
```

**Коды ответа:**

| Код | Значение |
|-----|----------|
| 204 No Content | Успешно |
| 404 Not Found | Пакет или файл не найден |

> **Особенность:** Если после удаления файла в версии пакета не остаётся файлов, версия пакета также удаляется автоматически.

## Справочная информация о параметрах

### Структура URL

| Параметр | Описание | Допустимые символы |
|----------|----------|-------------------|
| `owner` | Владелец пакета (пользователь или организация) | — |
| `package_name` | Имя пакета | `a-z`, `A-Z`, `0-9`, `.`, `-`, `+`, `_` |
| `package_version` | Версия пакета | Непустая строка без пробелов по краям |
| `file_name` | Имя файла | `a-z`, `A-Z`, `0-9`, `.`, `-`, `+`, `_` |

## Форматы аутентификации

Поддерживаются следующие методы:

- **HTTP Basic Auth:** `--user username:token`
- **Authorization header:** `-H "Authorization: token YOUR_TOKEN"`
- **Параметр в URL:** `?token=YOUR_TOKEN` или `?access_token=YOUR_TOKEN`

> **Рекомендация:** При использовании 2FA или OAuth обязательно используйте персональный токен доступа (Personal Access Token) вместо пароля.

## Примеры полного цикла работы

```bash
# 1. Публикация
curl --user john:ghp_abc123 \
     --upload-file ./myapp-v1.0.0.tar.gz \
     https://git.example.com/api/packages/john/generic/myapp/1.0.0/myapp-v1.0.0.tar.gz

# 2. Скачивание
curl --user john:ghp_abc123 \
     https://git.example.com/api/packages/john/generic/myapp/1.0.0/myapp-v1.0.0.tar.gz \
     --output downloaded-app.tar.gz

# 3. Удаление версии
curl --user john:ghp_abc123 -X DELETE \
     https://git.example.com/api/packages/john/generic/myapp/1.0.0
```

## Ограничения и особенности

| Ограничение | Описание |
|-------------|----------|
| Уникальность файлов | Нельзя дважды опубликовать файл с одинаковым именем в рамках одной версии |
| Имена | Только латиница, цифры и специальные символы (`.`, `-`, `+`, `_`) |
| Обновление | Для замены файла сначала удалите старый, затем загрузите новый |
| Автоматическое удаление | Версия пакета удаляется, если в ней не остаётся файлов |

## Резюме

Всего существует 4 базовые команды управления Generic-пакетами:

| Действие | HTTP-метод | Эндпоинт |
|----------|------------|----------|
| Публикация | `PUT` | `/api/packages/{owner}/generic/{name}/{version}/{file}` |
| Скачивание | `GET` | `/api/packages/{owner}/generic/{name}/{version}/{file}` |
| Удаление версии | `DELETE` | `/api/packages/{owner}/generic/{name}/{version}` |
| Удаление файла | `DELETE` | `/api/packages/{owner}/generic/{name}/{version}/{file}` |

Дополнительные операции (список пакетов, поиск, метаданные) доступны через стандартный Forgejo API, но для Generic-пакетов реализованы только базовые CRUD-операции.