#!/bin/sh

set -e

DOCKER_ENV_PATH=.env
DOCKER_COMPOSE_YML_PATH=docker-compose.yml
APP_ENV_PATH=../www/.env

# Create files if they don't exist:
if [ ! -f "$DOCKER_ENV_PATH" ]; then
  echo "сreating docker .env file..."
  cp .env.example "$DOCKER_ENV_PATH"
fi

if [ ! -f "$DOCKER_COMPOSE_YML_PATH" ]; then
  echo "сreating docker-compose.yml file..."
  cp docker-compose.example.yml "$DOCKER_COMPOSE_YML_PATH"
fi

if [ ! -f "$APP_ENV_PATH" ]; then
  echo "сreating app .env file..."
  cp ../www/.env.example "$APP_ENV_PATH"
fi

# Load values from application .env file
source $APP_ENV_PATH

# Create WP root-dir if it doesn't exists
if [ ! -d "$WP_SITE_ROOT_PATH" ]; then
  echo "сreating WordPress root directory..."
  mkdir -p "$WP_SITE_ROOT_PATH"
fi

# Launch application
docker-compose down
docker-compose build --no-cache
docker-compose up -d --build --force-recreate --no-deps
