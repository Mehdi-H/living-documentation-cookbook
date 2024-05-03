-- This SQL script was generated with ChatGTP3.5 with the following prompt :
-- Write a sql script. It should contain valid sql with 5 tables with some relationships. Tables and columns must be described with SQL "COMMENT ON" statements

CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100)
);

COMMENT ON TABLE department IS 'Table to store departments';

COMMENT ON COLUMN department.department_id IS 'Unique identifier for the department';

COMMENT ON COLUMN department.department_name IS 'Name of the department';

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES department(department_id)
);

COMMENT ON TABLE employee IS 'Table to store employees';

COMMENT ON COLUMN employee.employee_id IS 'Unique identifier for the employee';

COMMENT ON COLUMN employee.employee_name IS 'Name of the employee';

COMMENT ON COLUMN employee.department_id IS 'Foreign key referencing the department the employee belongs to';

CREATE TABLE project (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    department_id INT,
    CONSTRAINT fk_department_project FOREIGN KEY (department_id) REFERENCES department(department_id)
);

COMMENT ON TABLE project IS 'Table to store projects';

COMMENT ON COLUMN project.project_id IS 'Unique identifier for the project';

COMMENT ON COLUMN project.project_name IS 'Name of the project';

COMMENT ON COLUMN project.department_id IS 'Foreign key referencing the department the project belongs to';

CREATE TABLE task (
    task_id SERIAL PRIMARY KEY,
    task_description TEXT,
    project_id INT,
    CONSTRAINT fk_project_task FOREIGN KEY (project_id) REFERENCES project(project_id)
);

COMMENT ON TABLE task IS 'Table to store tasks';

COMMENT ON COLUMN task.task_id IS 'Unique identifier for the task';

COMMENT ON COLUMN task.task_description IS 'Description of the task';

COMMENT ON COLUMN task.project_id IS 'Foreign key referencing the project the task belongs to';

CREATE TABLE assignment (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INT,
    task_id INT,
    CONSTRAINT fk_employee_assignment FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_task_assignment FOREIGN KEY (task_id) REFERENCES task(task_id)
);

COMMENT ON TABLE assignment IS 'Table to store assignments of tasks to employees';

COMMENT ON COLUMN assignment.assignment_id IS 'Unique identifier for the assignment';

COMMENT ON COLUMN assignment.employee_id IS 'Foreign key referencing the employee assigned to the task';

COMMENT ON COLUMN assignment.task_id IS 'Foreign key referencing the task assigned to the employee';

