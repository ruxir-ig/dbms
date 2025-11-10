# Database Management Systems - Assignment Implementation Guide

## Complete Summary of All 7 Tasks

---

## Task 1: SQL DDL Statements

**File:** `task1_sql_ddl.sql`

### What You Need to Do:
1. Execute the SQL script in Oracle/MySQL database
2. Understand SQL DDL (Data Definition Language) commands

### Key Concepts Demonstrated:

#### **Database Objects Created:**
- **SEQUENCES**: Auto-incrementing number generators (`student_id_seq`, `course_id_seq`)
- **TABLES**:
  - `Department` - Stores department information
  - `Student` - Student records with foreign key to Department
  - `Course` - Course catalog
  - `Enrollment` - Many-to-many relationship between students and courses

- **CONSTRAINTS**:
  - `PRIMARY KEY` - Unique identifier for each record
  - `FOREIGN KEY` - Maintains referential integrity between tables
  - `CHECK` - Validates data (e.g., GPA between 0-4.0)
  - `UNIQUE` - Ensures no duplicate values
  - `NOT NULL` - Mandatory fields
  - `DEFAULT` - Auto-fills values if not provided

- **INDEXES**: Speed up queries
  - Regular indexes on frequently searched columns
  - Bitmap indexes on low-cardinality columns (like status)

- **VIEWS**: Virtual tables
  - `vw_active_students` - Shows only active students
  - `vw_course_enrollment_summary` - Enrollment statistics
  - `vw_student_transcript` - Student grade history

- **SYNONYMS**: Aliases for database objects
  - `Dept` for `Department`
  - `Stud` for `Student`

### How to Execute:
```sql
-- In SQL*Plus or MySQL Workbench
@task1_sql_ddl.sql
```

---

## Task 2: SQL DML Queries (10+ Queries)

**File:** `task2_sql_dml_queries.sql`

### What You Need to Do:
1. Execute each query section-by-section
2. Understand output of each query type
3. Learn JOIN types, subqueries, and aggregations

### Key Concepts Demonstrated:

#### **Query Types:**

1. **INNER JOIN** - Matches records from multiple tables
2. **LEFT OUTER JOIN** - Includes all records from left table, even without matches
3. **SELF JOIN** - Joins table to itself (employee-manager relationship)
4. **SUBQUERY with IN** - Filters using results from another query
5. **CORRELATED SUBQUERY** - Inner query depends on outer query
6. **AGGREGATE FUNCTIONS** - COUNT, AVG, MIN, MAX, SUM with GROUP BY
7. **COMPLEX SUBQUERIES** - Nested queries for advanced filtering
8. **UNION** - Combines results from multiple queries
9. **VIEWS** - Creates and queries virtual tables
10. **EXISTS** - Tests for existence of records
11. **CASE STATEMENTS** - Conditional logic in queries
12. **DATE FUNCTIONS** - MONTHS_BETWEEN, SYSDATE
13. **STRING FUNCTIONS** - UPPER, LOWER, SUBSTR, INSTR
14. **UPDATE with SUBQUERY** - Conditional updates
15. **DELETE with SUBQUERY** - Conditional deletions

### Sample Query Breakdown:

```sql
-- Query 5: Correlated Subquery
-- Finds employees earning more than their department average
SELECT e.emp_name, e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM Employee e2
    WHERE e2.department = e.department
);
```

### How to Execute:
```sql
@task2_sql_dml_queries.sql
```

---

## Task 3: MongoDB Queries (CRUD Operations)

**File:** `task3_mongodb_queries.js`

### What You Need to Do:
1. Start MongoDB server: `mongod`
2. Open MongoDB shell: `mongo` or `mongosh`
3. Execute script: `load('task3_mongodb_queries.js')`

### Key Concepts Demonstrated:

#### **CRUD Operations:**

**CREATE (Insert)**
```javascript
// Single document
db.students.insertOne({...})

// Multiple documents
db.students.insertMany([{...}, {...}])
```

**READ (Query)**
```javascript
// Find all
db.students.find()

// Find with conditions
db.students.find({ department: "Computer Science" })

// Find with operators
db.students.find({ gpa: { $gt: 3.5 } })
```

**UPDATE (Modify)**
```javascript
// Update one
db.students.updateOne(
    { student_id: 1001 },
    { $set: { gpa: 3.85 } }
)

// Update many
db.students.updateMany(
    { is_active: false },
    { $set: { is_active: true } }
)
```

**DELETE (Remove)**
```javascript
// Delete one
db.students.deleteOne({ student_id: 1006 })

// Delete many
db.students.deleteMany({ is_active: false })
```

#### **Logical Operators:**
- `$and` - All conditions must be true
- `$or` - At least one condition must be true
- `$not` - Negates condition
- `$nor` - None of the conditions should be true

#### **Comparison Operators:**
- `$eq` - Equal to
- `$ne` - Not equal to
- `$gt` - Greater than
- `$gte` - Greater than or equal
- `$lt` - Less than
- `$lte` - Less than or equal
- `$in` - In array
- `$nin` - Not in array

#### **Array Operators:**
- `$push` - Add element to array
- `$pull` - Remove element from array
- `$all` - Matches arrays containing all elements

#### **Aggregation:**
```javascript
db.students.aggregate([
    { $match: { is_active: true } },
    { $group: { _id: "$department", avg_gpa: { $avg: "$gpa" } } },
    { $sort: { avg_gpa: -1 } }
])
```

### How to Execute:
```bash
# Start MongoDB
mongod

# In another terminal
mongo
> use studentDB
> load('task3_mongodb_queries.js')
```

---

## Task 4: PL/SQL Block - Library Fine Calculation

**File:** `task4_library_fine_plsql.sql`

### What You Need to Do:
1. Enable server output: `SET SERVEROUTPUT ON;`
2. Execute the script
3. Provide inputs when prompted (Roll_no and Book_name)

### Business Logic:

**Fine Calculation Rules:**
- **Days 1-14**: No fine
- **Days 15-30**: Rs 5 per day
- **Days > 30**:
  - First 30 days: Rs 5 per day (Rs 150)
  - After 30 days: Rs 50 per day

### Key Concepts Demonstrated:

#### **PL/SQL Blocks:**
```sql
DECLARE
    -- Variable declarations
    v_roll_no NUMBER;
    v_fine_amount NUMBER := 0;
BEGIN
    -- Executable statements
    -- IF-ELSIF-ELSE logic
    -- INSERT/UPDATE statements
EXCEPTION
    -- Exception handling
    WHEN NO_DATA_FOUND THEN
        -- Handle error
END;
```

#### **Control Structures:**
- `IF...THEN...ELSIF...ELSE...END IF` - Conditional branching
- `CASE` - Alternative to multiple IF statements

#### **Exception Handling:**
- **Named Exceptions**: `NO_DATA_FOUND`, `TOO_MANY_ROWS`
- **User-defined Exceptions**: `book_already_returned`
- `RAISE` - Trigger exception
- `RAISE_APPLICATION_ERROR` - Custom error with code

#### **Database Operations:**
- `SELECT...INTO` - Fetch data into variables
- `INSERT` - Add fine record
- `UPDATE` - Change book status to 'Returned'
- `COMMIT` - Save changes
- `ROLLBACK` - Undo changes

### Sample Execution:
```sql
SET SERVEROUTPUT ON;
@task4_library_fine_plsql.sql

-- When prompted:
Enter value for roll_no: 101
Enter value for name_of_book: Database Systems
```

---

## Task 5: Import/Export Operations

**File:** `task5_import_export.sql`

### What You Need to Do:
1. Understand different methods for exporting/importing data
2. Create necessary directories
3. Grant appropriate permissions

### Key Concepts Demonstrated:

#### **EXPORT Methods:**

**1. SQL*Plus SPOOL (Text/CSV)**
```sql
SET COLSEP ','
SPOOL /tmp/employees.csv
SELECT * FROM Employee_Export;
SPOOL OFF
```

**2. UTL_FILE Package (PL/SQL)**
```sql
DECLARE
    v_file UTL_FILE.FILE_TYPE;
BEGIN
    v_file := UTL_FILE.FOPEN('EXPORT_DIR', 'output.csv', 'W');
    UTL_FILE.PUT_LINE(v_file, 'data');
    UTL_FILE.FCLOSE(v_file);
END;
```

**3. Data Pump (expdp) - Command Line**
```bash
expdp username/password \
    DIRECTORY=dp_dir \
    DUMPFILE=export.dmp \
    TABLES=Employee_Export
```

**4. External Tables**
```sql
CREATE TABLE emp_ext
ORGANIZATION EXTERNAL (...)
AS SELECT * FROM Employee;
```

#### **IMPORT Methods:**

**1. SQL*Loader (sqlldr) - Command Line**
```bash
sqlldr username/password \
    CONTROL=import.ctl \
    LOG=import.log
```

**2. External Tables**
```sql
CREATE TABLE emp_import
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY ext_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
    )
    LOCATION ('data.csv')
);

INSERT INTO Employee SELECT * FROM emp_import;
```

**3. Data Pump (impdp)**
```bash
impdp username/password \
    DIRECTORY=dp_dir \
    DUMPFILE=import.dmp
```

### File Formats Supported:
- **CSV** - Comma-separated values
- **TXT** - Plain text
- **XLSX** - Excel (with conversion)
- **DMP** - Oracle binary format (Data Pump)

### Prerequisites:
```sql
-- Create directory
CREATE OR REPLACE DIRECTORY export_dir AS '/tmp/db_exports';

-- Grant permissions
GRANT READ, WRITE ON DIRECTORY export_dir TO username;
```

---

## Task 6: Parameterized Cursor - Roll Call Merge

**File:** `task6_parameterized_cursor.sql`

### What You Need to Do:
1. Execute script to create tables and sample data
2. Run the main PL/SQL block
3. Observe how data is merged from O_Roll_Call to N_Roll_Call

### Key Concepts Demonstrated:

#### **Cursor Types:**

**1. Implicit Cursor**
- Automatically created by Oracle for DML statements
- Access using `SQL%` attributes
```sql
UPDATE table SET ...;
IF SQL%ROWCOUNT > 0 THEN
    -- Rows were updated
END IF;
```

**2. Explicit Cursor**
```sql
DECLARE
    CURSOR emp_cursor IS
        SELECT * FROM employees;
    v_emp employees%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_emp;
        EXIT WHEN emp_cursor%NOTFOUND;
        -- Process record
    END LOOP;
    CLOSE emp_cursor;
END;
```

**3. Cursor FOR Loop** (Simplest)
```sql
FOR record IN (SELECT * FROM table) LOOP
    -- Process record
END LOOP;
-- Automatically opens, fetches, and closes
```

**4. Parameterized Cursor**
```sql
DECLARE
    CURSOR emp_cursor(p_dept VARCHAR2) IS
        SELECT * FROM employees
        WHERE department = p_dept;
BEGIN
    -- Use with different parameters
    FOR emp IN emp_cursor('IT') LOOP
        -- Process IT employees
    END LOOP;

    FOR emp IN emp_cursor('HR') LOOP
        -- Process HR employees
    END LOOP;
END;
```

#### **Cursor Attributes:**
- `%FOUND` - TRUE if last fetch returned a row
- `%NOTFOUND` - TRUE if last fetch didn't return a row
- `%ROWCOUNT` - Number of rows fetched so far
- `%ISOPEN` - TRUE if cursor is open

### Business Logic:
The program merges attendance records from `O_Roll_Call` (old table) to `N_Roll_Call` (new table):
- If record exists in N_Roll_Call → Skip it
- If record doesn't exist → Insert it
- Uses parameterized cursor to process by class

### Sample Output:
```
========================================
ROLL CALL MERGE PROCESS
========================================
Processing Class: CS-A
----------------------------------------
  SKIPPED: Roll 101 - Alice Johnson (Already exists)
  INSERTED: Roll 102 - Bob Smith [Present]
  INSERTED: Roll 104 - David Brown [Late]
----------------------------------------
Total Records Processed: 8
Records Inserted: 6
Records Skipped: 2
========================================
```

---

## Task 7: Database Connectivity (Python)

**File:** `task7_database_connectivity.py`

### What You Need to Do:
1. Install required packages:
   ```bash
   # For MySQL
   pip install mysql-connector-python

   # For Oracle
   pip install cx_Oracle
   ```

2. Run the program:
   ```bash
   python task7_database_connectivity.py
   ```

3. Choose database type (MySQL/Oracle)
4. Provide connection credentials
5. Use interactive menu for CRUD operations

### Key Concepts Demonstrated:

#### **Database Operations:**

**1. Connection Management**
```python
# MySQL
import mysql.connector
connection = mysql.connector.connect(
    host='localhost',
    user='root',
    password='password',
    database='testdb'
)

# Oracle
import cx_Oracle
connection = cx_Oracle.connect(
    user='system',
    password='password',
    dsn='localhost:1521/xe'
)
```

**2. CRUD Operations**

**CREATE (Add)**
```python
def add_student(name, email, dept, gpa, date):
    query = "INSERT INTO students VALUES (%s, %s, %s, %s, %s)"
    cursor.execute(query, (name, email, dept, gpa, date))
    connection.commit()
```

**READ (View)**
```python
def view_all_students():
    query = "SELECT * FROM students"
    cursor.execute(query)
    students = cursor.fetchall()
    for student in students:
        print(student)
```

**UPDATE (Edit)**
```python
def update_student(id, name=None, email=None):
    query = "UPDATE students SET name=%s, email=%s WHERE id=%s"
    cursor.execute(query, (name, email, id))
    connection.commit()
```

**DELETE (Remove)**
```python
def delete_student(id):
    query = "DELETE FROM students WHERE student_id=%s"
    cursor.execute(query, (id,))
    connection.commit()
```

#### **Interactive Menu System:**
```
1. Add New Student
2. View All Students
3. Search Student by ID
4. Update Student Information
5. Delete Student
6. Exit
```

### Program Features:
- **Two Database Implementations**: MySQL and Oracle
- **Object-Oriented Design**: Separate classes for each database
- **Error Handling**: Try-catch blocks for all operations
- **User Input Validation**: Checks for valid data
- **Transaction Management**: Commit/Rollback operations
- **Dynamic Queries**: Builds UPDATE queries based on provided fields
- **Connection Pooling**: Proper open/close of connections

### MySQL vs Oracle Differences:

| Feature | MySQL | Oracle |
|---------|-------|--------|
| Auto-increment | AUTO_INCREMENT | SEQUENCE |
| Placeholder | %s | :name |
| Date format | Direct string | TO_DATE() |
| Driver | mysql-connector-python | cx_Oracle |

---

## Complete Execution Guide

### Step 1: Setup Environment

**For SQL Tasks (1, 2, 4, 5, 6):**
```bash
# Oracle SQL*Plus
sqlplus username/password@database

# MySQL
mysql -u username -p
```

**For MongoDB Task (3):**
```bash
# Start MongoDB server
mongod

# Open MongoDB shell
mongo
```

**For Python Task (7):**
```bash
# Install dependencies
pip install mysql-connector-python cx_Oracle

# Run program
python task7_database_connectivity.py
```

### Step 2: Execute Each Task

**Task 1 - DDL:**
```sql
@task1_sql_ddl.sql
```

**Task 2 - DML:**
```sql
@task2_sql_dml_queries.sql
```

**Task 3 - MongoDB:**
```javascript
load('task3_mongodb_queries.js')
```

**Task 4 - Library Fine:**
```sql
SET SERVEROUTPUT ON;
@task4_library_fine_plsql.sql
-- Provide inputs when prompted
```

**Task 5 - Import/Export:**
```sql
-- First create directories
CREATE DIRECTORY export_dir AS '/tmp/exports';
@task5_import_export.sql
```

**Task 6 - Cursors:**
```sql
SET SERVEROUTPUT ON;
@task6_parameterized_cursor.sql
```

**Task 7 - Connectivity:**
```bash
python task7_database_connectivity.py
```

---

## Key Learning Outcomes

### SQL Skills:
- ✓ Creating database objects (tables, views, indexes, sequences)
- ✓ Defining constraints for data integrity
- ✓ Writing complex queries with joins and subqueries
- ✓ Using aggregate functions and grouping
- ✓ Implementing set operations (UNION, INTERSECT)

### PL/SQL Skills:
- ✓ Writing anonymous blocks with variables
- ✓ Implementing control structures (IF, CASE, LOOP)
- ✓ Handling exceptions (system and user-defined)
- ✓ Using cursors (all types)
- ✓ Managing transactions (COMMIT/ROLLBACK)

### MongoDB Skills:
- ✓ CRUD operations on NoSQL database
- ✓ Using logical and comparison operators
- ✓ Querying nested documents and arrays
- ✓ Aggregation pipeline
- ✓ Indexing for performance

### Programming Skills:
- ✓ Database connectivity from application layer
- ✓ Implementing complete CRUD operations
- ✓ Error handling and validation
- ✓ User interface design (menu systems)
- ✓ Working with multiple database systems

---

## Common Issues and Solutions

### Issue 1: Permission Denied for Directory
**Solution:**
```sql
-- As DBA user
CREATE DIRECTORY export_dir AS '/tmp/exports';
GRANT READ, WRITE ON DIRECTORY export_dir TO username;
```

### Issue 2: SERVEROUTPUT not displaying
**Solution:**
```sql
SET SERVEROUTPUT ON SIZE 1000000;
```

### Issue 3: MongoDB connection refused
**Solution:**
```bash
# Start MongoDB service
sudo systemctl start mongod
# Or
sudo service mongod start
```

### Issue 4: Python MySQL module not found
**Solution:**
```bash
pip install --upgrade mysql-connector-python
# Or
pip3 install mysql-connector-python
```

### Issue 5: Oracle sequence not incrementing
**Solution:**
```sql
-- Drop and recreate sequence
DROP SEQUENCE student_id_seq;
CREATE SEQUENCE student_id_seq START WITH 1 INCREMENT BY 1;
```

---

## Testing Your Implementation

### Task 1 (DDL):
```sql
-- Verify tables created
SELECT table_name FROM user_tables;

-- Verify constraints
SELECT constraint_name, constraint_type FROM user_constraints;

-- Verify indexes
SELECT index_name FROM user_indexes;
```

### Task 2 (DML):
```sql
-- Check row counts
SELECT COUNT(*) FROM Employee;
SELECT COUNT(*) FROM Project;

-- Test a complex query
SELECT e.emp_name, p.project_name
FROM Employee e
JOIN Assignment a ON e.emp_id = a.emp_id
JOIN Project p ON a.project_id = p.project_id;
```

### Task 3 (MongoDB):
```javascript
// Check database
show databases

// Check collections
show collections

// Count documents
db.students.countDocuments()
```

### Task 4 (PL/SQL):
```sql
-- Check fine records
SELECT * FROM Fine;

-- Check borrower status
SELECT Roll_no, Name, Status FROM Borrower;
```

### Task 6 (Cursors):
```sql
-- Verify merge
SELECT COUNT(*) FROM O_Roll_Call;
SELECT COUNT(*) FROM N_Roll_Call;

-- Check merged records
SELECT * FROM N_Roll_Call ORDER BY roll_no;
```

---

## What to Submit

1. **All 7 source files** (provided above)
2. **Screenshots** of execution for each task
3. **Output logs** showing successful execution
4. **This summary document** for reference

---

## Important Notes

### For Task 1:
- Make sure sequences start from appropriate values
- Test all constraints by trying to insert invalid data
- Verify foreign key relationships work correctly

### For Task 2:
- Understand the difference between INNER and OUTER joins
- Practice writing subqueries independently
- Learn when to use UNION vs UNION ALL

### For Task 3:
- MongoDB doesn't enforce schemas - be careful with data types
- Understand the difference between updateOne and updateMany
- Practice aggregation pipelines

### For Task 4:
- Test with different date ranges to verify fine calculation
- Test exception handling with invalid roll numbers
- Ensure status changes from 'I' to 'R'

### For Task 5:
- Create directories with proper permissions before running
- Test both export and import operations
- Verify data integrity after import

### For Task 6:
- Understand when to use each cursor type
- Practice parameterized cursors with different parameters
- Monitor performance with large datasets

### For Task 7:
- Test all CRUD operations thoroughly
- Handle database connection errors gracefully
- Implement proper input validation

---

## Additional Resources

### SQL Reference:
- Oracle Documentation: https://docs.oracle.com/database/
- MySQL Documentation: https://dev.mysql.com/doc/

### MongoDB:
- MongoDB Manual: https://docs.mongodb.com/manual/

### Python DB-API:
- MySQL Connector: https://dev.mysql.com/doc/connector-python/
- cx_Oracle: https://cx-oracle.readthedocs.io/

---

## Final Checklist

- [ ] Task 1: DDL statements executed successfully
- [ ] Task 2: All 15 queries produce correct output
- [ ] Task 3: MongoDB CRUD operations work
- [ ] Task 4: Library fine calculation correct
- [ ] Task 5: Export and import operations successful
- [ ] Task 6: Cursor merge completes without errors
- [ ] Task 7: Python program connects and performs CRUD
- [ ] All screenshots captured
- [ ] All files ready for submission

---

## Contact Information

If you encounter issues:
1. Check error messages carefully
2. Verify database connections and permissions
3. Review syntax for your specific database version
4. Test each component individually before integration

Good luck with your assignment! 🎓

---

**Document Created:** November 2024
**Version:** 1.0
**Total Tasks:** 7
**Total Files:** 7 + 1 Summary
