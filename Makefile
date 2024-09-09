# PostgreSQL connection details
PG_HOST := localhost
PG_PORT := 5432
PG_USER := postgres
PG_PASSWORD := password

SERVICES := auth wizard mana spell realm

.PHONY: all create-dbs init-migrations migrate-up migrate-down migration-status proto build run test clean help

all: create-dbs migrate-up build

create-dbs:
	@echo "Creating databases..."
	@for %%s in ($(SERVICES)) do ( \
		set "PGPASSWORD=$(PG_PASSWORD)" && \
		psql -h $(PG_HOST) -p $(PG_PORT) -U $(PG_USER) -d postgres -c "CREATE DATABASE %%s;" \
	)

init-migrations:
	@echo "Initializing migrations..."
	@powershell.exe -Command "$$services = '$(SERVICES)'.Split(' '); foreach ($$s in $$services) { \
		Write-Host 'Creating migration for' $$s; \
		migrate create -ext sql -dir migrations/$$s -seq 'init' \
	}"

migrate-up:
	@echo "Running migrations up..."
	@powershell.exe -Command "$$services = '$(SERVICES)'.Split(' '); foreach ($$s in $$services) { \
		Write-Host 'Migrating' $$s; \
		migrate -path migrations/$$s -database \"postgresql://$(PG_USER):$(PG_PASSWORD)@$(PG_HOST):$(PG_PORT)/$$s?sslmode=disable\" up; \
	}"

migrate-down:
	@echo "Running migrations down..."
	@powershell.exe -Command "$$services = '$(SERVICES)'.Split(' '); foreach ($$s in $$services) { \
		Write-Host 'Reverting' $$s; \
		migrate -path migrations/$$s -database \"postgresql://$(PG_USER):$(PG_PASSWORD)@$(PG_HOST):$(PG_PORT)/$$s?sslmode=disable\" down; \
	}"

migration-status:
	@echo "Checking migration status..."
	@powershell.exe -Command "$$services = '$(SERVICES)'.Split(' '); foreach ($$s in $$services) { \
		Write-Host 'Status for' $$s; \
		migrate -path migrations/$$s -database \"postgresql://$(PG_USER):$(PG_PASSWORD)@$(PG_HOST):$(PG_PORT)/$$s?sslmode=disable\" version; \
	}"

proto:
	@echo "Generating protobuf code..."
	@for %%s in ($(SERVICES)) do ( \
		protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/%%s/%%s.proto \
	)

build:
	@echo "Building services..."
	@for %%s in ($(SERVICES)) do ( \
		go build -o bin/%%s cmd/%%s/main.go \
	)

run:
	@echo "Running services..."
	@for %%s in ($(SERVICES)) do ( \
		./bin/%%s & \
	)

test:
	@echo "Running tests..."
	@go test ./...

clean:
	@echo "Cleaning up..."
	@rm -rf bin

help:
	@echo "Available commands:"
	@echo "  make create-dbs    - Create databases for all services"
	@echo "  make migrate-up    - Run all migrations up"
	@echo "  make migrate-down  - Run all migrations down"
	@echo "  make migration-status - Check migration status"
	@echo "  make proto         - Generate protobuf code"
	@echo "  make build         - Build all services"
	@echo "  make run           - Run all services"
	@echo "  make test          - Run all tests"
	@echo "  make clean         - Remove built binaries"
	@echo "  make all           - Create DBs, run migrations, and build (default)"
	@echo "  make help          - Show this help message"