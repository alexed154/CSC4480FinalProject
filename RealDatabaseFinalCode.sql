----------- Dropping Tables -----------
Drop Table Students;


----------- Creating Tables -----------
----- Student Table -----
CREATE TABLE student (
    student_id  VARCHAR(10)  PRIMARY KEY NOT NULL,
    first_name  VARCHAR(20)  NOT NULL,
    last_name   VARCHAR(20)  NOT NULL,
    email       VARCHAR(20)  NOT NULL UNIQUE
);

----- Course Table -----
CREATE SEQUENCE course_seq START 1;
CREATE TABLE course (
    course_id      VARCHAR(10)  PRIMARY KEY NOT NULL
                                DEFAULT 'C' || LPAD(nextval('course_seq')::TEXT, 9, '0'),
    department     VARCHAR(10)  NOT NULL,
    course_number  VARCHAR(6)   NOT NULL UNIQUE,
    course_name    VARCHAR(30)  NOT NULL UNIQUE,
    semester       VARCHAR(10)  NOT NULL CHECK (semester IN ('Spring', 'Summer', 'Fall')),
    academic_year           VARCHAR(4)   NOT NULL
);

----- Enrollment Table -----
CREATE SEQUENCE enrollment_seq START 1;
CREATE TABLE enrollment (
    enrollment_id  VARCHAR(10)  PRIMARY KEY NOT NULL
                                DEFAULT 'E' || LPAD(nextval('enrollment_seq')::TEXT, 9, '0'),
    student_id     VARCHAR(10)  NOT NULL REFERENCES student(student_id)  ON DELETE CASCADE,
    course_id      VARCHAR(10)  NOT NULL REFERENCES course(course_id)    ON DELETE CASCADE,
    grade_cached   DECIMAL(5,2),
    UNIQUE (student_id, course_id)
);
-- Trigger: enforce max 5 students per course
CREATE OR REPLACE FUNCTION check_enrollment_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM enrollment WHERE course_id = NEW.course_id) >= 5 THEN
        RAISE EXCEPTION
            'Course % already has 5 enrolled students (maximum reached).', NEW.course_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 
CREATE TRIGGER trg_enrollment_limit
BEFORE INSERT ON enrollment
FOR EACH ROW EXECUTE FUNCTION check_enrollment_limit();

----- Grading Category -----

Insert into Students
Values('2026ABCDEF', 'Alexander', 'Edmonds', 'aedmonds');
Insert into Students
Values('2026ZYXWVU', 'Spongebob', 'Squarepants', 'ssquarepants');

select * from Students;

