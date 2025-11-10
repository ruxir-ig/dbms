-- Task 4: Unnamed PL/SQL Block - Library Fine Calculation System
-- Uses Control Structures and Exception Handling

-- First, create the required tables
CREATE TABLE Borrower (
    Roll_no NUMBER(6) PRIMARY KEY,
    Name VARCHAR2(50) NOT NULL,
    Date_of_Issue DATE,
    Name_of_Book VARCHAR2(100),
    Status VARCHAR2(1) CHECK (Status IN ('I', 'R')) -- I=Issued, R=Returned
);

CREATE TABLE Fine (
    Roll_no NUMBER(6),
    Fine_Date DATE,
    Fine_Amt NUMBER(8,2),
    FOREIGN KEY (Roll_no) REFERENCES Borrower(Roll_no)
);

-- Insert sample data
INSERT INTO Borrower VALUES (101, 'Alice Johnson', TO_DATE('2024-10-01', 'YYYY-MM-DD'), 'Database Systems', 'I');
INSERT INTO Borrower VALUES (102, 'Bob Smith', TO_DATE('2024-10-20', 'YYYY-MM-DD'), 'Data Structures', 'I');
INSERT INTO Borrower VALUES (103, 'Carol White', TO_DATE('2024-09-15', 'YYYY-MM-DD'), 'Algorithms', 'I');
INSERT INTO Borrower VALUES (104, 'David Brown', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Operating Systems', 'I');
INSERT INTO Borrower VALUES (105, 'Emma Davis', TO_DATE('2024-08-10', 'YYYY-MM-DD'), 'Computer Networks', 'I');

COMMIT;

-- ============================================================================
-- PL/SQL BLOCK - Library Fine Calculation with Exception Handling
-- ============================================================================

DECLARE
    -- Variables to store input
    v_roll_no Borrower.Roll_no%TYPE;
    v_book_name Borrower.Name_of_Book%TYPE;

    -- Variables for calculation
    v_issue_date Borrower.Date_of_Issue%TYPE;
    v_days_diff NUMBER;
    v_fine_amount NUMBER(8,2) := 0;
    v_current_status Borrower.Status%TYPE;

    -- User-defined exception
    book_already_returned EXCEPTION;
    invalid_roll_number EXCEPTION;

BEGIN
    -- Accept input from user
    v_roll_no := &Roll_no;
    v_book_name := '&Name_of_Book';

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('LIBRARY FINE CALCULATION SYSTEM');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Roll Number: ' || v_roll_no);
    DBMS_OUTPUT.PUT_LINE('Book Name: ' || v_book_name);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- Fetch borrower details
    BEGIN
        SELECT Date_of_Issue, Status
        INTO v_issue_date, v_current_status
        FROM Borrower
        WHERE Roll_no = v_roll_no
        AND Name_of_Book = v_book_name;

        -- Check if book is already returned
        IF v_current_status = 'R' THEN
            RAISE book_already_returned;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE invalid_roll_number;
    END;

    -- Calculate number of days since issue
    v_days_diff := TRUNC(SYSDATE - v_issue_date);

    DBMS_OUTPUT.PUT_LINE('Date of Issue: ' || TO_CHAR(v_issue_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('Current Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('Days Outstanding: ' || v_days_diff);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- Calculate fine based on number of days
    IF v_days_diff >= 15 AND v_days_diff <= 30 THEN
        -- Fine is Rs 5 per day for 15-30 days
        v_fine_amount := 5 * v_days_diff;
        DBMS_OUTPUT.PUT_LINE('Fine Category: 15-30 days @ Rs 5/day');

    ELSIF v_days_diff > 30 THEN
        -- Fine is Rs 50 per day for days > 30
        -- And Rs 5 per day for days <= 30
        v_fine_amount := (50 * (v_days_diff - 30)) + (5 * 30);
        DBMS_OUTPUT.PUT_LINE('Fine Category: >30 days @ Rs 50/day');
        DBMS_OUTPUT.PUT_LINE('(First 30 days @ Rs 5/day = Rs ' || (5 * 30));
        DBMS_OUTPUT.PUT_LINE('Additional ' || (v_days_diff - 30) || ' days @ Rs 50/day = Rs ' || (50 * (v_days_diff - 30)) || ')');

    ELSE
        -- No fine for days < 15
        v_fine_amount := 0;
        DBMS_OUTPUT.PUT_LINE('Fine Category: No fine (within 15 days)');
    END IF;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL FINE AMOUNT: Rs ' || v_fine_amount);
    DBMS_OUTPUT.PUT_LINE('========================================');

    -- If fine is applicable, insert into Fine table
    IF v_fine_amount > 0 THEN
        INSERT INTO Fine (Roll_no, Fine_Date, Fine_Amt)
        VALUES (v_roll_no, SYSDATE, v_fine_amount);

        DBMS_OUTPUT.PUT_LINE('Fine record inserted successfully.');
    END IF;

    -- Update status to Returned
    UPDATE Borrower
    SET Status = 'R'
    WHERE Roll_no = v_roll_no
    AND Name_of_Book = v_book_name;

    DBMS_OUTPUT.PUT_LINE('Book status updated to RETURNED.');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transaction committed successfully.');
    DBMS_OUTPUT.PUT_LINE('========================================');

EXCEPTION
    WHEN book_already_returned THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: This book has already been returned!');
        DBMS_OUTPUT.PUT_LINE('No action taken.');

    WHEN invalid_roll_number THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid Roll Number or Book Name!');
        DBMS_OUTPUT.PUT_LINE('No matching record found in the system.');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: An unexpected error occurred!');
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================================
-- Alternative Version: Using Named Exception Handler
-- ============================================================================

DECLARE
    -- Variables
    v_roll_no Borrower.Roll_no%TYPE := &Roll_no;
    v_book_name Borrower.Name_of_Book%TYPE := '&Name_of_Book';
    v_issue_date Borrower.Date_of_Issue%TYPE;
    v_days_diff NUMBER;
    v_fine_amount NUMBER(8,2);
    v_status Borrower.Status%TYPE;

    -- Custom exceptions
    e_already_returned EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_already_returned, -20001);

BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PROCESSING BOOK RETURN ===' || CHR(10));

    -- Retrieve book issue information
    SELECT Date_of_Issue, Status
    INTO v_issue_date, v_status
    FROM Borrower
    WHERE Roll_no = v_roll_no AND Name_of_Book = v_book_name;

    -- Check if already returned
    IF v_status = 'R' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Book already returned');
    END IF;

    -- Calculate days difference
    v_days_diff := TRUNC(SYSDATE - v_issue_date);

    -- Determine fine using CASE statement
    v_fine_amount := CASE
        WHEN v_days_diff < 15 THEN 0
        WHEN v_days_diff BETWEEN 15 AND 30 THEN v_days_diff * 5
        ELSE (30 * 5) + ((v_days_diff - 30) * 50)
    END;

    -- Display calculation details
    DBMS_OUTPUT.PUT_LINE('Student: ' || v_roll_no);
    DBMS_OUTPUT.PUT_LINE('Book: ' || v_book_name);
    DBMS_OUTPUT.PUT_LINE('Days: ' || v_days_diff);
    DBMS_OUTPUT.PUT_LINE('Fine: Rs ' || v_fine_amount);

    -- Insert fine record if applicable
    IF v_fine_amount > 0 THEN
        INSERT INTO Fine VALUES (v_roll_no, SYSDATE, v_fine_amount);
        DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Fine record created successfully!');
    ELSE
        DBMS_OUTPUT.PUT_LINE(CHR(10) || 'No fine applicable - returned within grace period.');
    END IF;

    -- Update borrower status
    UPDATE Borrower
    SET Status = 'R'
    WHERE Roll_no = v_roll_no AND Name_of_Book = v_book_name;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Book return processed successfully!' || CHR(10));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No such borrower record found!');
    WHEN e_already_returned THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================================
-- Test Queries
-- ============================================================================

-- Enable output display
SET SERVEROUTPUT ON;

-- View all borrower records
SELECT * FROM Borrower ORDER BY Roll_no;

-- View all fine records
SELECT b.Roll_no, b.Name, b.Name_of_Book, f.Fine_Date, f.Fine_Amt
FROM Borrower b
JOIN Fine f ON b.Roll_no = f.Roll_no
ORDER BY f.Fine_Date DESC;

-- Summary Report
SELECT
    b.Roll_no,
    b.Name,
    b.Name_of_Book,
    b.Date_of_Issue,
    b.Status,
    TRUNC(SYSDATE - b.Date_of_Issue) as Days_Outstanding,
    NVL(f.Fine_Amt, 0) as Fine_Amount
FROM Borrower b
LEFT JOIN Fine f ON b.Roll_no = f.Roll_no
ORDER BY Days_Outstanding DESC;

-- Clean up (commented out to preserve data)
-- DROP TABLE Fine;
-- DROP TABLE Borrower;
