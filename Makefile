# This is an auto documented Makefile. For more information see the following article
# @see http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

SHELL := /bin/bash
.SHELLFLAGS = -ec
.SILENT:
MAKEFLAGS += --silent
.ONESHELL:

.EXPORT_ALL_VARIABLES:

.DEFAULT_GOAL: help

.PHONY: help ## 🛟 To display this prompts. This will list all available targets with their documentation
help:
	{
	echo "❓ Use \`make <target>' where <target> is one of 👇"
	grep -E '^\.PHONY: [a-zA-Z0-9_-]+ .*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = "(: |##)"}; {printf "\033[36m%-30s\033[0m %s\n", $$2, $$3}'
	echo "Tips 💡"
	echo "	- use tab for auto-completion"
	echo "	- use the dry run option '-n' to show what make is attempting to do. example: make -n backing-services-start"
	} | tee /dev/tty | freeze -c full -o docs/available-commands.png

.PHONY: backing-services-start  ## 🔌 start all the services consumed by our components through the network (aka backing services https://12factor.net/backing-services)
backing-services-start:
	docker compose \
		-f backing_services/docker-compose.yml \
		up -d --remove-orphans

.PHONY: backing-services-stop  ## ⏹️ stop all the services consumed by our components through the network (aka backing services https://12factor.net/backing-services)
backing-services-stop:
	docker compose -f backing_services/docker-compose.yml down

.PHONY: backing-services-db-connection  ## 🔌🐳🐘 Connect to the local db used by the app
backing-services-db-connection:
	docker exec -it my_local_postgresql psql -U local_dev local_db

.PHONY: database-documentation  ## 🧫 Generate static HTML documentation of the database against a live db
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
		schemaspy/schemaspy:latest -configFile /config/schemaspy.properties -noimplied -nopages -l -loglevel severe \
			| sed 's,^,[🕵️ SchemaSpy] - ,'
	echo "[*][*] Documentation generated @ file://$(CURDIR)/docs/schemaspy/docs/public/index.html ..."
	cp $(CURDIR)/docs/schemaspy/docs/public/diagrams/summary/*.png $(CURDIR)/docs/database/
	echo "[*][*] Schema copied for versioning @ file://$(CURDIR)/docs/database/ ..."
	$(MAKE) backing-services-stop

.PHONY: python-dependencies  ## ⬇️ to download python dependencies
python-dependencies:
	cd coolcover_company && poetry install

.PHONY: start-app  ## 🎬 to start the API locally
start-app:
	echo "[*] Starting the API locally ..."
	echo "[*] 📖 According to your preference, API documentation will be available on:"
	echo -e "\t* http://127.0.0.1:8000/docs"
	echo -e "\t* or http://127.0.0.1:8000/redoc ..." 
	cd coolcover_company && poetry run \
		uvicorn src.coolcover_company.main:app --reload
