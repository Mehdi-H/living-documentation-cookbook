# This is an auto documented Makefile. For more information see the following article
# @see http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

SHELL := /bin/bash
.SHELLFLAGS = -ec
.SILENT:
MAKEFLAGS += --silent
.ONESHELL:

.EXPORT_ALL_VARIABLES:

.DEFAULT_GOAL: help

.PHONY: help ## 🛟 to display this prompts. This will list all available targets with their documentation
help:
	{
	echo "❓ Use 'make <target>' where <target> is one of 👇"
	grep -E '^\.PHONY: [a-zA-Z0-9_-]+ .*?##' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = "(: |##)"}; {printf "\033[36m%-30s\033[0m %s\n", $$2, $$3}'
	echo "Tips 💡"
	echo "	- use tab for auto-completion"
	echo "	- use the dry run option '-n' to show what make is attempting to do. example: 'make -n help'"
	} | tee /dev/tty | freeze -c full -o docs/available-commands.png

.PHONY: backing-services-start  ## 🔌 to start all the services consumed by our components through the network (aka backing services https://12factor.net/backing-services)
backing-services-start:
	echo "[*] $@ ..."
	docker compose \
		-f backing_services/docker-compose.yml \
		up -d --remove-orphans

.PHONY: backing-services-stop  ## ⏹️ to stop all the services consumed by our components through the network (aka backing services https://12factor.net/backing-services)
backing-services-stop:
	docker compose -f backing_services/docker-compose.yml down

.PHONY: backing-services-db-connection  ## 🔌🐳🐘 to connect to the local db used by the app
backing-services-db-connection:
	docker exec -it my_local_postgresql psql -U local_dev local_db

.PHONY: database-documentation  ## 🧫 to generate static HTML documentation of the database against a live db
database-documentation: SCHEMASPY_VERSION:=7.0.2
database-documentation: POSTGRES_HOST:=localhost
database-documentation: POSTGRES_DB:=local_db
database-documentation: POSTGRES_USER:=local_dev
database-documentation: POSTGRES_PASSWORD:=toto
database-documentation: POSTGRES_PORT:=5432
database-documentation: backing-services-start
	echo "[*] Generating database documentation with SchemaSpy based on ${POSTGRES_HOST} > ${POSTGRES_DB} db..."
	echo "[*][*] Cleaning the slate @ file://$(CURDIR)/docs/schemaspy/docs/* ..."
	rm -rf $(CURDIR)/docs/schemaspy/docs/*
	echo "[*][*] Generating file://$(CURDIR)/docs/schemaspy/schemaspy.properties file ..."
	envsubst < ./docs/schemaspy/schemaspy.properties.template > ./docs/schemaspy/schemaspy.properties
	docker run --rm \
		-v "./docs/schemaspy/docs/:/output:z" \
		-v "./docs/schemaspy:/config" \
		--network="host" \
		schemaspy/schemaspy:${SCHEMASPY_VERSION} -configFile /config/schemaspy.properties -noimplied -nopages -loglevel severe \
			| sed 's,^,[🕵️ SchemaSpy] - ,'
	echo "[*][*] Documentation generated @ file://$(CURDIR)/docs/schemaspy/docs/public/index.html ..."
	cp $(CURDIR)/docs/schemaspy/docs/public/diagrams/summary/*.png $(CURDIR)/docs/database/
	echo "[*][*] Schema copied for versioning @ file://$(CURDIR)/docs/database/ ..."
	$(MAKE) backing-services-stop

.PHONY: app-dependencies-install  ## ⬇️ to download python dependencies
app-dependencies-install:
	cd coolcover_company && uv sync && uv lock

app-dependencies-check-for-outdated:  ## 🔍 to check for outdated python dependencies
	cd coolcover_company && uv run pip list --outdated

app-dependencies-update: app-dependencies-check-for-outdated  ## ⬆️ to update python dependencies
	echo "[*] Updating python dependencies ..."
	cd coolcover_company && uv sync --upgrade && uv lock
	echo "[*] Python dependencies updated."

.PHONY: app-lint  ## 🔍 to lint the python codebase
app-lint: app-dependencies-install app-format
	cd coolcover_company && uv run ruff check --fix .

.PHONY: app-format  ## 🎨 to format the python codebase
app-format:
	cd coolcover_company && uv run ruff format

.PHONY: app-start  ## 🚀 to start the FastAPI application
app-start: app-dependencies-install app-lint
	echo "[*] Starting app, it will be available @ http://127.0.0.1:8000/docs ..."
	cd coolcover_company && uv run uvicorn coolcover_company.main:app --reload

app-start-check: PORT:=8000
app-start-check: app-lint
	@echo "[*] Starting app for a quick health check on port ${PORT} ..."
	cd coolcover_company && uv run uvicorn coolcover_company.main:app --port ${PORT} &
	sleep 2
	echo "[*] Checking app health endpoint ..."
	curl -f http://127.0.0.1:${PORT}/docs || (echo "[!] App did not start correctly" && exit 1)
	curl -f http://127.0.0.1:${PORT}/healthz || (echo "[!] App did not start correctly" && exit 1)
	@echo "[*] App started correctly"
	echo "[*] Killing app running on port ${PORT} ..."
	lsof -t -i tcp:${PORT} | xargs kill -9

.PHONY: data-contracts-documentation  ## 📦📜 to generate documentation for the data contracts
data-contracts-documentation:
	cd coolcover_company && uv run python ../docs/data_contracts/main.py
	echo "[*] Data contracts documentation generated @ file://$(CURDIR)/docs/data_contracts/generated_docs/Departments/department_specification.html ..."

.PHONY: all-docs  ## 🪄📚 to generate all documentation artifacts at once
all-docs: help database-documentation data-contracts-documentation app-start-check rest-api-documentation
	echo "[*] All done!"

.PHONY: rest-api-documentation  ## 🌐📜 to generate documentation for the web rest API
rest-api-documentation: PORT:=8001
rest-api-documentation: SPEC_URL:=http://127.0.0.1:${PORT}/openapi.json
rest-api-documentation:
	@echo "[*] Starting app for a quick health check on port ${PORT} ..."
	cd coolcover_company && uv run uvicorn coolcover_company.main:app --port ${PORT} &
	sleep 2
	echo "[*] Download web API documentation based on OpenAPI spec from ${SPEC_URL} ..."
	curl -f ${SPEC_URL} > $(CURDIR)/docs/rest_api/openapi.json || (echo "[!] App did not start correctly")
	echo "[*] Killing app running on port ${PORT} ..."
	lsof -t -i tcp:${PORT} | xargs kill -9
	echo "[*] REST API documentation generated @ file://$(CURDIR)/docs/rest_api/openapi.json ..."