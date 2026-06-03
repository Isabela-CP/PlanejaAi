# Makefile for Planeja.AI Backend

.PHONY: help up down restart logs db-shell clean

help:
	@echo "Available commands:"
	@echo "  make up         - Start all containers in background"
	@echo "  make down       - Stop and remove all containers"
	@echo "  make restart    - Restart all containers"
	@echo "  make logs       - Tail logs for all containers"
	@echo "  make db-shell   - Open psql shell inside the database container"
	@echo "  make clean      - Stop containers and remove volumes (wipes database)"

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

db-shell:
	docker exec -it planeja_db psql -U planeja_user -d planeja_db

clean:
	docker compose down -v
