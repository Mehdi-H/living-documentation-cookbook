# living-documentation-cookbook

A companion repo to my blog article

- [living-documentation-cookbook](#living-documentation-cookbook)
  - [Requirements](#requirements)
  - [Getting started](#getting-started)
  - [Documentation](#documentation)
    - [Documenting usages](#documenting-usages)
    - [Documenting the database](#documenting-the-database)
    - [Documenting the HTTP REST API](#documenting-the-http-rest-api)


## Requirements

- 📸 [charmbracelet/freeze](https://github.com/charmbracelet/freeze) : to create documentation from commands output
- ⛳️ [GNU tee](https://tldr.inbrowser.app/pages/common/tee) : to pipe some logs in both STDOUT and other CLI tools (such as Freeze)
- 🐳 [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/) : to run containers locally
- 🐍 [Python](https://www.python.org/downloads/) : to run the sample FastAPI app and consult the dynamic OpenAPI (living) documentation
  - Take a look at [pyproject.toml](./coolcover_company/pyproject.toml) file to know what Python version is needed
- 💐 [Poetry](https://python-poetry.org/) : to handle Python dependency management

## Getting started

Run `make` or `make help` 🔥

## Documentation

### Documenting usages

Run `make` or `make help` in your terminal, or straight from this markdown file if your IDE allows it :

```sh
make;
```

This command will list the available commands, and it will also update the following image 👇

![Available commands generated automatically](./docs/available-commands.png)

### Documenting the database

![Database documentation](./docs/database/relationships.real.compact.png)

Generate and update this schema with :

```bash
make database-documentation;
```

### Documenting the HTTP REST API

Run the application with

```bash
make start-app
```

The API documentation will be automatically available at the following urls once the application is up :

|          OpenAPI rendering           |            ReDoc rendering             |
| :----------------------------------: | :------------------------------------: |
|   ![](./docs/rest_api/openapi.png)   |     ![](./docs/rest_api/redoc.png)     |
| [🔗 link](http://127.0.0.1:8000/docs) | [🔗  link](http://127.0.0.1:8000/redoc) |

This documentation is automatically rendered from how the API is modelled in the code, following [OpenAPI standard](https://swagger.io/specification/), it is *living* at the same pace as the code is evolving.
