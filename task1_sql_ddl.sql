-- Task 1: SQL DDL Statements
-- Demonstrating SQL objects: Table, View, Index, Sequence, Synonym, Constraints

-- Create Sequence for auto-incrementing IDs
CREATE SEQUENCE student_id_seq
START WITH 1001
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE course_id_seq
START WITH 101
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Tables with various constraints
CREATE TABLE Department (
    dept_id NUMBER(4) PRIMARY KEY,
    dept_name VARCHAR2(50) NOT NULL UNIQUE,
    dept_head VARCHAR2(50),
    established_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_dept_name CHECK (LENGTH(dept_name) >= 2)
);

CREATE TABLE Student (
    student_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(30) NOT NULL,
    last_name VARCHAR2(30) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(15),
    enrollment_date DATE DEFAULT SYSDATE,
    dept_id NUMBER(4),
    gpa NUMBER(3,2) CHECK (gpa >= 0 AND gpa <= 4.0),
    status VARCHAR2(10) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Graduated')),
    CONSTRAINT fk_student_dept FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE SET NULL
);

CREATE TABLE Course (
    course_id NUMBER(5) PRIMARY KEY,
    course_code VARCHAR2(10) NOT NULL UNIQUE,
    course_name VARCHAR2(100) NOT NULL,
    credits NUMBER(2) CHECK (credits > 0 AND credits <= 6),
    dept_id NUMBER(4),
    instructor_name VARCHAR2(50),
    max_capacity NUMBER(3) DEFAULT 30,
    CONSTRAINT fk_course_dept FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE CASCADE
);

CREATE TABLE Enrollment (
    enrollment_id NUMBER(10) PRIMARY KEY,
    student_id NUMBER(10) NOT NULL,
    course_id NUMBER(5) NOT NULL,
    enrollment_date DATE DEFAULT SYSDATE,
    grade VARCHAR2(2) CHECK (grade IN ('A', 'B', 'C', 'D', 'F', 'W', 'I')),
    semester VARCHAR2(20) NOT NULL,
    academic_year NUMBER(4) NOT NULL,
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_enroll_course FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    CONSTRAINT uk_enrollment UNIQUE (student_id, course_id, semester, academic_year)
);

-- Create Indexes for performance optimization
CREATE INDEX idx_student_lastname ON Student(last_name);
CREATE INDEX idx_student_dept ON Student(dept_id);
CREATE INDEX idx_course_dept ON Course(dept_id);
CREATE INDEX idx_enrollment_student ON Enrollment(student_id);
CREATE INDEX idx_enrollment_course ON Enrollment(course_id);
CREATE BITMAP INDEX idx_student_status ON Student(status);

-- Create Views
CREATE VIEW vw_active_students AS
SELECT s.student_id, s.first_name, s.last_name, s.email,
       d.dept_name, s.gpa, s.enrollment_date
FROM Student s
LEFT JOIN Department d ON s.dept_id = d.dept_id
WHERE s.status = 'Active';

CREATE VIEW vw_course_enrollment_summary AS
SELECT c.course_code, c.course_name, c.instructor_name,
       COUNT(e.enrollment_id) as total_enrolled,
       c.max_capacity,
       (c.max_capacity - COUNT(e.enrollment_id)) as available_seats
FROM Course c
LEFT JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_name, c.instructor_name, c.max_capacity;

CREATE VIEW vw_student_transcript AS
SELECT s.student_id, s.first_name || ' ' || s.last_name as student_name,
       c.course_code, c.course_name, c.credits,
       e.grade, e.semester, e.academic_year
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
ORDER BY s.student_id, e.academic_year, e.semester;

-- Create Synonyms for easier access
CREATE SYNONYM Dept FOR Department;
CREATE SYNONYM Stud FOR Student;
CREATE PUBLIC SYNONYM ActiveStudents FOR vw_active_students;

-- Demonstrate ALTER TABLE statements
ALTER TABLE Student ADD (
    date_of_birth DATE,
    address VARCHAR2(200)
);

ALTER TABLE Student MODIFY (phone VARCHAR2(20));

ALTER TABLE Department ADD CONSTRAINT chk_dept_head CHECK (LENGTH(dept_head) >= 3);

-- Add comment to table
COMMENT ON TABLE Student IS 'Stores student information including personal details and academic status';
COMMENT ON COLUMN Student.gpa IS 'Grade Point Average on a 4.0 scale';

-- Sample Data Insertion using Sequence
INSERT INTO Department VALUES (1, 'Computer Science', 'Dr. Smith', TO_DATE('2000-01-15', 'YYYY-MM-DD'));
INSERT INTO Department VALUES (2, 'Mathematics', 'Dr. Johnson', TO_DATE('1995-08-20', 'YYYY-MM-DD'));
INSERT INTO Department VALUES (3, 'Physics', 'Dr. Williams', TO_DATE('1998-03-10', 'YYYY-MM-DD'));

INSERT INTO Student (student_id, first_name, last_name, email, phone, dept_id, gpa, status)
VALUES (student_id_seq.NEXTVAL, 'John', 'Doe', 'john.doe@university.edu', '1234567890', 1, 3.75, 'Active');

INSERT INTO Student (student_id, first_name, last_name, email, phone, dept_id, gpa, status)
VALUES (student_id_seq.NEXTVAL, 'Jane', 'Smith', 'jane.smith@university.edu', '9876543210', 2, 3.90, 'Active');

INSERT INTO Course (course_id, course_code, course_name, credits, dept_id, instructor_name)
VALUES (course_id_seq.NEXTVAL, 'CS101', 'Introduction to Programming', 4, 1, 'Prof. Anderson');

INSERT INTO Course (course_id, course_code, course_name, credits, dept_id, instructor_name)
VALUES (course_id_seq.NEXTVAL, 'MATH201', 'Calculus II', 3, 2, 'Prof. Brown');

-- Demonstrate DROP statements (commented out to preserve structure)
-- DROP SYNONYM Stud;
-- DROP VIEW vw_student_transcript;
-- DROP INDEX idx_student_lastname;
-- DROP TABLE Enrollment;
-- DROP SEQUENCE student_id_seq;
