from coolcover_company.entities import Department
from fastapi.responses import JSONResponse


from fastapi import FastAPI

app = FastAPI()


DEPARTMENTS = [
    Department(id=n, name=name) for n, name in zip([1, 2, 3], ["RH", "IT", "Finance"])
]


@app.get("/healthz", tags=["Admin"])
def healthz():
    return JSONResponse({"status": "UP"})


@app.get("/departments", tags=["Departments"])
def get_departments():
    """To list company departments 🏣 | 🏤 | 🏢"""
    return DEPARTMENTS


@app.post("/departments", tags=["Departments"])
def define_department(department: Department):
    DEPARTMENTS.append(department)
