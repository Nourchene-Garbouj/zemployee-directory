"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PROGRAM: ZREPORT_EMPLOYEES
" DESC:    Employee Directory Report with ALV Grid output
"          Uses ZCL_EMPLOYEE and ZCL_EMPLOYEE_DAO
"
" HOW TO CREATE IN SAP:
"   1. Go to transaction SE38 (ABAP Editor)
"   2. Enter program name: ZREPORT_EMPLOYEES
"   3. Click Create
"   4. Set type: Executable Program
"   5. Set description: "Employee Directory Report"
"   6. Paste this code
"   7. Save and Activate (Ctrl+F3)
"   8. Run with F8
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

REPORT zreport_employees.

"------------------------------------------------------------
" TYPES — local structure for ALV display
"------------------------------------------------------------
TYPES:
  BEGIN OF ty_alv_row,
    emp_id     TYPE numc8,
    first_name TYPE char40,
    last_name  TYPE char40,
    department TYPE char20,
    salary     TYPE p DECIMALS 2,
    currency   TYPE waers,
    hire_date  TYPE dats,
    email      TYPE char100,
  END OF ty_alv_row,
  ty_alv_tab TYPE TABLE OF ty_alv_row.

"------------------------------------------------------------
" SELECTION SCREEN
" This is the filter screen the user sees when running report
"------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  " Filter by Employee ID range
  SELECT-OPTIONS so_empid FOR ('NUMC8')
    NO INTERVALS
    MODIF ID emp.

  " Filter by Department (single value)
  PARAMETERS p_dept TYPE char20 OPTIONAL.

  " Checkbox: show only employees hired this year
  PARAMETERS p_new  TYPE abap_bool AS CHECKBOX DEFAULT ' '.

SELECTION-SCREEN END OF BLOCK b1.

"------------------------------------------------------------
" INITIALIZATION
" Runs once when the report is first called
" We set default selection screen values here
"------------------------------------------------------------
INITIALIZATION.
  TEXT-001 = 'Employee Filter Options'.

"------------------------------------------------------------
" START-OF-SELECTION
" Main program logic — runs when user clicks Execute (F8)
"------------------------------------------------------------
START-OF-SELECTION.

  " 1. Create DAO instance
  DATA lo_dao TYPE REF TO zcl_employee_dao.
  lo_dao = NEW zcl_employee_dao( ).

  " 2. Fetch data from DB using DAO
  DATA lt_employees TYPE zcl_employee_dao=>ty_employee_tab.

  IF p_dept IS NOT INITIAL.
    " Fetch filtered by department
    lt_employees = lo_dao->read_all( p_dept ).
  ELSE.
    " Fetch all employees
    lt_employees = lo_dao->read_all( ).
  ENDIF.

  " 3. Apply additional filters
  DATA lt_alv TYPE ty_alv_tab.
  DATA ls_alv TYPE ty_alv_row.

  LOOP AT lt_employees INTO DATA(ls_emp).

    " Filter by Employee ID if selection was entered
    IF so_empid[] IS NOT INITIAL.
      CHECK ls_emp-emp_id IN so_empid.
    ENDIF.

    " Filter: only hired this year if checkbox is ticked
    IF p_new = abap_true.
      DATA lv_year TYPE char4.
      lv_year = sy-datum(4).         " First 4 chars of today = year
      CHECK ls_emp-hire_date(4) = lv_year.
    ENDIF.

    " Map DB structure to ALV display structure
    CLEAR ls_alv.
    ls_alv-emp_id     = ls_emp-emp_id.
    ls_alv-first_name = ls_emp-first_name.
    ls_alv-last_name  = ls_emp-last_name.
    ls_alv-department = ls_emp-department.
    ls_alv-salary     = ls_emp-salary.
    ls_alv-currency   = ls_emp-currency.
    ls_alv-hire_date  = ls_emp-hire_date.
    ls_alv-email      = ls_emp-email.

    APPEND ls_alv TO lt_alv.

  ENDLOOP.

  " 4. Check if we have any results
  IF lt_alv IS INITIAL.
    MESSAGE 'No employees found matching your criteria.' TYPE 'I'.
    RETURN.
  ENDIF.

  " 5. Display ALV Grid
  PERFORM display_alv USING lt_alv.

"------------------------------------------------------------
" FORM: display_alv
" Builds and shows the ALV Grid using CL_SALV_TABLE
" CL_SALV_TABLE is the modern, OOP way to build ALV reports
"------------------------------------------------------------
FORM display_alv USING it_alv TYPE ty_alv_tab.

  " ALV object reference
  DATA lo_alv     TYPE REF TO cl_salv_table.
  DATA lo_columns TYPE REF TO cl_salv_columns_table.
  DATA lo_column  TYPE REF TO cl_salv_column_table.
  DATA lo_display TYPE REF TO cl_salv_display_settings.
  DATA lo_funcs   TYPE REF TO cl_salv_functions_list.

  " CL_SALV_TABLE->FACTORY creates the ALV instance
  " It needs the internal table passed by reference
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = it_alv
      ).
    CATCH cx_salv_msg INTO DATA(lx_error).
      MESSAGE lx_error->get_text( ) TYPE 'E'.
      RETURN.
  ENDTRY.

  " --- FUNCTIONS (toolbar buttons) ---
  lo_funcs = lo_alv->get_functions( ).
  lo_funcs->set_all( abap_true ).   " Enable all standard buttons
                                     " (sort, filter, export to Excel...)

  " --- DISPLAY SETTINGS ---
  lo_display = lo_alv->get_display_settings( ).
  lo_display->set_list_header( 'Employee Directory' ).
  lo_display->set_striped_pattern( abap_true ).  " Zebra stripes

  " --- COLUMN SETTINGS ---
  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( abap_true ).   " Auto-fit column widths

  " Customize each column header label
  TRY.
      lo_column ?= lo_columns->get_column( 'EMP_ID' ).
      lo_column->set_long_text( 'Employee ID' ).
      lo_column->set_medium_text( 'Emp. ID' ).

      lo_column ?= lo_columns->get_column( 'FIRST_NAME' ).
      lo_column->set_long_text( 'First Name' ).

      lo_column ?= lo_columns->get_column( 'LAST_NAME' ).
      lo_column->set_long_text( 'Last Name' ).

      lo_column ?= lo_columns->get_column( 'DEPARTMENT' ).
      lo_column->set_long_text( 'Department' ).

      lo_column ?= lo_columns->get_column( 'SALARY' ).
      lo_column->set_long_text( 'Monthly Salary' ).
      lo_column->set_medium_text( 'Salary' ).

      lo_column ?= lo_columns->get_column( 'CURRENCY' ).
      lo_column->set_long_text( 'Currency' ).

      lo_column ?= lo_columns->get_column( 'HIRE_DATE' ).
      lo_column->set_long_text( 'Hire Date' ).

      lo_column ?= lo_columns->get_column( 'EMAIL' ).
      lo_column->set_long_text( 'Email Address' ).
      lo_column->set_visible( abap_false ).  " Hidden by default, user can show it

    CATCH cx_salv_not_found.
      " Column not found — safe to ignore
  ENDTRY.

  " --- DISPLAY ---
  lo_alv->display( ).

ENDFORM.
