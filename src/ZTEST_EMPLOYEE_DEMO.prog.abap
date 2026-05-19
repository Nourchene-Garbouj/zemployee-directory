"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PROGRAM: ZTEST_EMPLOYEE_DEMO
" DESC:    Demo/test program for the Employee Directory project
"          Creates sample data and exercises all CRUD operations
"
" HOW TO CREATE IN SAP:
"   1. Go to transaction SE38 (ABAP Editor)
"   2. Enter program name: ZTEST_EMPLOYEE_DEMO
"   3. Click Create → type: Executable Program
"   4. Paste this code, Save and Activate (Ctrl+F3)
"   5. Run with F8 — check the console output
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

REPORT ztest_employee_demo.

START-OF-SELECTION.

  WRITE: / '=============================================='.
  WRITE: / '   EMPLOYEE DIRECTORY — DEMO PROGRAM'.
  WRITE: / '=============================================='.
  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 1: Create DAO instance
  "------------------------------------------------------------
  DATA lo_dao TYPE REF TO zcl_employee_dao.
  lo_dao = NEW zcl_employee_dao( ).

  WRITE: / '--- STEP 1: Creating sample employees ---'.

  "------------------------------------------------------------
  " STEP 2: Create 3 employee objects and insert into DB
  "------------------------------------------------------------

  " Employee 1
  DATA lo_emp1 TYPE REF TO zcl_employee.
  lo_emp1 = NEW zcl_employee(
    iv_emp_id     = '00000001'
    iv_first_name = 'Alice'
    iv_last_name  = 'Johnson'
    iv_department = 'FINANCE'
    iv_salary     = '4500.00'
    iv_currency   = 'USD'
    iv_hire_date  = '20230115'
    iv_email      = 'alice.johnson@company.com'
  ).

  " Employee 2
  DATA lo_emp2 TYPE REF TO zcl_employee.
  lo_emp2 = NEW zcl_employee(
    iv_emp_id     = '00000002'
    iv_first_name = 'Bob'
    iv_last_name  = 'Martinez'
    iv_department = 'IT'
    iv_salary     = '5200.00'
    iv_currency   = 'USD'
    iv_hire_date  = '20220601'
    iv_email      = 'bob.martinez@company.com'
  ).

  " Employee 3
  DATA lo_emp3 TYPE REF TO zcl_employee.
  lo_emp3 = NEW zcl_employee(
    iv_emp_id     = '00000003'
    iv_first_name = 'Sara'
    iv_last_name  = 'Chen'
    iv_department = 'HR'
    iv_salary     = '4800.00'
    iv_currency   = 'USD'
    iv_hire_date  = '20240301'
    iv_email      = 'sara.chen@company.com'
  ).

  "------------------------------------------------------------
  " STEP 3: INSERT all 3 into the database using DAO
  "------------------------------------------------------------
  DATA lv_success TYPE abap_bool.

  lv_success = lo_dao->create( lo_emp1 ).
  IF lv_success = abap_true.
    WRITE: / '✔ Created: Alice Johnson (00000001)'.
  ELSE.
    WRITE: / '✘ Failed to create Alice (already exists?)'.
  ENDIF.

  lv_success = lo_dao->create( lo_emp2 ).
  IF lv_success = abap_true.
    WRITE: / '✔ Created: Bob Martinez (00000002)'.
  ELSE.
    WRITE: / '✘ Failed to create Bob (already exists?)'.
  ENDIF.

  lv_success = lo_dao->create( lo_emp3 ).
  IF lv_success = abap_true.
    WRITE: / '✔ Created: Sara Chen (00000003)'.
  ELSE.
    WRITE: / '✘ Failed to create Sara (already exists?)'.
  ENDIF.

  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 4: READ — fetch one employee by ID
  "------------------------------------------------------------
  WRITE: / '--- STEP 2: Reading employee 00000001 ---'.

  DATA ls_emp TYPE zcl_employee_dao=>ty_employee.
  ls_emp = lo_dao->read( '00000001' ).

  IF ls_emp-emp_id IS NOT INITIAL.
    WRITE: / 'Found:' , ls_emp-first_name , ls_emp-last_name.
    WRITE: / 'Dept: '  , ls_emp-department.
    WRITE: / 'Salary:' , ls_emp-salary , ls_emp-currency.
  ELSE.
    WRITE: / '✘ Employee 00000001 not found.'.
  ENDIF.

  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 5: READ ALL — fetch all employees
  "------------------------------------------------------------
  WRITE: / '--- STEP 3: Reading all employees ---'.

  DATA lt_all TYPE zcl_employee_dao=>ty_employee_tab.
  lt_all = lo_dao->read_all( ).

  WRITE: / 'Total employees found:' , lines( lt_all ).

  LOOP AT lt_all INTO DATA(ls_row).
    WRITE: / '  >' , ls_row-emp_id , ls_row-first_name ,
              ls_row-last_name , '|' , ls_row-department ,
              '|' , ls_row-salary , ls_row-currency.
  ENDLOOP.

  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 6: READ ALL filtered by department
  "------------------------------------------------------------
  WRITE: / '--- STEP 4: Reading IT department only ---'.

  DATA lt_it TYPE zcl_employee_dao=>ty_employee_tab.
  lt_it = lo_dao->read_all( 'IT' ).

  WRITE: / 'IT employees found:' , lines( lt_it ).
  LOOP AT lt_it INTO DATA(ls_it).
    WRITE: / '  >' , ls_it-first_name , ls_it-last_name.
  ENDLOOP.

  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 7: UPDATE — give Bob a raise and move to FINANCE
  "------------------------------------------------------------
  WRITE: / '--- STEP 5: Updating Bob Martinez ---'.

  lv_success = lo_dao->update(
    iv_emp_id    = '00000002'
    iv_salary    = '6000.00'
    iv_department = 'FINANCE'
  ).

  IF lv_success = abap_true.
    WRITE: / '✔ Bob updated — new salary: 6000 USD, dept: FINANCE'.
  ELSE.
    WRITE: / '✘ Update failed.'.
  ENDIF.

  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 8: EXISTS — check before delete
  "------------------------------------------------------------
  WRITE: / '--- STEP 6: Checking if 00000003 exists ---'.

  DATA lv_exists TYPE abap_bool.
  lv_exists = lo_dao->exists( '00000003' ).

  IF lv_exists = abap_true.
    WRITE: / '✔ Employee 00000003 exists in the system.'.
  ELSE.
    WRITE: / '✘ Employee 00000003 does not exist.'.
  ENDIF.

  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 9: DELETE — remove Sara Chen
  "------------------------------------------------------------
  WRITE: / '--- STEP 7: Deleting Sara Chen (00000003) ---'.

  lv_success = lo_dao->delete( '00000003' ).

  IF lv_success = abap_true.
    WRITE: / '✔ Sara Chen deleted successfully.'.
  ELSE.
    WRITE: / '✘ Delete failed.'.
  ENDIF.

  WRITE: / ' '.

  "------------------------------------------------------------
  " STEP 10: Final state — show remaining employees
  "------------------------------------------------------------
  WRITE: / '--- STEP 8: Final state of the directory ---'.

  DATA lt_final TYPE zcl_employee_dao=>ty_employee_tab.
  lt_final = lo_dao->read_all( ).

  WRITE: / 'Remaining employees:' , lines( lt_final ).
  LOOP AT lt_final INTO DATA(ls_final).
    WRITE: / '  >' , ls_final-emp_id , ls_final-first_name ,
              ls_final-last_name , '|' , ls_final-department ,
              '|' , ls_final-salary , ls_final-currency.
  ENDLOOP.

  WRITE: / ' '.
  WRITE: / '=============================================='.
  WRITE: / '   DEMO COMPLETE'.
  WRITE: / '=============================================='.
