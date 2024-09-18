#!/bin/bash

# Nama file yang akan dibuat
CSV_FILE="sample_data.csv"
XLSX_FILE="sample_data.xlsx"

# Buat file CSV dengan data sample
echo "id,name,email,department,hire_date,salary" > $CSV_FILE
echo "1,John Doe,john.doe@example.com,Human Resources,2021-01-15,60000" >> $CSV_FILE
echo "2,Jane Smith,jane.smith@example.com,Engineering,2020-06-01,80000" >> $CSV_FILE
echo "3,Emily Johnson,emily.johnson@example.com,Engineering,2019-11-23,75000" >> $CSV_FILE
echo "4,Michael Brown,michael.brown@example.com,Marketing,2022-03-12,65000" >> $CSV_FILE

# Buat file XLSX dengan data sample menggunakan Python
python3 <<EOF
import pandas as pd

# Data sample
data = {
    "id": [1, 2, 3, 4],
    "name": ["John Doe", "Jane Smith", "Emily Johnson", "Michael Brown"],
    "email": ["john.doe@example.com", "jane.smith@example.com", "emily.johnson@example.com", "michael.brown@example.com"],
    "department": ["Human Resources", "Engineering", "Engineering", "Marketing"],
    "hire_date": ["2021-01-15", "2020-06-01", "2019-11-23", "2022-03-12"],
    "salary": [60000, 80000, 75000, 65000]
}

# Create DataFrame
df = pd.DataFrame(data)

# Save to Excel
df.to_excel("$XLSX_FILE", index=False)

print(f"File {XLSX_FILE} has been created successfully.")
EOF

echo "File $CSV_FILE has been created successfully."
