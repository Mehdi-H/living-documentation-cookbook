from enum import StrEnum
from pydantic import BaseModel, Field

class DepartmentName(StrEnum):
    FINANCE="FINANCE"
    IT="IT"
    R_AND_D="R&D"
    RH="RH"


class Department(BaseModel):
    """We expect departments in our company to be defined as such 👇"""
    id: int = Field(..., description="Unique identifier for the department")
    name: DepartmentName = Field(..., description="Name of the department")


class Employee(BaseModel):
    id: int = Field(..., description="Unique identifier for the employee")
    name: str = Field(..., description="Name of the employee")
    department_id: int = Field(
        ...,
        description="An id to reference the department the employee belongs to",
    )


class Project(BaseModel):
    id: int = Field(..., description="Unique identifier for the project")
    name: str = Field(..., description="Name of the project")
    department_id: int = Field(
        ..., description="An id to reference the department the project belongs to"
    )


class Task(BaseModel):
    id: int = Field(..., description="Unique identifier for the task")
    description: str = Field(..., description="Description of the task")
    project_id: int = Field(
        ..., description="An id to reference the project the task belongs to"
    )


class Assignment(BaseModel):
    id: int = Field(..., description="Unique identifier for the assignment")
    employee_id: int = Field(
        ..., description="An id to reference the employee assigned to the task"
    )
    task_id: int = Field(
        ..., description="An id to reference the task assigned to the employee"
    )
