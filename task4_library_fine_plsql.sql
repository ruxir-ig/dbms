CREATE DATABASE IF NOT EXISTS ruchir;
USE ruchir;

DROP TABLE IF EXISTS Fine;
DROP TABLE IF EXISTS Borrower;

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE Borrower (
    Roll_no INT,
    Name VARCHAR(50),
    Date_of_Issue DATE,
    Name_of_Book VARCHAR(100),
    Status CHAR(1),
    PRIMARY KEY(Roll_no, Name_of_Book)
);

CREATE TABLE Fine (
    Roll_no INT,
    Date DATE,
    Amt DECIMAL(10, 2)
);

INSERT INTO Borrower (Roll_no, Name, Date_of_Issue, Name_of_Book, Status)
VALUES
    (1, 'Riya', '2025-10-10', 'DBMS', 'I'),
    (2, 'Aarav', '2025-10-15', 'CN', 'I'),
    (3, 'Meera', '2025-10-20', 'AI', 'I'),
    (4, 'Karan', '2025-10-25', 'WT', 'I'),
    (5, 'Tanya', '2025-11-01', 'HCI', 'I');

SELECT * FROM Borrower;

DROP PROCEDURE IF EXISTS return_book;
DELIMITER $$

CREATE PROCEDURE return_book(IN rno INT, IN book VARCHAR(100))
BEGIN
    DECLARE issue_date DATE;
    DECLARE days_diff INT;
    DECLARE fine_amt DECIMAL(10, 2);

    -- Get issue date for given roll and book
    SELECT Date_of_Issue INTO issue_date
    FROM Borrower
    WHERE Roll_no = rno AND Name_of_Book = book AND Status = 'I';

    -- If record not found
    IF issue_date IS NULL THEN
        SELECT 'Invalid Roll Number or Book Name!' AS Message;
    ELSE
        -- Calculate number of days
        SET days_diff = DATEDIFF(CURDATE(), issue_date);

        -- Fine calculation
        IF days_diff BETWEEN 15 AND 30 THEN
            SET fine_amt = days_diff * 5;
        ELSEIF days_diff > 30 THEN
            SET fine_amt = days_diff * 50;
        ELSE
            SET fine_amt = 0;
        END IF;

        -- Update status
        UPDATE Borrower
        SET Status = 'R'
        WHERE Roll_no = rno AND Name_of_Book = book;

        -- Insert fine if applicable
        IF fine_amt > 0 THEN
            INSERT INTO Fine VALUES (rno, CURDATE(), fine_amt);
        END IF;

        -- Display message
        SELECT CONCAT('Book returned successfully. Days kept: ', days_diff, ', Fine: Rs ', fine_amt) AS Message;
    END IF;
END$$
DELIMITER ;

-- use madhura_db;
-- SET SQL_SAFE_UPDATES = 0;
-- CALL return_book(1, 'DBMS');