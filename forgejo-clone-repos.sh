#!/bin/bash
# Получить список репозиториев из API и клонировать их
# Если нет jq то можно скачать и поместить каталог где установлен Bash https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
REPOSITORIES=$(curl -s https://codeberg.org/api/v1/users/SergeyMi/repos?per_page=1000 | jq -r '.[] | select(.fork == false).clone_url')
for REPOSITORY in $REPOSITORIES; do
  git clone $REPOSITORY
done
