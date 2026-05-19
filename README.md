# 🗂️ Employee Directory Manager — SAP ABAP Project

A beginner-to-intermediate SAP ABAP project demonstrating core fundamentals:
- Custom database table design (Data Dictionary)
- Object-Oriented ABAP (OOP) with classes and methods
- CRUD operations (Create, Read, Update, Delete)
- ALV Grid report with selection screen

## 📁 Project Structure

```
src/
├── ZZ_EMPLOYEES.tabl.xml          # Custom database table (Data Dictionary)
├── ZCL_EMPLOYEE.clas.abap         # OOP class: Employee entity
├── ZCL_EMPLOYEE_DAO.clas.abap     # OOP class: Data Access Object (CRUD)
└── ZREPORT_EMPLOYEES.prog.abap    # ALV Report with selection screen
```

## 🧱 Tech Stack

| Tool | Purpose |
|------|---------|
| SAP ABAP (7.4+) | Programming language |
| SAP Data Dictionary (SE11) | Database table definition |
| ABAP OOP | Class-based architecture |
| ALV Grid (CL_SALV_TABLE) | Report output |
| abapGit | Version control / Git integration |

## 🚀 How to Deploy

1. Install [abapGit](https://abapgit.org) in your SAP system
2. Create a new abapGit repository pointing to this repo
3. Pull the objects — they will be created automatically in your system
4. Activate all objects via SE80 or abapGit

## 📖 Features

- Maintain a directory of employees with ID, name, department, and salary
- Run a report with filters (by department, employee ID range)
- Full CRUD support via the DAO class
- Clean OOP architecture separating data, logic, and presentation

## 🎓 Learning Outcomes

- ABAP syntax and data types
- Transparent table creation in SE11
- Object-oriented programming in ABAP
- Working with internal tables and field symbols
- Building ALV reports using CL_SALV_TABLE
- Version controlling ABAP with abapGit

---
*Built as a learning project to demonstrate SAP ABAP fundamentals.*
