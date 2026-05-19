"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TABLE: ZZ_EMPLOYEES
" DESC:  Employee Directory - Custom Transparent Table
" TYPE:  TRANSP (Transparent Table - maps 1:1 to a DB table)
"
" HOW TO CREATE IN SAP:
"   1. Go to transaction SE11
"   2. Select "Database table", enter ZZ_EMPLOYEES, click Create
"   3. Enter short description, set Delivery Class = A
"   4. Go to Fields tab and add each field below
"   5. Set table category = Transparent Table
"   6. Save and Activate (Ctrl+F3)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" FIELD          | KEY | TYPE | LEN | DESCRIPTION
" -------------------------------------------------------------
" MANDT          | X   | CLNT |  3  | Client (SAP mandatory)
" EMP_ID         | X   | NUMC |  8  | Employee ID (business key)
" FIRST_NAME     |     | CHAR | 40  | First Name
" LAST_NAME      |     | CHAR | 40  | Last Name
" DEPARTMENT     |     | CHAR | 20  | Department
" SALARY         |     | CURR | 13,2| Monthly Salary
" CURRENCY       |     | CUKY |  5  | Currency Key (e.g. USD, EUR)
" HIRE_DATE      |     | DATS |  8  | Hire Date (YYYYMMDD)
" EMAIL          |     | CHAR |100  | Email Address
" CREATED_BY     |     | CHAR | 12  | Audit: Created By (user)
" CREATED_ON     |     | DATS |  8  | Audit: Created On (date)
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" KEY DESIGN DECISIONS (explain these in interviews!):
"
" 1. MANDT field: Every SAP transparent table MUST start with
"    the client field. SAP is multi-client — this separates data
"    between clients (e.g. DEV / QA / PROD).
"
" 2. EMP_ID as NUMC not INT: NUMC is a numeric CHARACTER type.
"    It pads with leading zeros (e.g. 00000001) which is the SAP
"    standard for IDs. You'll see this in MATNR, LIFNR, KUNNR...
"
" 3. CURR + CUKY pair: SAP requires every CURR (currency amount)
"    field to be paired with a CUKY (currency key) field.
"    SALARY references CURRENCY in the same row.
"
" 4. Audit fields (CREATED_BY / CREATED_ON): Best practice.
"    Always know who created a record and when. In production
"    code these are populated automatically via SY-UNAME / SY-DATUM.
"
" 5. Z-prefix naming: All customer objects in SAP must start with
"    Y or Z to avoid conflicts with SAP standard objects.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
