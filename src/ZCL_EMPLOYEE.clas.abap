"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CLASS: ZCL_EMPLOYEE
" DESC:  Employee entity class — represents a single employee
"
" HOW TO CREATE IN SAP:
"   1. Go to transaction SE24 (Class Builder)
"   2. Enter class name: ZCL_EMPLOYEE
"   3. Click Create
"   4. Set description: "Employee Entity Class"
"   5. Set instantiation: Public
"   6. Add each attribute and method from this file
"   7. Save and Activate (Ctrl+F3)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS zcl_employee DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    "------------------------------------------------------------
    " TYPES
    " Define a structure type that mirrors our DB table
    "------------------------------------------------------------
    TYPES:
      BEGIN OF ty_employee,
        emp_id     TYPE numc8,
        first_name TYPE char40,
        last_name  TYPE char40,
        department TYPE char20,
        salary     TYPE p DECIMALS 2,
        currency   TYPE waers,
        hire_date  TYPE dats,
        email      TYPE char100,
        created_by TYPE uname,
        created_on TYPE dats,
      END OF ty_employee.

    "------------------------------------------------------------
    " CONSTRUCTOR
    " Called when you do: lo_emp = NEW zcl_employee( ... )
    "------------------------------------------------------------
    METHODS:
      constructor
        IMPORTING
          iv_emp_id     TYPE numc8
          iv_first_name TYPE char40
          iv_last_name  TYPE char40
          iv_department TYPE char20
          iv_salary     TYPE p DECIMALS 2
          iv_currency   TYPE waers   DEFAULT 'USD'
          iv_hire_date  TYPE dats
          iv_email      TYPE char100 OPTIONAL,

      "------------------------------------------------------------
      " GETTERS — read each attribute
      "------------------------------------------------------------
      get_emp_id
        RETURNING VALUE(rv_emp_id) TYPE numc8,

      get_full_name
        RETURNING VALUE(rv_full_name) TYPE string,

      get_department
        RETURNING VALUE(rv_department) TYPE char20,

      get_salary
        RETURNING VALUE(rv_salary) TYPE p DECIMALS 2,

      get_currency
        RETURNING VALUE(rv_currency) TYPE waers,

      get_hire_date
        RETURNING VALUE(rv_hire_date) TYPE dats,

      get_email
        RETURNING VALUE(rv_email) TYPE char100,

      "------------------------------------------------------------
      " SETTERS — update each attribute
      "------------------------------------------------------------
      set_department
        IMPORTING iv_department TYPE char20,

      set_salary
        IMPORTING
          iv_salary   TYPE p DECIMALS 2
          iv_currency TYPE waers OPTIONAL,

      set_email
        IMPORTING iv_email TYPE char100,

      "------------------------------------------------------------
      " UTILITY METHODS
      "------------------------------------------------------------
      get_as_structure
        RETURNING VALUE(rs_employee) TYPE ty_employee,

      display.   "prints employee details to console

  PRIVATE SECTION.

    "------------------------------------------------------------
    " ATTRIBUTES — private, only accessible via getters/setters
    "------------------------------------------------------------
    DATA:
      mv_emp_id     TYPE numc8,
      mv_first_name TYPE char40,
      mv_last_name  TYPE char40,
      mv_department TYPE char20,
      mv_salary     TYPE p DECIMALS 2,
      mv_currency   TYPE waers,
      mv_hire_date  TYPE dats,
      mv_email      TYPE char100,
      mv_created_by TYPE uname,
      mv_created_on TYPE dats.

ENDCLASS.


CLASS zcl_employee IMPLEMENTATION.

  "------------------------------------------------------------
  " CONSTRUCTOR
  "------------------------------------------------------------
  METHOD constructor.
    mv_emp_id     = iv_emp_id.
    mv_first_name = iv_first_name.
    mv_last_name  = iv_last_name.
    mv_department = iv_department.
    mv_salary     = iv_salary.
    mv_currency   = iv_currency.
    mv_hire_date  = iv_hire_date.
    mv_email      = iv_email.

    " Audit fields: auto-populated from SAP system variables
    " SY-UNAME = current logged-in user
    " SY-DATUM = today's date
    mv_created_by = sy-uname.
    mv_created_on = sy-datum.
  ENDMETHOD.

  "------------------------------------------------------------
  " GETTERS
  "------------------------------------------------------------
  METHOD get_emp_id.
    rv_emp_id = mv_emp_id.
  ENDMETHOD.

  METHOD get_full_name.
    " Concatenate first and last name into one string
    rv_full_name = mv_first_name && ` ` && mv_last_name.
  ENDMETHOD.

  METHOD get_department.
    rv_department = mv_department.
  ENDMETHOD.

  METHOD get_salary.
    rv_salary = mv_salary.
  ENDMETHOD.

  METHOD get_currency.
    rv_currency = mv_currency.
  ENDMETHOD.

  METHOD get_hire_date.
    rv_hire_date = mv_hire_date.
  ENDMETHOD.

  METHOD get_email.
    rv_email = mv_email.
  ENDMETHOD.

  "------------------------------------------------------------
  " SETTERS
  "------------------------------------------------------------
  METHOD set_department.
    mv_department = iv_department.
  ENDMETHOD.

  METHOD set_salary.
    mv_salary = iv_salary.
    " Only update currency if a new one was passed in
    IF iv_currency IS SUPPLIED.
      mv_currency = iv_currency.
    ENDIF.
  ENDMETHOD.

  METHOD set_email.
    mv_email = iv_email.
  ENDMETHOD.

  "------------------------------------------------------------
  " UTILITY: get_as_structure
  " Returns all attributes packed into one structure
  " Used by the DAO class to insert/update the DB table
  "------------------------------------------------------------
  METHOD get_as_structure.
    rs_employee-emp_id     = mv_emp_id.
    rs_employee-first_name = mv_first_name.
    rs_employee-last_name  = mv_last_name.
    rs_employee-department = mv_department.
    rs_employee-salary     = mv_salary.
    rs_employee-currency   = mv_currency.
    rs_employee-hire_date  = mv_hire_date.
    rs_employee-email      = mv_email.
    rs_employee-created_by = mv_created_by.
    rs_employee-created_on = mv_created_on.
  ENDMETHOD.

  "------------------------------------------------------------
  " UTILITY: display
  " Prints a summary of the employee to the console
  " Useful for testing and debugging
  "------------------------------------------------------------
  METHOD display.
    WRITE: / '================================'.
    WRITE: / 'Employee ID  :', mv_emp_id.
    WRITE: / 'Full Name    :', get_full_name( ).
    WRITE: / 'Department   :', mv_department.
    WRITE: / 'Salary       :', mv_salary, mv_currency.
    WRITE: / 'Hire Date    :', mv_hire_date.
    WRITE: / 'Email        :', mv_email.
    WRITE: / 'Created By   :', mv_created_by.
    WRITE: / 'Created On   :', mv_created_on.
    WRITE: / '================================'.
  ENDMETHOD.

ENDCLASS.
