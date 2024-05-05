import json
from os import path
import os
from coolcover_company.entities import Department
from json_schema_for_humans.generate import generate_from_filename
from json_schema_for_humans.generation_configuration import GenerationConfiguration
from pydantic import BaseModel

DATA_CONTRACTS_DOCUMENTATION_DIR = path.dirname(path.realpath(__file__))
GENERATED_DOCS_DIR = path.join(DATA_CONTRACTS_DOCUMENTATION_DIR, "generated_docs")

def generate_data_contract_documentation_as_html(
    department_specification: BaseModel
) -> None:
    path_to_generated_doc = path.join(GENERATED_DOCS_DIR, "Departments")
    if not os.path.exists(path_to_generated_doc):
        os.mkdir(path_to_generated_doc)
    with open(
        path.join(path_to_generated_doc, "department_specification.json"), "w"
    ) as json_schema:
        json_schema.write(json.dumps(department_specification.model_json_schema()))
    generate_from_filename(
        path.join(path_to_generated_doc, "department_specification.json"),
        path.join(path_to_generated_doc, "department_specification.html"),
        config=(GenerationConfiguration(expand_buttons=True)),
    )

if __name__ == "__main__":
    generate_data_contract_documentation_as_html(Department)
