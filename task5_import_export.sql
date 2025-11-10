-- Task 5: Exporting and Importing Data
-- Demonstrates exporting tables to external files (CSV, XLSX, TXT) and importing data

-- ============================================================================
-- PART 1: EXPORTING DATA FROM DATABASE TO EXTERNAL FILES
-- ============================================================================

-- Create sample table for export demonstration
CREATE TABLE Employee_Export (
    emp_id NUMBER(6) PRIMARY KEY,
    emp_name VARCHAR2(50),
    department VARCHAR2(30),
    salary NUMBER(10,2),
    hire_date DATE,
    email VARCHAR2(100)
);

-- Insert sample data
INSERT INTO Employee_Export VALUES (1001, 'John Smith', 'IT', 75000, TO_DATE('2020-01-15', 'YYYY-MM-DD'), 'john.smith@company.com');
INSERT INTO Employee_Export VALUES (1002, 'Sarah Johnson', 'HR', 65000, TO_DATE('2019-05-20', 'YYYY-MM-DD'), 'sarah.j@company.com');
INSERT INTO Employee_Export VALUES (1003, 'Mike Wilson', 'Finance', 80000, TO_DATE('2018-08-10', 'YYYY-MM-DD'), 'mike.w@company.com');
INSERT INTO Employee_Export VALUES (1004, 'Emily Brown', 'IT', 72000, TO_DATE('2021-03-25', 'YYYY-MM-DD'), 'emily.b@company.com');
INSERT INTO Employee_Export VALUES (1005, 'David Lee', 'Marketing', 68000, TO_DATE('2020-11-12', 'YYYY-MM-DD'), 'david.lee@company.com');
COMMIT;

-- ============================================================================
-- METHOD 1: Using SQL*Plus SPOOL (for TXT/CSV export)
-- ============================================================================

-- Set formatting options for clean output
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON
SET PAGESIZE 50000
SET LINESIZE 200
SET TERMOUT OFF
SET TRIMSPOOL ON
SET COLSEP ','

-- Spool to CSV file
SPOOL /tmp/employees_export.csv

SELECT emp_id, emp_name, department, salary,
       TO_CHAR(hire_date, 'YYYY-MM-DD') as hire_date, email
FROM Employee_Export;

SPOOL OFF

-- Reset settings
SET ECHO ON
SET FEEDBACK ON
SET TERMOUT ON

PROMPT Data exported to /tmp/employees_export.csv

-- ============================================================================
-- METHOD 2: Using UTL_FILE Package (PL/SQL Approach)
-- ============================================================================

-- Note: Requires directory object and appropriate permissions
-- Create directory (requires DBA privileges)
-- CREATE OR REPLACE DIRECTORY export_dir AS '/tmp/db_exports';
-- GRANT READ, WRITE ON DIRECTORY export_dir TO your_username;

DECLARE
    v_file UTL_FILE.FILE_TYPE;
    v_line VARCHAR2(4000);

    CURSOR emp_cursor IS
        SELECT emp_id, emp_name, department, salary,
               TO_CHAR(hire_date, 'YYYY-MM-DD') as hire_date, email
        FROM Employee_Export;
BEGIN
    -- Open file for writing
    v_file := UTL_FILE.FOPEN('EXPORT_DIR', 'employees_utl_file.csv', 'W');

    -- Write header
    v_line := 'EMP_ID,EMP_NAME,DEPARTMENT,SALARY,HIRE_DATE,EMAIL';
    UTL_FILE.PUT_LINE(v_file, v_line);

    -- Write data rows
    FOR emp_rec IN emp_cursor LOOP
        v_line := emp_rec.emp_id || ',' ||
                  emp_rec.emp_name || ',' ||
                  emp_rec.department || ',' ||
                  emp_rec.salary || ',' ||
                  emp_rec.hire_date || ',' ||
                  emp_rec.email;
        UTL_FILE.PUT_LINE(v_file, v_line);
    END LOOP;

    -- Close file
    UTL_FILE.FCLOSE(v_file);

    DBMS_OUTPUT.PUT_LINE('Export completed successfully using UTL_FILE!');

EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(v_file) THEN
            UTL_FILE.FCLOSE(v_file);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- ============================================================================
-- METHOD 3: Using Oracle Data Pump (expdp) - Command Line
-- ============================================================================

-- Execute from command line (not SQL*Plus):
-- Create directory for data pump
-- CREATE OR REPLACE DIRECTORY dp_dir AS '/tmp/datapump';

-- Export entire table
-- expdp username/password DIRECTORY=dp_dir DUMPFILE=employee_export.dmp TABLES=Employee_Export

-- Export with query filter
-- expdp username/password DIRECTORY=dp_dir DUMPFILE=it_employees.dmp TABLES=Employee_Export QUERY='WHERE department=''IT'''

-- Export to CSV using external table
-- expdp username/password DIRECTORY=dp_dir DUMPFILE=emp.dmp TABLES=Employee_Export CONTENT=DATA_ONLY

-- ============================================================================
-- METHOD 4: Using External Table for CSV Export
-- ============================================================================

-- Create directory object
CREATE OR REPLACE DIRECTORY ext_dir AS '/tmp/external_tables';

-- Create external table definition for export
CREATE TABLE Employee_External_Export (
    emp_id NUMBER(6),
    emp_name VARCHAR2(50),
    department VARCHAR2(30),
    salary NUMBER(10,2),
    hire_date DATE,
    email VARCHAR2(100)
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_DATAPUMP
    DEFAULT DIRECTORY ext_dir
    LOCATION ('employee_export.dmp')
)
AS
SELECT * FROM Employee_Export;

PROMPT External table created for export

-- ============================================================================
-- PART 2: IMPORTING DATA FROM EXTERNAL FILES TO DATABASE
-- ============================================================================

-- Create table for import
CREATE TABLE Employee_Import (
    emp_id NUMBER(6) PRIMARY KEY,
    emp_name VARCHAR2(50),
    department VARCHAR2(30),
    salary NUMBER(10,2),
    hire_date DATE,
    email VARCHAR2(100)
);

-- ============================================================================
-- METHOD 1: Using SQL*Loader (sqlldr) - Command Line Tool
-- ============================================================================

-- Create control file: employee_import.ctl
-- Save the following content to employee_import.ctl:

/*
LOAD DATA
INFILE 'employees.csv'
BADFILE 'employees.bad'
DISCARDFILE 'employees.dis'
APPEND INTO TABLE Employee_Import
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    emp_id,
    emp_name,
    department,
    salary,
    hire_date DATE "YYYY-MM-DD",
    email
)
*/

-- Execute from command line:
-- sqlldr username/password CONTROL=employee_import.ctl LOG=employee_import.log

-- ============================================================================
-- METHOD 2: Using External Table for Import (CSV)
-- ============================================================================

-- First, create a CSV file at /tmp/employees_to_import.csv with content:
/*
1006,Alice Cooper,Sales,71000,2021-06-15,alice.c@company.com
1007,Bob Taylor,IT,76000,2020-09-20,bob.t@company.com
1008,Carol White,HR,63000,2022-01-10,carol.w@company.com
*/

-- Create external table to read CSV
CREATE TABLE Employee_External_Import (
    emp_id NUMBER(6),
    emp_name VARCHAR2(50),
    department VARCHAR2(30),
    salary NUMBER(10,2),
    hire_date DATE,
    email VARCHAR2(100)
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY ext_dir
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
        (
            emp_id,
            emp_name,
            department,
            salary,
            hire_date DATE 'YYYY-MM-DD',
            email
        )
    )
    LOCATION ('employees_to_import.csv')
)
REJECT LIMIT UNLIMITED;

-- Import data from external table
INSERT INTO Employee_Import
SELECT * FROM Employee_External_Import;

COMMIT;

PROMPT Data imported from CSV using external table

-- ============================================================================
-- METHOD 3: Using UTL_FILE to read and import
-- ============================================================================

DECLARE
    v_file UTL_FILE.FILE_TYPE;
    v_line VARCHAR2(4000);
    v_emp_id NUMBER(6);
    v_emp_name VARCHAR2(50);
    v_department VARCHAR2(30);
    v_salary NUMBER(10,2);
    v_hire_date DATE;
    v_email VARCHAR2(100);
    v_field_count NUMBER := 0;
BEGIN
    v_file := UTL_FILE.FOPEN('EXT_DIR', 'employees_to_import.csv', 'R');

    LOOP
        BEGIN
            UTL_FILE.GET_LINE(v_file, v_line);

            -- Skip header line
            IF v_field_count > 0 THEN
                -- Parse CSV line
                v_emp_id := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 1));
                v_emp_name := REGEXP_SUBSTR(v_line, '[^,]+', 1, 2);
                v_department := REGEXP_SUBSTR(v_line, '[^,]+', 1, 3);
                v_salary := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 4));
                v_hire_date := TO_DATE(REGEXP_SUBSTR(v_line, '[^,]+', 1, 5), 'YYYY-MM-DD');
                v_email := REGEXP_SUBSTR(v_line, '[^,]+', 1, 6);

                -- Insert into table
                INSERT INTO Employee_Import
                VALUES (v_emp_id, v_emp_name, v_department, v_salary, v_hire_date, v_email);
            END IF;

            v_field_count := v_field_count + 1;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
        END;
    END LOOP;

    UTL_FILE.FCLOSE(v_file);
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Import completed. Rows imported: ' || (v_field_count - 1));

EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(v_file) THEN
            UTL_FILE.FCLOSE(v_file);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================================
-- METHOD 4: Using Oracle Data Pump (impdp) - Command Line
-- ============================================================================

-- Execute from command line:
-- Import entire dump file
-- impdp username/password DIRECTORY=dp_dir DUMPFILE=employee_export.dmp TABLES=Employee_Export REMAP_TABLE=Employee_Export:Employee_Import

-- Import with table rename
-- impdp username/password DIRECTORY=dp_dir DUMPFILE=employee_export.dmp TABLES=Employee_Export REMAP_TABLE=Employee_Export:Employee_New

-- ============================================================================
-- METHOD 5: Insert from XLSX using External Table (Oracle 12c+)
-- ============================================================================

-- Note: Requires Oracle 12c or higher with proper drivers

-- Create external table for XLSX
CREATE TABLE Employee_XLSX_Import (
    emp_id,
    emp_name,
    department,
    salary,
    hire_date,
    email
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY ext_dir
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY '\t'
        (
            emp_id,
            emp_name,
            department,
            salary,
            hire_date DATE 'YYYY-MM-DD',
            email
        )
    )
    LOCATION ('employees.txt')
);

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Check exported data
SELECT * FROM Employee_Export ORDER BY emp_id;

-- Check imported data
SELECT * FROM Employee_Import ORDER BY emp_id;

-- Compare counts
SELECT 'EXPORT' as source, COUNT(*) as record_count FROM Employee_Export
UNION ALL
SELECT 'IMPORT' as source, COUNT(*) as record_count FROM Employee_Import;

-- ============================================================================
-- Alternative: Using DBMS_CLOUD (for Oracle Cloud)
-- ============================================================================

/*
-- Export to object storage
BEGIN
    DBMS_CLOUD.EXPORT_DATA(
        credential_name => 'OBJ_STORE_CRED',
        file_uri_list => 'https://objectstorage.region.oraclecloud.com/n/namespace/b/bucket/o/employees.csv',
        format => JSON_OBJECT('type' value 'csv', 'delimiter' value ','),
        query => 'SELECT * FROM Employee_Export'
    );
END;
/

-- Import from object storage
BEGIN
    DBMS_CLOUD.COPY_DATA(
        table_name => 'Employee_Import',
        credential_name => 'OBJ_STORE_CRED',
        file_uri_list => 'https://objectstorage.region.oraclecloud.com/n/namespace/b/bucket/o/employees.csv',
        format => JSON_OBJECT('type' value 'csv', 'delimiter' value ',', 'skipheaders' value '1')
    );
END;
/
*/

-- Cleanup (commented to preserve data)
-- DROP TABLE Employee_External_Export;
-- DROP TABLE Employee_External_Import;
-- DROP TABLE Employee_XLSX_Import;
-- DROP TABLE Employee_Export;
-- DROP TABLE Employee_Import;
-- DROP DIRECTORY export_dir;
-- DROP DIRECTORY ext_dir;

PROMPT Import/Export demonstration completed!
