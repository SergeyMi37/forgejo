#!/usr/bin/env bash

# Скрипт для получения всех репозиториев пользователя из Forgejo API
# Поддерживает: Codeberg, self-hosted Forgejo, Gitea
# chmod +x forgejo-list-repos.sh
# Запустите для получения публичных репозиториев:
#FORGEJO_USERNAME="имя_пользователя" ./forgejo-list-repos.sh

#Пример для Codeberg:
#FORGEJO_URL="https://codeberg.org" FORGEJO_USERNAME="knut" ./forgejo-list-repos.sh

set -euo pipefail

# -------------------------------------------------------------------
# 1. Конфигурация (настройте под себя или используйте переменные окружения)
# -------------------------------------------------------------------

# URL вашего Forgejo-инстанса (например: https://codeberg.org)
FORGEJO_URL="${FORGEJO_URL:-https://codeberg.org}"

# Имя пользователя, чьи репозитории нужно получить
FORGEJO_USERNAME="${FORGEJO_USERNAME:-}"

# API-токен (опционально, но нужен для приватных репозиториев)
FORGEJO_TOKEN="${FORGEJO_TOKEN:-}"

# -------------------------------------------------------------------
# 2. Проверка зависимостей
# -------------------------------------------------------------------

check_dependencies() {
    local deps=("curl" "jq")
    local missing=()
    
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "❌ Ошибка: Отсутствуют необходимые команды: ${missing[*]}" >&2
        echo "   Установите их: apt install jq curl (Debian/Ubuntu) или brew install jq curl (macOS)" >&2
        exit 1
    fi
}

# -------------------------------------------------------------------
# 3. Основная функция получения репозиториев
# -------------------------------------------------------------------

fetch_repositories() {
    local url="${FORGEJO_URL}/api/v1/users/${FORGEJO_USERNAME}/repos"
    local page=1
    local per_page=50
    local all_repos=()
    local temp_file
    
    temp_file=$(mktemp)
    
    echo "🔍 Получение репозиториев пользователя: ${FORGEJO_USERNAME}" >&2
    echo "🏢 Инстанс: ${FORGEJO_URL}" >&2
    echo "==============================================" >&2
    
    # Пагинированный запрос к API
    while true; do
        local api_url="${url}?page=${page}&limit=${per_page}"
        local auth_header=()
        
        if [[ -n "$FORGEJO_TOKEN" ]]; then
            auth_header=(-H "Authorization: token ${FORGEJO_TOKEN}")
        fi
        
        # Выполняем запрос
        http_code=$(curl -s -w "%{http_code}" "${auth_header[@]}" \
            -H "Accept: application/json" \
            "$api_url" -o "$temp_file")
        
        if [[ "$http_code" != "200" ]]; then
            echo "❌ Ошибка API: HTTP $http_code" >&2
            cat "$temp_file" >&2
            rm -f "$temp_file"
            exit 1
        fi
        
        # Проверяем, пустой ли ответ
        repos_on_page=$(jq -r 'length' "$temp_file")
        
        if [[ "$repos_on_page" -eq 0 ]]; then
            break
        fi
        
        # Добавляем репозитории с текущей страницы
        while IFS= read -r repo; do
            all_repos+=("$repo")
        done < <(jq -r '.[] | @base64' "$temp_file")
        
        # Если получили меньше, чем запросили - это последняя страница
        if [[ "$repos_on_page" -lt "$per_page" ]]; then
            break
        fi
        
        ((page++))
    done
    
    rm -f "$temp_file"
    
    # -----------------------------------------------------------------
    # 4. Вывод результатов
    # -----------------------------------------------------------------
    
    local repo_count=${#all_repos[@]}
    
    if [[ $repo_count -eq 0 ]]; then
        echo "❌ Репозитории не найдены" >&2
        echo "   Проверьте имя пользователя и права доступа" >&2
        exit 0
    fi
    
    echo "✅ Найдено репозиториев: $repo_count" >&2
    echo "==============================================" >&2
    echo ""
    
    # Выводим список в удобном формате (можно менять под свои нужды)
    for repo_base64 in "${all_repos[@]}"; do
        repo_json=$(echo "$repo_base64" | base64 --decode)
        
        repo_name=$(echo "$repo_json" | jq -r '.name')
        repo_full_name=$(echo "$repo_json" | jq -r '.full_name')
        clone_url=$(echo "$repo_json" | jq -r '.clone_url')
        ssh_url=$(echo "$repo_json" | jq -r '.ssh_url')
        is_private=$(echo "$repo_json" | jq -r '.private')
        is_fork=$(echo "$repo_json" | jq -r '.fork')
        description=$(echo "$repo_json" | jq -r '.description // ""')
        
        # Формат вывода: имя | SSH URL | HTTPS URL
        printf "%-30s | %-40s | %s\n" "$repo_full_name" "$ssh_url" "$clone_url"
    done
    
    echo ""
    echo "==============================================" >&2
    echo "💡 Совет: Для клонирования всех репозиториев используйте:" >&2
    echo "   ./forgejo-list-repos.sh | grep '|' | awk -F'|' '{print \$3}' | xargs -n1 git clone" >&2
}

# -------------------------------------------------------------------
# 5. Проверка обязательных параметров и запуск
# -------------------------------------------------------------------

main() {
    check_dependencies
    
    # Проверяем, задано ли имя пользователя
    if [[ -z "$FORGEJO_USERNAME" ]]; then
        echo "❌ Ошибка: Не указано имя пользователя" >&2
        echo "   Использование: FORGEJO_USERNAME=ваш_логин $0" >&2
        echo "   Или экспортируйте переменную: export FORGEJO_USERNAME=ваш_логин" >&2
        exit 1
    fi
    
    # Предупреждение о токене для приватных репозиториев
    if [[ -z "$FORGEJO_TOKEN" ]]; then
        echo "⚠️  Внимание: API-токен не указан" >&2
        echo "   Получены будут только ПУБЛИЧНЫЕ репозитории" >&2
        echo "   Для приватных репозиториев установите FORGEJO_TOKEN" >&2
        echo "   Как создать токен: ${FORGEJO_URL}/user/settings/applications" >&2
        echo "" >&2
    fi
    
    fetch_repositories
}

# Запускаем основную функцию
main "$@"