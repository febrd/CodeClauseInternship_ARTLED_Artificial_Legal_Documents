#!/bin/bash

# Nama file database
DB_FILE="test.db"

# Hapus file database jika sudah ada
if [ -f "$DB_FILE" ]; then
    rm "$DB_FILE"
fi

# Buat database dan tabel
sqlite3 "$DB_FILE" <<EOF
-- Membuat tabel departments
CREATE TABLE departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    location TEXT
);

-- Membuat tabel employees
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department_id INTEGER,
    hire_date DATE,
    salary REAL,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Membuat tabel projects
CREATE TABLE projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    budget REAL,
    start_date DATE,
    end_date DATE
);

-- Membuat tabel employee_projects
CREATE TABLE employee_projects (
    employee_id INTEGER,
    project_id INTEGER,
    role TEXT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- Menambahkan data ke tabel departments
INSERT INTO departments (name, location) VALUES
('Human Resources', 'New York'),
('Engineering', 'San Francisco'),
('Marketing', 'Chicago');

-- Menambahkan data ke tabel employees
INSERT INTO employees (name, email, department_id, hire_date, salary) VALUES
('John Doe', 'john.doe@example.com', 1, '2021-01-15', 60000),
('Jane Smith', 'jane.smith@example.com', 2, '2020-06-01', 80000),
('Emily Johnson', 'emily.johnson@example.com', 2, '2019-11-23', 75000),
('Michael Brown', 'michael.brown@example.com', 3, '2022-03-12', 65000);

-- Menambahkan data ke tabel projects
INSERT INTO projects (name, budget, start_date, end_date) VALUES
('Project Alpha', 50000, '2023-01-01', '2023-12-31'),
('Project Beta', 75000, '2023-03-01', '2024-02-28'),
('Project Gamma', 60000, '2023-06-01', '2023-11-30');

-- Menambahkan data ke tabel employee_projects
INSERT INTO employee_projects (employee_id, project_id, role) VALUES
(1, 1, 'Manager'),
(2, 1, 'Developer'),
(3, 2, 'Developer'),
(4, 3, 'Marketing Specialist');
EOF

echo "Database and tables have been set up successfully."
