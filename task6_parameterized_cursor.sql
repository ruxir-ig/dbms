USE ruchir;

CREATE TABLE O_Roll_Call (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    attendance_date DATE
);

CREATE TABLE N_Roll_Call (
    student_id INT,
    student_name VARCHAR(100),
    attendance_date DATE
);

DELIMITER $$

CREATE PROCEDURE Merge_Roll_Call(IN p_date DATE)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_student_name VARCHAR(100);
    DECLARE v_attendance_date DATE;
    DECLARE done INT DEFAULT 0;

    DECLARE cur_new_roll_call CURSOR FOR
    SELECT student_id, student_name, attendance_date
    FROM N_Roll_Call
    WHERE attendance_date = p_date;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_new_roll_call;
    read_loop: LOOP
        FETCH cur_new_roll_call INTO v_student_id, v_student_name, v_attendance_date;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM O_Roll_Call WHERE student_id = v_student_id) THEN
            INSERT INTO O_Roll_Call (student_id, student_name, attendance_date)
            VALUES (v_student_id, v_student_name, v_attendance_date);
        END IF;
    END LOOP;

    CLOSE cur_new_roll_call;
END$$

DELIMITER ;