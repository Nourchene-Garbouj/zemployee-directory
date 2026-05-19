"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CLASS: ZCL_EMPLOYEE_DAO
" DESC:  Data Access Object — handles all DB operations
"        for the ZZ_EMPLOYEES table (CRUD)
"
" HOW TO CREATE IN SAP:
"   1. Go to transaction SE24 (Class Builder)
"   2. Enter class name: ZCL_EMPLOYEE_DAO
"   3. Click Create
"   4. Set description: "Employee Data Access Object (CRUD)"
"   5. Set instantiation: Public
"   6. Add each method from this file
"   7. Save and Activate (Ctrl+F3)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS zcl_employee_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Reuse the type we defined in ZCL_EMPLOYEE
    TYPES:
      ty_employee     TYPE zcl_employee=>ty_employee,
      ty_employee_tab TYPE TABLE OF zcl_employee=>ty_employee.

    METHODS:

      "------------------------------------------------------------
      " CREATE — insert one employee into the DB
      " Usage: lo_dao->create( lo_employee )
      "------------------------------------------------------------
      create
        IMPORTING
          io_employee      TYPE REF TO zcl_employee
        RETURNING
          VALUE(rv_success) TYPE abap_bool,

      "------------------------------------------------------------
      " READ ONE — fetch a single employee by ID
      " Usage: ls_emp = lo_dao->read( '00000001' )
      "------------------------------------------------------------
      read
        IMPORTING
          iv_emp_id        TYPE numc8
        RETURNING
          VALUE(rs_employee) TYPE ty_employee,

      "------------------------------------------------------------
      " READ ALL — fetch all employees (optionally filter by dept)
      " Usage: lt_emps = lo_dao->read_all( )
      "         lt_emps = lo_dao->read_all( 'FINANCE' )
      "------------------------------------------------------------
      read_all
        IMPORTING
          iv_department    TYPE char20 OPTIONAL
        RETURNING
          VALUE(rt_employees) TYPE ty_employee_tab,

      "------------------------------------------------------------
      " UPDATE — update salary and/or department of an employee
      " Usage: lo_dao->update( iv_emp_id = '00000001'
      "                        iv_salary = 5000 )
      "------------------------------------------------------------
      update
        IMPORTING
          iv_emp_id        TYPE numc8
          iv_department    TYPE char20 OPTIONAL
          iv_salary        TYPE p DECIMALS 2 OPTIONAL
          iv_email         TYPE char100 OPTIONAL
        RETURNING
          VALUE(rv_success) TYPE abap_bool,

      "------------------------------------------------------------
      " DELETE — remove an employee record by ID
      " Usage: lo_dao->delete( '00000001' )
      "------------------------------------------------------------
      delete
        IMPORTING
          iv_emp_id        TYPE numc8
        RETURNING
          VALUE(rv_success) TYPE abap_bool,

      "------------------------------------------------------------
      " EXISTS — check if an employee ID already exists
      " Usage: IF lo_dao->exists( '00000001' ) = abap_true.
      "------------------------------------------------------------
      exists
        IMPORTING
          iv_emp_id        TYPE numc8
        RETURNING
          VALUE(rv_exists)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_employee_dao IMPLEMENTATION.

  "------------------------------------------------------------
  " CREATE
  "------------------------------------------------------------
  METHOD create.
    " Get the employee data as a flat structure
    DATA ls_employee TYPE ty_employee.
    ls_employee = io_employee->get_as_structure( ).

    " Check if this ID already exists — avoid duplicates
    IF exists( ls_employee-emp_id ) = abap_true.
      rv_success = abap_false.
      RETURN.
    ENDIF.

    " INSERT into the database table
    " sy-mandt = current client (SAP fills this automatically)
    INSERT zz_employees FROM @ls_employee.

    " SY-SUBRC is SAP's return code variable
    " 0 = success, anything else = something went wrong
    IF sy-subrc = 0.
      rv_success = abap_true.
    ELSE.
      rv_success = abap_false.
    ENDIF.

  ENDMETHOD.

  "------------------------------------------------------------
  " READ ONE
  "------------------------------------------------------------
  METHOD read.
    " SELECT SINGLE = fetch exactly one row by primary key
    SELECT SINGLE *
      FROM zz_employees
      WHERE emp_id = @iv_emp_id
      INTO @rs_employee.

    " If nothing found, SY-SUBRC will be non-zero
    " rs_employee will just be empty — caller should check
    IF sy-subrc <> 0.
      CLEAR rs_employee.
    ENDIF.

  ENDMETHOD.

  "------------------------------------------------------------
  " READ ALL
  "------------------------------------------------------------
  METHOD read_all.

    IF iv_department IS SUPPLIED AND iv_department IS NOT INITIAL.
      " Filter by department if one was passed in
      SELECT *
        FROM zz_employees
        WHERE department = @iv_department
        ORDER BY emp_id
        INTO TABLE @rt_employees.
    ELSE.
      " No filter — return all employees
      SELECT *
        FROM zz_employees
        ORDER BY emp_id
        INTO TABLE @rt_employees.
    ENDIF.

  ENDMETHOD.

  "------------------------------------------------------------
  " UPDATE
  "------------------------------------------------------------
  METHOD update.
    " First check the record exists
    IF exists( iv_emp_id ) = abap_false.
      rv_success = abap_false.
      RETURN.
    ENDIF.

    " Read the current record
    DATA ls_employee TYPE ty_employee.
    ls_employee = read( iv_emp_id ).

    " Only update the fields that were actually passed in
    " IS SUPPLIED = the caller explicitly passed a value
    IF iv_department IS SUPPLIED AND iv_department IS NOT INITIAL.
      ls_employee-department = iv_department.
    ENDIF.

    IF iv_salary IS SUPPLIED AND iv_salary > 0.
      ls_employee-salary = iv_salary.
    ENDIF.

    IF iv_email IS SUPPLIED AND iv_email IS NOT INITIAL.
      ls_employee-email = iv_email.
    ENDIF.

    " UPDATE writes the changed structure back to the DB
    UPDATE zz_employees FROM @ls_employee.

    IF sy-subrc = 0.
      rv_success = abap_true.
    ELSE.
      rv_success = abap_false.
    ENDIF.

  ENDMETHOD.

  "------------------------------------------------------------
  " DELETE
  "------------------------------------------------------------
  METHOD delete.
    " Check it exists first
    IF exists( iv_emp_id ) = abap_false.
      rv_success = abap_false.
      RETURN.
    ENDIF.

    " DELETE using the primary key
    DELETE FROM zz_employees
      WHERE emp_id = @iv_emp_id.

    IF sy-subrc = 0.
      rv_success = abap_true.
    ELSE.
      rv_success = abap_false.
    ENDIF.

  ENDMETHOD.

  "------------------------------------------------------------
  " EXISTS
  "------------------------------------------------------------
  METHOD exists.
    " SELECT COUNT(*) is the cleanest way to check existence
    DATA lv_count TYPE i.

    SELECT COUNT(*)
      FROM zz_employees
      WHERE emp_id = @iv_emp_id
      INTO @lv_count.

    IF lv_count > 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
