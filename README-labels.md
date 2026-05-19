# Настройка меток и шаблонов задач в Forgejo

Полный, готовый к использованию набор меток в формате YAML, а также шаблоны задач, оформленные по лучшим практикам Forgejo.

## Содержание

- [Глобальный набор меток (YAML)](#1-глобальный-набор-меток-yaml)
- [Шаблоны задач](#2-шаблоны-задач-в-папке-forgeoissue_template)
  - [Шаблон для бага](#21-шаблон-для-бага--bug_reportyml)
  - [Шаблон для фичи](#22-шаблон-для-фичи--feature_requestyml)
  - [Шаблон для документации](#23-шаблон-для-документации--documentationyml)
  - [Markdown-шаблон (альтернатива)](#24-простой-markdown-шаблон-альтернатива-yaml)
- [Применение шаблонов](#3-применение-шаблонов)
- [Автоматическое проставление меток через config](#4-дополнительный-совет-автоматическое-проставление-меток-через-config)

---

## 1. Глобальный набор меток (YAML)

Создайте файл, например `Standard.yaml`, и поместите его в папку `custom/options/label/` вашего экземпляра Forgejo (требуются права администратора).

```yaml
labels: 
  # === Тип задачи (Kind) ===
  - name: "Kind/Bug"
    color: "d73a4a"
    description: "Сообщение об ошибке. Что-то работает не так, как ожидалось."
    exclusive: false
  
  - name: "Kind/Feature"
    color: "008672"
    description: "Новая функциональность или возможность, которой раньше не было."
    exclusive: false
  
  - name: "Kind/Enhancement"
    color: "a2eeef"
    description: "Улучшение существующей функциональности. Не новая фича, но и не баг."
    exclusive: false
  
  - name: "Kind/Documentation"
    color: "0075ca"
    description: "Относится к документации: README, комментарии, руководства."
    exclusive: false
  
  - name: "Kind/Question"
    color: "d876e3"
    description: "Вопрос, требующий разъяснения или обсуждения."
    exclusive: false

  # === Статус выполнения (Status) ===
  - name: "Status/In Progress"
    color: "fbca04"
    description: "Задача взята в работу и активно выполняется."
    exclusive: true
  
  - name: "Status/Blocked"
    color: "e99695"
    description: "Работа над задачей заблокирована. Требуется внешнее действие."
    exclusive: true
  
  - name: "Status/Done"
    color: "0e8a16"
    description: "Задача завершена. PR принят или Issue закрыт."
    exclusive: true
  
  - name: "Status/Review Needed"
    color: "fef2c0"
    description: "Готово к проверке. Требуется ревью кода или подтверждение."
    exclusive: true
  
  - name: "Status/Draft"
    color: "d3e2f0"
    description: "Черновик. Работа ещё не готова для ревью или обсуждения."
    exclusive: true

  # === Приоритет (Priority) ===
  - name: "Priority/Critical"
    color: "b60205"
    description: "Критический приоритет. Немедленное исправление. Блокирует релиз."
    exclusive: true
  
  - name: "Priority/High"
    color: "d93f0b"
    description: "Высокий приоритет. Должно быть исправлено в ближайшее время."
    exclusive: true
  
  - name: "Priority/Medium"
    color: "fbca04"
    description: "Средний приоритет. Будет рассмотрено в плановом порядке."
    exclusive: true
  
  - name: "Priority/Low"
    color: "0e8a16"
    description: "Низкий приоритет. Приятно иметь, но не срочно."
    exclusive: true

  # === Дополнительные полезные метки ===
  - name: "Good First Issue"
    color: "7057ff"
    description: "Хорошая задача для новичков. Дружелюбно к сообществу."
    exclusive: false
  
  - name: "Help Wanted"
    color: "008672"
    description: "Требуется помощь сообщества. Никто не взял или сложная задача."
    exclusive: false
  
  - name: "Duplicate"
    color: "cfd3d7"
    description: "Дубликат другой задачи. Будет закрыто."
    exclusive: false
  
  - name: "Wontfix"
    color: "ffffff"
    description: "Решено не исправлять. Задача закрыта с указанием причины."
    exclusive: false
```

### Категории меток

| Категория | Exclusive | Описание |
|-----------|-----------|----------|
| **Kind** | `false` | Тип задачи (баг, фича, улучшение, документация, вопрос) |
| **Status** | `true` | Статус выполнения (только один статус одновременно) |
| **Priority** | `true` | Приоритет (только один приоритет одновременно) |
| **Дополнительные** | `false` | Вспомогательные метки (Good First Issue, Help Wanted и т.д.) |

---

## 2. Шаблоны задач в папке `.forgejo/issue_template/`

Создайте в корне вашего репозитория папку `.forgejo/issue_template/` и поместите в неё следующие файлы.

### 2.1 Шаблон для бага — `bug_report.yml`

```yaml
name: "Сообщение об ошибке"
description: "Создать отчет об ошибке, чтобы помочь нам улучшить продукт"
title: "[BUG]: "
labels:
  - "Kind/Bug"
  - "Priority/Medium"
  - "Status/Draft"
body:
  - type: markdown
    attributes:
      value: |
        ## Спасибо, что сообщаете о проблеме!
        Пожалуйста, заполните информацию ниже максимально подробно.

  - type: input
    id: version
    attributes:
      label: Версия продукта
      description: В какой версии вы обнаружили проблему?
      placeholder: "например, v1.2.3"
    validations:
      required: true

  - type: dropdown
    id: priority
    attributes:
      label: Приоритет (от вашего имени)
      description: Как вы оцениваете критичность для себя?
      options:
        - "Priority/Critical - Всё сломалось, работа остановлена"
        - "Priority/High - Серьёзная проблема, но есть обходной путь"
        - "Priority/Medium - Заметно, но можно работать"
        - "Priority/Low - Косметическая проблема"
    validations:
      required: true

  - type: textarea
    id: what-happened
    attributes:
      label: Что произошло?
      description: Опишите проблему как можно детальнее
      placeholder: "Я сделал X, ожидал Y, а получил Z..."
    validations:
      required: true

  - type: textarea
    id: reproduction
    attributes:
      label: Шаги воспроизведения
      description: Как мы можем воспроизвести эту проблему?
      placeholder: |
        1. Зайти в ...
        2. Нажать на ...
        3. Увидеть ошибку ...
      render: bash
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Ожидаемое поведение
      description: Что должно было произойти?
      placeholder: "Должно было ..."
    validations:
      required: false

  - type: textarea
    id: logs
    attributes:
      label: Логи или скриншоты
      description: Вставьте логи, консоль или приложите скриншот
      render: shell

  - type: checkboxes
    id: checks
    attributes:
      label: Подтверждение
      options:
        - label: Я проверил, что похожая проблема ещё не сообщалась
          required: true
        - label: Я предоставил минимальный пример для воспроизведения
          required: false
```

### 2.2 Шаблон для фичи — `feature_request.yml`

```yaml
name: "Запрос новой функции"
description: "Предложите идею для этого проекта"
title: "[FEATURE]: "
labels:
  - "Kind/Feature"
  - "Priority/Medium"
  - "Status/Draft"
body:
  - type: markdown
    attributes:
      value: |
        ## Спасибо за вашу идею!
        Расскажите, что вы хотите видеть в проекте.

  - type: textarea
    id: problem
    attributes:
      label: Связана ли ваша идея с проблемой?
      description: Чётко опишите проблему
      placeholder: "Меня раздражает, когда ..."
    validations:
      required: false

  - type: textarea
    id: solution
    attributes:
      label: Опишите желаемое решение
      description: Что должно произойти?
      placeholder: "Я хочу, чтобы была возможность ..."
    validations:
      required: true

  - type: textarea
    id: alternatives
    attributes:
      label: Альтернативы, которые вы рассматривали
      description: Какие обходные пути или другие решения вы пробовали?
    validations:
      required: false

  - type: textarea
    id: context
    attributes:
      label: Дополнительный контекст
      description: Скриншоты, ссылки, примеры кода — всё, что поможет понять идею
    validations:
      required: false

  - type: checkboxes
    id: checks
    attributes:
      label: Подтверждение
      options:
        - label: Я проверил, что похожая функция ещё не предлагалась
          required: true
        - label: Я описал решение достаточно подробно
          required: false
```

### 2.3 Шаблон для документации — `documentation.yml`

```yaml
name: "Вопрос по документации"
description: "Сообщить о проблеме или предложить улучшение документации"
title: "[DOCS]: "
labels:
  - "Kind/Documentation"
  - "Priority/Medium"
  - "Status/Draft"
body:
  - type: markdown
    attributes:
      value: |
        ## Помогите нам улучшить документацию

  - type: dropdown
    id: type
    attributes:
      label: Тип запроса
      options:
        - "Опечатка или грамматическая ошибка"
        - "Неточная или устаревшая информация"
        - "Отсутствует важный раздел"
        - "Предложение по улучшению"
    validations:
      required: true

  - type: input
    id: location
    attributes:
      label: Где находится проблема?
      description: Укажите файл/раздел/URL документации
      placeholder: "README.md, строка 42 или https://..."
    validations:
      required: true

  - type: textarea
    id: what-is-wrong
    attributes:
      label: Что не так или что отсутствует?
      description: Подробно опишите проблему
    validations:
      required: true

  - type: textarea
    id: suggestion
    attributes:
      label: Ваше предложение по исправлению
      description: Как, по-вашему, должно быть написано?
      render: markdown
    validations:
      required: false
```

### 2.4 Простой Markdown-шаблон (альтернатива YAML)

Если YAML-шаблоны для вас слишком сложны, можно использовать простой Markdown-файл:

**Файл:** `.forgejo/issue_template/bug_report.md`

```markdown
---
name: "Сообщение об ошибке"
about: "Создать отчет об ошибке"
title: "[BUG]: "
labels: 
  - "Kind/Bug"
  - "Priority/Medium"
  - "Status/Draft"
assignees: []
---

## Описание ошибки
Четкое и краткое описание того, в чем заключается ошибка.

## Шаги для воспроизведения
1. Перейти на '...'
2. Нажать на '....'
3. Прокрутить до '....'
4. Увидеть ошибку

## Ожидаемое поведение
Четкое и краткое описание того, что вы ожидали.

## Скриншоты
Если возможно, добавьте скриншоты, чтобы объяснить вашу проблему.

## Окружение:
 - Версия приложения: [например, v1.2.3]
 - Браузер: [например, chrome, safari]
 - Версия ОС: [например, Windows 11]

## Дополнительный контекст
Добавьте сюда любые другие сведения о проблеме.
```

---

## 3. Применение шаблонов

После размещения шаблонов в `.forgejo/issue_template/`:

1. **При создании новой задачи** пользователь увидит выбор шаблона
2. **Выбранный шаблон автоматически:**
   - Заполнит заголовок (`title`) согласно формату
   - Применит все указанные в `labels` метки
   - Назначит пользователей из `assignees` (если указаны)
3. **Scoped-метки** (`exclusive: true`) будут работать как радиокнопки — нельзя выбрать две метки из одной области

---

## 4. Дополнительный совет: автоматическое проставление меток через config

В корень репозитория можно добавить файл `.forgejo/config.yml` для ещё более тонкой настройки:

```yaml
# .forgejo/config.yml
issues:
  - name: "Шаблон задачи по умолчанию"
    about: "Используйте этот шаблон, если не уверены, что выбрать"
    title: "[TASK]: "
    labels:
      - "Kind/Question"
      - "Priority/Medium"
    assignees: []
```

Этот конфиг также будет отображаться при создании новых задач.

---

## Структура файлов

```
репозиторий/
├── .forgejo/
│   ├── config.yml              # Дополнительная конфигурация
│   └── issue_template/
│       ├── bug_report.yml      # Шаблон для бага
│       ├── feature_request.yml # Шаблон для фичи
│       ├── documentation.yml   # Шаблон для документации
│       └── bug_report.md       # Markdown-альтернатива
│
Forgejo (сервер)/
└── custom/
    └── options/
        └── label/
            └── Standard.yaml   # Глобальный набор меток
```