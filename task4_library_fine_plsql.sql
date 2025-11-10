CREATE DATABASE empp;
USE empp;

CREATE TABLE Borrower (
Roll_no INT NOT NULL,
Name VARCHAR(100) NOT NULL,
Date_of_Issue DATE NOT NULL,

Name_of_Book VARCHAR(150) NOT NULL,
Status ENUM('I','R') NOT NULL DEFAULT 'I',
PRIMARY KEY (Roll_no, Name_of_Book),
CHECK (Status IN ('I','R'))
) ENGINE=InnoDB;

CREATE TABLE Fine (
Fine_id BIGINT PRIMARY KEY AUTO_INCREMENT,
Roll_no INT NOT NULL,
Date DATE NOT NULL,
Amt DECIMAL(10,2) NOT NULL,
CONSTRAINT fk_fine_roll FOREIGN KEY (Roll_no) REFERENCES
Borrower(Roll_no)
ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

INSERT INTO Borrower (Roll_no, Name, Date_of_Issue, Name_of_Book,
Status) VALUES

(101, 'Asha', DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'DBMS
Fundamentals', 'I'),

(102, 'Rahul', DATE_SUB(CURDATE(), INTERVAL 22 DAY), 'Operating
Systems', 'I'),

(103, 'Meera', DATE_SUB(CURDATE(), INTERVAL 45 DAY), 'Data Mining',
'I'),

(104, 'Vijay', DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Computer
Networks', 'R');
DELIMITER $$
CREATE PROCEDURE Return_Book (
IN p_roll_no INT,
IN p_book_name VARCHAR(150)
)
BEGIN

DECLARE v_date_issue DATE;
DECLARE v_days INT DEFAULT 0;
DECLARE v_fine DECIMAL(10,2) DEFAULT 0.00;

DECLARE v_sqlstate CHAR(5);
DECLARE v_message TEXT;

DECLARE no_issue_row CONDITION FOR SQLSTATE '45001';
DECLARE bad_days CONDITION FOR SQLSTATE '45002';

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;

GET DIAGNOSTICS CONDITION 1 v_sqlstate = RETURNED_SQLSTATE, v_message
=
MESSAGE_TEXT;
SELECT CONCAT('ERROR [', IFNULL(v_sqlstate,'?????'), ']: ',
IFNULL(v_message,'Unexpected failure')) AS Error;
END;
START TRANSACTION;

SELECT Date_of_Issue
INTO v_date_issue
FROM Borrower
WHERE Roll_no = p_roll_no
AND Name_of_Book = p_book_name
AND Status = 'I'
FOR UPDATE;

IF v_date_issue IS NULL THEN
SIGNAL no_issue_row
SET MESSAGE_TEXT = 'No active issue found (either wrong book/roll_no
or already
returned).';
END IF;

SET v_days = DATEDIFF(CURDATE(), v_date_issue);

IF v_days < 0 THEN
SIGNAL bad_days SET MESSAGE_TEXT = 'Issue date is in the future.
Please correct the
record.';
END IF;

IF v_days BETWEEN 15 AND 30 THEN
SET v_fine = v_days * 5;
ELSEIF v_days > 30 THEN
SET v_fine = v_days * 50;
ELSE
SET v_fine = 0;
END IF;

UPDATE Borrower
SET Status = 'R'
WHERE Roll_no = p_roll_no
AND Name_of_Book = p_book_name
AND Status = 'I';

IF v_fine > 0 THEN
INSERT INTO Fine (Roll_no, Date, Amt)
VALUES (p_roll_no, CURDATE(), v_fine);
END IF;
COMMIT;

SELECT
p_roll_no AS Roll_No,
p_book_name AS Book,
v_date_issue AS Date_of_Issue,
CURDATE() AS Return_Date,
v_days AS Total_Days,
v_fine AS Fine_Amount;
END $$
DELIMITER ;

CALL Return_Book(101, 'DBMS Fundamentals');

CALL Return_Book(102, 'Operating Systems');

CALL Return_Book(103, 'Data Mining');

CALL Return_Book(104, 'Computer Networks');

CALL Return_Book(999, 'Anything');

SELECT * FROM Borrower ORDER BY Roll_no;

SELECT * FROM Fine ORDER BY Fine_id