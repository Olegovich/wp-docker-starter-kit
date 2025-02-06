#!/bin/bash
set -euo pipefail

# Запуск оригинального entrypoint
docker-entrypoint.sh "$@" &

# Ждем, пока WordPress будет готов
until curl -s http://localhost:80; do
  echo "Waiting for WordPress..."
  sleep 5
done

# Путь к wp-config.php
WP_CONFIG_PATH="/var/www/html/wp-config.php"

if [ -f "$WP_CONFIG_PATH" ]; then
  echo "Adding custom configurations to wp-config.php"

  # Добавляем константы для wp-config.php (устанавливаем значения явно, или из .env файла).
  # Чтобы не было php-ошибок, в каждом блоке проверяем через grep, есть ли уже константа в wp-config, и вставляем ее строго перед строкой:
  # require_once ABSPATH . 'wp-settings.php';
  # Также все константы, у которых тип данных не string - проверяем на тип, чтобы они добавились с правильным типом.

  # Явно отключаем WP_AUTO_UPDATE_CORE, без использования .env файла, т.к. версией WP управляем только через докер-образ.
  if ! grep -q "define( 'WP_AUTO_UPDATE_CORE', 0 );" "$WP_CONFIG_PATH"; then
    sed -i "/require_once ABSPATH . 'wp-settings.php';/i define( 'WP_AUTO_UPDATE_CORE', 0 );" "$WP_CONFIG_PATH"
  fi

  # Добавляем WP_DEBUG_DISPLAY
  if [ -n "${WORDPRESS_DEBUG_DISPLAY:-}" ]; then
    if [[ "${WORDPRESS_DEBUG_DISPLAY}" =~ ^[0-9]+$ ]]; then
      if ! grep -q "define( 'WP_DEBUG_DISPLAY', ${WORDPRESS_DEBUG_DISPLAY} );" "$WP_CONFIG_PATH"; then
        sed -i "/require_once ABSPATH . 'wp-settings.php';/i define( 'WP_DEBUG_DISPLAY', ${WORDPRESS_DEBUG_DISPLAY} );" "$WP_CONFIG_PATH"
      fi
    fi
  fi

  # Добавляем WP_DEBUG_LOG
  if [ -n "${WORDPRESS_DEBUG_LOG:-}" ]; then
    if [[ "${WORDPRESS_DEBUG_LOG}" =~ ^[0-9]+$ ]]; then
      if ! grep -q "define( 'WP_DEBUG_LOG', ${WORDPRESS_DEBUG_LOG} );" "$WP_CONFIG_PATH"; then
        sed -i "/require_once ABSPATH . 'wp-settings.php';/i define( 'WP_DEBUG_LOG', ${WORDPRESS_DEBUG_LOG} );" "$WP_CONFIG_PATH"
      fi
    fi
  fi

  # Добавляем WP_ENVIRONMENT_TYPE
  if [ -n "${WP_ENVIRONMENT_TYPE:-}" ]; then
    if ! grep -q "define( 'WP_ENVIRONMENT_TYPE', '${WP_ENVIRONMENT_TYPE}' );" "$WP_CONFIG_PATH"; then
      sed -i "/require_once ABSPATH . 'wp-settings.php';/i define( 'WP_ENVIRONMENT_TYPE', '${WP_ENVIRONMENT_TYPE}' );" "$WP_CONFIG_PATH"
    fi
  fi

  # Добавляем WP_POST_REVISIONS
  if [ -n "${WP_POST_REVISIONS:-}" ]; then
    if [[ "${WP_POST_REVISIONS}" =~ ^[0-9]+$ ]]; then
      if ! grep -q "define( 'WP_POST_REVISIONS', ${WP_POST_REVISIONS} );" "$WP_CONFIG_PATH"; then
        sed -i "/require_once ABSPATH . 'wp-settings.php';/i define( 'WP_POST_REVISIONS', ${WP_POST_REVISIONS} );" "$WP_CONFIG_PATH"
      fi
    fi
  fi
fi

wait