# CLAUDE.md

## TLDR

Companion repo to the blog article about living documentation.
Demonstrates auto-generated docs from code.

> *Cette section a été générée automatiquement à partir de : `parts/repo_tldr.md`.*

## Main commands

```
❓ Use 'make <target>' where <target> is one of 👇
all-docs                        🪄📚 to generate all documentation artifacts at once
app-dependencies-install        ⬇️ to download python dependencies
app-format                      🎨 to format the python codebase
app-lint                        🔍 to lint the python codebase
app-start                       🚀 to start the FastAPI application
backing-services-db-connection    🔌🐳🐘 to connect to the local db used by the app
backing-services-start          🔌 to start all the services consumed by our components through the network (aka backing services https://12factor.net/backing-services)
backing-services-stop           ⏹️ to stop all the services consumed by our components through the network (aka backing services https://12factor.net/backing-services)
check-setup                     🔍 to check that mise is installed and all system dependencies are available
claude-md                       🤖📜 to generate CLAUDE.md from configured sources of truth
claude-md-validate              🔍 to validate the CLAUDE.md generator configuration
data-contracts-documentation    📦📜 to generate documentation for the data contracts
database-documentation          🧫 to generate static HTML documentation of the database against a live db
help                            🛟 to display this prompts. This will list all available targets with their documentation
rest-api-documentation          🌐📜 to generate documentation for the web rest API
system-dependencies-install     ⬇️ to install system dependencies
Tips 💡
	- use tab for auto-completion
	- use the dry run option '-n' to show what make is attempting to do. example: 'make -n help'
```

> *Cette section a été générée automatiquement à partir de : `make help`.*

## Arborescence

```
.
├── backing_services  # Docker Compose for local development backing services
│   ├── init_scripts
│   │   └── init.sql
│   └── docker-compose.yml
├── claude-md-autoupdate  # Automated CLAUDE.md generator, living documentation with configurable parts
│   ├── parts
│   │   ├── repo_tldr.md
│   │   └── tree_with_annotations.py
│   ├── claude_md_config.py
│   └── generate_claude_md.py
├── coolcover_company  # Python web application with automated documentation generation
│   ├── src
│   │   └── coolcover_company
│   ├── tests
│   │   └── __init__.py
│   └── pyproject.toml
├── docs  # Auto-generated documentation artifacts from code
│   ├── data_contracts
│   │   ├── generated_docs
│   │   ├── main.py
│   │   └── sample.png
│   ├── database
│   │   ├── relationships.real.compact.png
│   │   └── relationships.real.large.png
│   ├── rest_api
│   │   ├── openapi.json
│   │   ├── openapi.png
│   │   └── redoc.png
│   ├── schemaspy
│   │   ├── docs
│   │   ├── schemaspy.properties
│   │   └── schemaspy.properties.template
│   └── available-commands.png
├── AGENTS.md
├── CLAUDE.md
├── LICENSE
├── Makefile
├── README.md
└── mise.toml

16 directories, 24 files
```

> *Cette section a été générée automatiquement à partir de : `python claude-md-autoupdate/parts/tree_with_annotations.py`.*
