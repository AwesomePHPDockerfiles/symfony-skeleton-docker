@echo off
docker compose --env-file .env.local exec php %*
