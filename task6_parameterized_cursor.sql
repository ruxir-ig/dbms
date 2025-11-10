-- Task 6: Cursors - All Types (Implicit, Explicit, Cursor FOR Loop, Parameterized Cursor)
-- Merging data from O_Roll_Call to N_Roll_Call, skipping if data exists in second table

-- ============================================================================
-- Setup: Create Tables and Sample Data
-- ============================================================================

-- Create O_Roll_Call (Old Roll Call - Source Table)
CREATE TABLE O_Roll_Call (
    roll_no NUMBER(6) PRIMARY KEY,
    student_name VARCHAR2(50) NOT NULL,
    class VARCHAR2(20),
    attendance_date DATE,
    status VARCHAR2(10) CHECK (status IN ('Present', 'Absent', 'Late'))
);

-- Create N_Roll_Call (New Roll Call - Target Table)
CREATE TABLE N_Roll_Call (
    roll_no NUMBER(6) PRIMARY KEY,
    student_name VARCHAR2(50) NOT NULL,
    class VARCHAR2(20),
    attendance_date DATE,
    status VARCHAR2(10) CHECK (status IN ('Present', 'Absent', 'Late')),
    merge_date DATE DEFAULT SYSDATE
);

-- Insert sample data into O_Roll_Call (Old/Source table)
INSERT INTO O_Roll_Call VALUES (101, 'Alice Johnson', 'CS-A', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Present');
INSERT INTO O_Roll_Call VALUES (102, 'Bob Smith', 'CS-A', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Present');
INSERT INTO O_Roll_Call VALUES (103, 'Carol White', 'CS-B', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Absent');
INSERT INTO O_Roll_Call VALUES (104, 'David Brown', 'CS-A', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Late');
INSERT INTO O_Roll_Call VALUES (105, 'Emma Davis', 'CS-B', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Present');
INSERT INTO O_Roll_Call VALUES (106, 'Frank Wilson', 'CS-A', TO_DATE('2024-11-02', 'YYYY-MM-DD'), 'Present');
INSERT INTO O_Roll_Call VALUES (107, 'Grace Lee', 'CS-B', TO_DATE('2024-11-02', 'YYYY-MM-DD'), 'Absent');
INSERT INTO O_Roll_Call VALUES (108, 'Henry Clark', 'CS-A', TO_DATE('2024-11-02', 'YYYY-MM-DD'), 'Present');

-- Insert some existing data into N_Roll_Call (some records already exist to test skip logic)
INSERT INTO N_Roll_Call (roll_no, student_name, class, attendance_date, status)
VALUES (101, 'Alice Johnson', 'CS-A', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Present');
INSERT INTO N_Roll_Call (roll_no, student_name, class, attendance_date, status)
VALUES (103, 'Carol White', 'CS-B', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Absent');

COMMIT;

-- ============================================================================
-- EXAMPLE 1: IMPLICIT CURSOR
-- ============================================================================
-- Implicit cursors are automatically created by Oracle for DML statements

DECLARE
    v_rows_updated NUMBER;
BEGIN
    -- Implicit cursor is used here
    UPDATE O_Roll_Call
    SET status = 'Present'
    WHERE status = 'Late';

    -- SQL%ROWCOUNT gives number of rows affected by implicit cursor
    v_rows_updated := SQL%ROWCOUNT;

    DBMS_OUTPUT.PUT_LINE('Rows updated using Implicit Cursor: ' || v_rows_updated);

    ROLLBACK; -- Rollback to preserve original data
END;
/

-- ============================================================================
-- EXAMPLE 2: EXPLICIT CURSOR
-- ============================================================================

DECLARE
    -- Declare explicit cursor
    CURSOR student_cursor IS
        SELECT roll_no, student_name, class, attendance_date, status
        FROM O_Roll_Call
        ORDER BY roll_no;

    -- Variables to hold cursor data
    v_roll_no O_Roll_Call.roll_no%TYPE;
    v_student_name O_Roll_Call.student_name%TYPE;
    v_class O_Roll_Call.class%TYPE;
    v_attendance_date O_Roll_Call.attendance_date%TYPE;
    v_status O_Roll_Call.status%TYPE;
    v_count NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== EXPLICIT CURSOR DEMONSTRATION ===');

    -- Open cursor
    OPEN student_cursor;

    LOOP
        -- Fetch data from cursor
        FETCH student_cursor INTO v_roll_no, v_student_name, v_class, v_attendance_date, v_status;

        -- Exit when no more rows
        EXIT WHEN student_cursor%NOTFOUND;

        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Row ' || v_count || ': ' || v_roll_no || ' - ' || v_student_name || ' - ' || v_status);
    END LOOP;

    -- Close cursor
    CLOSE student_cursor;

    DBMS_OUTPUT.PUT_LINE('Total rows processed: ' || v_count);
END;
/

-- ============================================================================
-- EXAMPLE 3: CURSOR FOR LOOP
-- ============================================================================

DECLARE
    CURSOR student_cursor IS
        SELECT roll_no, student_name, class, status
        FROM O_Roll_Call
        WHERE status = 'Present';

    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== CURSOR FOR LOOP DEMONSTRATION ===');

    -- Cursor FOR loop automatically opens, fetches, and closes cursor
    FOR student_rec IN student_cursor LOOP
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(student_rec.roll_no || ' - ' || student_rec.student_name ||
                           ' [' || student_rec.class || '] - ' || student_rec.status);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total present students: ' || v_count);
END;
/

-- ============================================================================
-- EXAMPLE 4: PARAMETERIZED CURSOR
-- ============================================================================

DECLARE
    -- Parameterized cursor - accepts class as parameter
    CURSOR class_cursor(p_class VARCHAR2) IS
        SELECT roll_no, student_name, class, attendance_date, status
        FROM O_Roll_Call
        WHERE class = p_class
        ORDER BY roll_no;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PARAMETERIZED CURSOR DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Students in CS-A:');

    -- Use parameterized cursor with parameter 'CS-A'
    FOR student_rec IN class_cursor('CS-A') LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || student_rec.roll_no || ' - ' || student_rec.student_name ||
                           ' - ' || student_rec.status);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Students in CS-B:');

    -- Reuse same cursor with different parameter 'CS-B'
    FOR student_rec IN class_cursor('CS-B') LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || student_rec.roll_no || ' - ' || student_rec.student_name ||
                           ' - ' || student_rec.status);
    END LOOP;
END;
/

-- ============================================================================
-- MAIN TASK: Merge O_Roll_Call to N_Roll_Call using Parameterized Cursor
-- If data exists in N_Roll_Call (second table), skip it
-- ============================================================================

SET SERVEROUTPUT ON;

DECLARE
    -- Parameterized cursor to fetch records from O_Roll_Call by class
    CURSOR roll_call_cursor(p_class VARCHAR2) IS
        SELECT roll_no, student_name, class, attendance_date, status
        FROM O_Roll_Call
        WHERE class = p_class
        ORDER BY roll_no;

    -- Variable to check if record exists in N_Roll_Call
    v_exists NUMBER;

    -- Counters
    v_total_processed NUMBER := 0;
    v_inserted NUMBER := 0;
    v_skipped NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ROLL CALL MERGE PROCESS');
    DBMS_OUTPUT.PUT_LINE('From: O_Roll_Call -> To: N_Roll_Call');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');

    -- Process CS-A class
    DBMS_OUTPUT.PUT_LINE('Processing Class: CS-A');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    FOR student_rec IN roll_call_cursor('CS-A') LOOP
        v_total_processed := v_total_processed + 1;

        -- Check if record already exists in N_Roll_Call
        SELECT COUNT(*)
        INTO v_exists
        FROM N_Roll_Call
        WHERE roll_no = student_rec.roll_no
        AND attendance_date = student_rec.attendance_date;

        IF v_exists > 0 THEN
            -- Record exists, skip it
            DBMS_OUTPUT.PUT_LINE('  SKIPPED: Roll ' || student_rec.roll_no ||
                               ' - ' || student_rec.student_name ||
                               ' (Already exists in N_Roll_Call)');
            v_skipped := v_skipped + 1;
        ELSE
            -- Record doesn't exist, insert it
            INSERT INTO N_Roll_Call (roll_no, student_name, class, attendance_date, status)
            VALUES (student_rec.roll_no, student_rec.student_name, student_rec.class,
                   student_rec.attendance_date, student_rec.status);

            DBMS_OUTPUT.PUT_LINE('  INSERTED: Roll ' || student_rec.roll_no ||
                               ' - ' || student_rec.student_name ||
                               ' [' || student_rec.status || ']');
            v_inserted := v_inserted + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    -- Process CS-B class
    DBMS_OUTPUT.PUT_LINE('Processing Class: CS-B');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    FOR student_rec IN roll_call_cursor('CS-B') LOOP
        v_total_processed := v_total_processed + 1;

        -- Check if record already exists in N_Roll_Call
        SELECT COUNT(*)
        INTO v_exists
        FROM N_Roll_Call
        WHERE roll_no = student_rec.roll_no
        AND attendance_date = student_rec.attendance_date;

        IF v_exists > 0 THEN
            -- Record exists, skip it
            DBMS_OUTPUT.PUT_LINE('  SKIPPED: Roll ' || student_rec.roll_no ||
                               ' - ' || student_rec.student_name ||
                               ' (Already exists in N_Roll_Call)');
            v_skipped := v_skipped + 1;
        ELSE
            -- Record doesn't exist, insert it
            INSERT INTO N_Roll_Call (roll_no, student_name, class, attendance_date, status)
            VALUES (student_rec.roll_no, student_rec.student_name, student_rec.class,
                   student_rec.attendance_date, student_rec.status);

            DBMS_OUTPUT.PUT_LINE('  INSERTED: Roll ' || student_rec.roll_no ||
                               ' - ' || student_rec.student_name ||
                               ' [' || student_rec.status || ']');
            v_inserted := v_inserted + 1;
        END IF;
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('MERGE SUMMARY');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Total Records Processed: ' || v_total_processed);
    DBMS_OUTPUT.PUT_LINE('Records Inserted: ' || v_inserted);
    DBMS_OUTPUT.PUT_LINE('Records Skipped: ' || v_skipped);
    DBMS_OUTPUT.PUT_LINE('========================================');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- View O_Roll_Call (Source Table)
PROMPT
PROMPT === O_Roll_Call (Source Table) ===
SELECT * FROM O_Roll_Call ORDER BY roll_no;

-- View N_Roll_Call (Target Table)
PROMPT
PROMPT === N_Roll_Call (Target Table - After Merge) ===
SELECT roll_no, student_name, class, attendance_date, status,
       TO_CHAR(merge_date, 'YYYY-MM-DD HH24:MI:SS') as merge_timestamp
FROM N_Roll_Call
ORDER BY roll_no;

-- Count comparison
PROMPT
PROMPT === Record Count Comparison ===
SELECT 'O_Roll_Call' as table_name, COUNT(*) as record_count FROM O_Roll_Call
UNION ALL
SELECT 'N_Roll_Call' as table_name, COUNT(*) as record_count FROM N_Roll_Call;

-- ============================================================================
-- Advanced Example: Cursor with REF CURSOR
-- ============================================================================

DECLARE
    TYPE ref_cursor_type IS REF CURSOR;
    student_cursor ref_cursor_type;

    v_roll_no O_Roll_Call.roll_no%TYPE;
    v_student_name O_Roll_Call.student_name%TYPE;
    v_status O_Roll_Call.status%TYPE;
    v_class VARCHAR2(20) := 'CS-A';

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== REF CURSOR DEMONSTRATION ===');

    -- Open cursor dynamically
    OPEN student_cursor FOR
        SELECT roll_no, student_name, status
        FROM O_Roll_Call
        WHERE class = v_class;

    LOOP
        FETCH student_cursor INTO v_roll_no, v_student_name, v_status;
        EXIT WHEN student_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_roll_no || ' - ' || v_student_name || ' - ' || v_status);
    END LOOP;

    CLOSE student_cursor;
END;
/

-- Cleanup (commented to preserve data)
-- DROP TABLE N_Roll_Call;
-- DROP TABLE O_Roll_Call;
