--===================================--
----------- Dropping Tables -----------
--===================================--
DROP TABLE student;
DROP TABLE score;
DROP TABLE assignment;
DROP TABLE grading_category;
DROP TABLE enrollment;
DROP TABLE course;


--===================================--
----------- Creating Tables -----------
--===================================--
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

----- Grading Category Table -----
CREATE SEQUENCE category_seq START 1;
 
CREATE TABLE grading_category (
    category_id     VARCHAR(10)   PRIMARY KEY NOT NULL
                                  DEFAULT 'GC' || LPAD(nextval('category_seq')::TEXT, 8, '0'),
    course_id       VARCHAR(10)   NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
    category_label  VARCHAR(20)   NOT NULL,
    weight_pct      DECIMAL(5,2)  NOT NULL CHECK (weight_pct > 0 AND weight_pct <= 100),
    UNIQUE (course_id, category_label)
);
 
-- Trigger: category weights for a course must not exceed 100
CREATE OR REPLACE FUNCTION check_category_weight_sum()
RETURNS TRIGGER AS $$
DECLARE
    total DECIMAL(6,2);
BEGIN
    SELECT COALESCE(SUM(weight_pct), 0)
      INTO total
      FROM grading_category
     WHERE course_id   = NEW.course_id
       AND category_id <> COALESCE(NEW.category_id, '');
 
    total := total + NEW.weight_pct;
 
    IF total > 100.00 THEN
        RAISE EXCEPTION
            'Category weights for course % would total %%, exceeding 100%%.',
            NEW.course_id, total;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 
CREATE TRIGGER trg_category_weight
BEFORE INSERT OR UPDATE ON grading_category
FOR EACH ROW EXECUTE FUNCTION check_category_weight_sum();

----- Assignment Table -----
CREATE SEQUENCE assignment_seq START 1;
CREATE TABLE assignment (
    assignment_id  VARCHAR(10)   PRIMARY KEY NOT NULL
                                 DEFAULT 'A' || LPAD(nextval('assignment_seq')::TEXT, 9, '0'),
    category_id    VARCHAR(10)   NOT NULL REFERENCES grading_category(category_id) ON DELETE CASCADE,
    title          VARCHAR(40)   NOT NULL,
    max_points     DECIMAL(6,2)  NOT NULL CHECK (max_points > 0),
    due_date       DATE
);

----- Score Table -----
CREATE SEQUENCE score_seq START 1;
 
CREATE TABLE score (
    score_id       VARCHAR(10)   PRIMARY KEY
                                 DEFAULT 'S' || LPAD(nextval('score_seq')::TEXT, 9, '0'),
    enrollment_id  VARCHAR(10)   NOT NULL REFERENCES enrollment(enrollment_id)  ON DELETE CASCADE,
    assignment_id  VARCHAR(10)   NOT NULL REFERENCES assignment(assignment_id)  ON DELETE CASCADE,
    points_earned  DECIMAL(6,2)  NOT NULL CHECK (points_earned >= 0),
    excused        INT           NOT NULL DEFAULT 0 CHECK (excused IN (0, 1)),
    UNIQUE (enrollment_id, assignment_id)
);
 
-- Trigger: points_earned cannot exceed assignment max_points (unless excused)
CREATE OR REPLACE FUNCTION check_score_max()
RETURNS TRIGGER AS $$
DECLARE
    max_pts DECIMAL(6,2);
BEGIN
    SELECT max_points INTO max_pts
      FROM assignment
     WHERE assignment_id = NEW.assignment_id;
 
    IF NEW.excused = 0 AND NEW.points_earned > max_pts THEN
        RAISE EXCEPTION
            'points_earned (%) cannot exceed max_points (%) for assignment %.',
            NEW.points_earned, max_pts, NEW.assignment_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 
CREATE TRIGGER trg_score_max
BEFORE INSERT OR UPDATE ON score
FOR EACH ROW EXECUTE FUNCTION check_score_max();

--=========================================--
----------- Inserting Sample Data -----------
--=========================================--
----- Students -----
Insert into student
Values('2026ABCDEF', 'Lebron', 'James', 'ljames');
Insert into student
Values('2029ZYXWVU', 'Spongebob', 'Squarepants', 'ssquarepants');
Insert into student
Values('2028HDJILA', 'Paul', 'Atreides', 'patreides');
Insert into student
Values('2025LKCAYH', 'Taylor', 'Swift', 'tswift');

----- Courses -----
INSERT INTO course (department, course_number, course_name, semester, year) VALUES
    ('CSC', '4480', 'Database Systems', 'Spring', '2026'),
    ('HIS', '2200', 'History of Ancient Rome', 'Fall', '2025'),
    ('MAT', '3150', 'Calculus III',  'Spring', '2026');
    
----- Enrollments -----
INSERT INTO enrollment (student_id, course_id) VALUES
    -- CSC 4480
    ('2026ABCDEF', 'C000000001'),   -- Lebron
    ('2029ZYXWVU', 'C000000001'),   -- Spongebob
    ('2028HDJILA', 'C000000001'),   -- Paul
    ('2025LKCAYH', 'C000000001'),   -- Taylor
    -- HIS 2200
    ('2026ABCDEF', 'C000000002'),   -- Lebron
    ('2029ZYXWVU', 'C000000002'),   -- Spongebob
    ('2028HDJILA', 'C000000002'),   -- Paul
    ('2025LKCAYH', 'C000000002'),   -- Taylor
    -- MAT 3150
    ('2026ABCDEF', 'C000000003'),   -- Lebron
    ('2029ZYXWVU', 'C000000003'),   -- Spongebob
    ('2028HDJILA', 'C000000003'),   -- Paul
    ('2025LKCAYH', 'C000000003');   -- Taylor
    
----- Grading Catergories -----    
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES
    -- CSC 4480
    ('C000000001', 'Participation', 10),
    ('C000000001', 'Homework',      20),
    ('C000000001', 'Tests',         50),
    ('C000000001', 'Projects',      20),
    -- HIS 2200
    ('C000000002', 'Participation', 20),
    ('C000000002', 'Essays',        30),
    ('C000000002', 'Exams',         50),
    -- MAT 3150
    ('C000000003', 'Homework',      10),
    ('C000000003', 'Quizzes',       40),
    ('C000000003', 'Final Exam',    50);

select * from Students;

