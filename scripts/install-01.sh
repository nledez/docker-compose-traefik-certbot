#!/bin/bash
for v in etc var certificates; do
	docker volume create --driver local -o o=bind -o type=none -o device=$(pwd)/letsencrypt/${v} letsencrypt_${v}
done
docker-compose pull --quiet
docker-compose up -d
