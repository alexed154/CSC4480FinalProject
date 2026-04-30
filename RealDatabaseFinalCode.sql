--===================================================================--
----------- Dropping Tables/Sequences, Casading Constraints -----------
--===================================================================--
DROP TABLE score             CASCADE CONSTRAINTS;
DROP TABLE assignment        CASCADE CONSTRAINTS;
DROP TABLE grading_category  CASCADE CONSTRAINTS;
DROP TABLE enrollment        CASCADE CONSTRAINTS;
DROP TABLE course            CASCADE CONSTRAINTS;
DROP TABLE student           CASCADE CONSTRAINTS;

DROP SEQUENCE course_seq;
DROP SEQUENCE enrollment_seq;
DROP SEQUENCE category_seq;
DROP SEQUENCE assignment_seq;
DROP SEQUENCE score_seq;



--======================================--
----------- Creating Sequences -----------
--======================================--
CREATE SEQUENCE course_seq      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE enrollment_seq  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE category_seq    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE assignment_seq  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE score_seq       START WITH 1 INCREMENT BY 1;



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
CREATE TABLE course (
    course_id      VARCHAR(10)  DEFAULT 'C' || LPAD(course_seq.NEXTVAL, 9, '0') PRIMARY KEY NOT NULL,
    department     VARCHAR(10)  NOT NULL,
    course_number  VARCHAR(6)   NOT NULL UNIQUE,
    course_name    VARCHAR(30)  NOT NULL UNIQUE,
    semester       VARCHAR(10)  NOT NULL CHECK (semester IN ('Spring','Summer','Fall')),
    year           VARCHAR(4)   NOT NULL
);



----- Enrollment Table -----
CREATE TABLE enrollment (
    enrollment_id  VARCHAR(10)  DEFAULT 'E' || LPAD(enrollment_seq.NEXTVAL, 9, '0') PRIMARY KEY NOT NULL,
    student_id     VARCHAR(10)  NOT NULL REFERENCES student(student_id)  ON DELETE CASCADE,
    course_id      VARCHAR(10)  NOT NULL REFERENCES course(course_id)    ON DELETE CASCADE,
    grade_cached   NUMBER(5,2),
    UNIQUE (student_id, course_id)
);



----- Grading Category Table -----
CREATE TABLE grading_category (
    category_id     VARCHAR(10)  DEFAULT 'GC' || LPAD(category_seq.NEXTVAL, 8, '0') PRIMARY KEY NOT NULL,
    course_id       VARCHAR(10)  NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
    category_label  VARCHAR(20)  NOT NULL,
    weight_pct      NUMBER(5,2)   NOT NULL CHECK (weight_pct > 0 AND weight_pct <= 100),
    UNIQUE (course_id, category_label)
);
 


----- Assignment Table -----
CREATE TABLE assignment (
    assignment_id  VARCHAR(10)  DEFAULT 'A' || LPAD(assignment_seq.NEXTVAL, 9, '0') PRIMARY KEY NOT NULL,
    category_id    VARCHAR(10)  NOT NULL REFERENCES grading_category(category_id) ON DELETE CASCADE,
    title          VARCHAR(40)  NOT NULL,
    max_points     NUMBER(6,2)  NOT NULL CHECK (max_points > 0),
    due_date       DATE
);



----- Score Table -----
CREATE TABLE score (
    score_id       VARCHAR2(10)  DEFAULT 'S' || LPAD(score_seq.NEXTVAL, 9, '0') PRIMARY KEY,
    enrollment_id  VARCHAR2(10)  NOT NULL REFERENCES enrollment(enrollment_id)  ON DELETE CASCADE,
    assignment_id  VARCHAR2(10)  NOT NULL REFERENCES assignment(assignment_id)  ON DELETE CASCADE,
    points_earned  NUMBER(6,2)   NOT NULL CHECK (points_earned >= 0),
    excused        NUMBER(1)     DEFAULT 0 NOT NULL CHECK (excused IN (0,1)),
    UNIQUE (enrollment_id, assignment_id)
);
 


--=========================================--
----------- Inserting Sample Data -----------
--=========================================--

----- Students -----
INSERT INTO student VALUES ('2026ABCDEF', 'Lebron', 'James', 'ljames');
INSERT INTO student VALUES ('2029ZYXWVU', 'Spongebob', 'Squarepants', 'ssquarepants');
INSERT INTO student VALUES ('2028HDJILA', 'Paul', 'Atreides', 'patreides');
INSERT INTO student VALUES ('2025LKCAYH', 'Taylor', 'Swift', 'tswift');



----- Courses -----
INSERT INTO course (department, course_number, course_name, semester, year)
VALUES ('CSC', '4480', 'Database Systems', 'Spring', '2026');

INSERT INTO course (department, course_number, course_name, semester, year)
VALUES ('HIS', '2200', 'History of Ancient Rome', 'Fall', '2025');

INSERT INTO course (department, course_number, course_name, semester, year)
VALUES ('MAT', '3150', 'Calculus III', 'Spring', '2026');
    


----- Enrollments -----
-- CSC 4480 (C000000001)
INSERT INTO enrollment (student_id, course_id) VALUES ('2026ABCDEF', 'C000000001');
INSERT INTO enrollment (student_id, course_id) VALUES ('2029ZYXWVU', 'C000000001');
INSERT INTO enrollment (student_id, course_id) VALUES ('2028HDJILA', 'C000000001');
INSERT INTO enrollment (student_id, course_id) VALUES ('2025LKCAYH', 'C000000001');

-- HIS 2200 (C000000002)
INSERT INTO enrollment (student_id, course_id) VALUES ('2026ABCDEF', 'C000000002');
INSERT INTO enrollment (student_id, course_id) VALUES ('2029ZYXWVU', 'C000000002');
INSERT INTO enrollment (student_id, course_id) VALUES ('2028HDJILA', 'C000000002');
INSERT INTO enrollment (student_id, course_id) VALUES ('2025LKCAYH', 'C000000002');

-- MAT 3150 (C000000003)
INSERT INTO enrollment (student_id, course_id) VALUES ('2026ABCDEF', 'C000000003');
INSERT INTO enrollment (student_id, course_id) VALUES ('2029ZYXWVU', 'C000000003');
INSERT INTO enrollment (student_id, course_id) VALUES ('2028HDJILA', 'C000000003');
INSERT INTO enrollment (student_id, course_id) VALUES ('2025LKCAYH', 'C000000003');
    


----- Grading Catergories -----    

-- CSC 4480
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000001', 'Participation', 10);
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000001', 'Homework', 20);
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000001', 'Tests', 50);
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000001', 'Projects', 20);

-- HIS 2200
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000002', 'Participation', 20);
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000002', 'Essays', 30);
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000002', 'Exams', 50);

-- MAT 3150
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000003', 'Homework', 10);
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000003', 'Quizzes', 40);
INSERT INTO grading_category (course_id, category_label, weight_pct) VALUES ('C000000003', 'Final Exam', 50);



----- Assignments -----

-- CSC 4480
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000001', 'Week 1 Participation', 10, DATE '2026-02-01');
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000002', 'Homework 1: Intro to SQL', 50, DATE '2026-02-10');
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000003', 'Midterm Exam', 100, DATE '2026-03-10');
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000004', 'Final Project', 100, DATE '2026-04-30');

-- HIS 2200
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000005', 'Fall Participation', 20, DATE '2025-12-01');
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000006', 'Essay 1', 50, DATE '2025-11-10');
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000007', 'Final Exam', 100, DATE '2025-12-10');

-- MAT 3150
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000008', 'Homework 1: Derivatives', 25, DATE '2026-02-04');
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000009', 'Quiz 1', 50, DATE '2026-02-18');
INSERT INTO assignment (category_id, title, max_points, due_date) VALUES ('GC00000010', 'Exam 1', 100, DATE '2026-02-28');



----- Scores -----

--- CSC 4480 ---
-- Lebron (E000000001)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000001','A000000001', 10);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000001','A000000002', 48);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000001','A000000003', 97);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000001','A000000004', 96);

-- Spongebob (E000000002)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000002','A000000001', 8);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000002','A000000002', 37);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000002','A000000003', 81);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000002','A000000004', 76);

-- Paul (E000000003)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000003','A000000001', 9);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000003','A000000002', 44);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000003','A000000003', 88);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000003','A000000004', 89);

-- Taylor (E000000004)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000004','A000000001', 10);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000004','A000000002', 47);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000004','A000000003', 92);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000004','A000000004', 94);


--- HIS 2200 ---
-- Lebron (E000000005)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000005','A000000005', 18);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000005','A000000006', 46);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000005','A000000007', 88);

-- Spongebob (E000000006)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000006','A000000005', 14);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000006','A000000006', 30);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000006','A000000007', 68);

-- Paul (E000000007)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000007','A000000005', 17);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000007','A000000006', 42);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000007','A000000007', 82);

-- Taylor (E000000008)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000008','A000000005', 20);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000008','A000000006', 49);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000008','A000000007', 96);


--- MAT 3150 ---
-- Lebron (E000000009)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000009','A000000008', 23);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000009','A000000009', 45);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000009','A000000010', 91);

-- Spongebob (E000000010)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000010','A000000008', 14);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000010','A000000009', 30);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000010','A000000010', 55);

-- Paul (E000000011)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000011','A000000008', 21);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000011','A000000009', 40);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000011','A000000010', 80);

-- Taylor (E000000012)
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000012','A000000008', 24);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000012','A000000009', 47);
INSERT INTO score (enrollment_id, assignment_id, points_earned) VALUES ('E000000012','A000000010', 95);

COMMIT;



select * from student;
select * from course;
select * from enrollment;
select * from grading_category;
select * from assignment;
select * from score;

-- ============================================================
--  SECTION 5: QUERIES
-- ============================================================

-- ------------------------------------------------------------
--  Q1: List all students enrolled in a given course
-- ------------------------------------------------------------
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name  AS student_name,
    s.email
FROM enrollment e
JOIN student s ON s.student_id = e.student_id
JOIN course  c ON c.course_id  = e.course_id
WHERE c.course_number = '4480'
  AND c.semester      = 'Spring'
  AND c.year          = '2026'
ORDER BY s.last_name;

-- ------------------------------------------------------------
--  Q2: All assignments for a course with category info
-- ------------------------------------------------------------
SELECT
    gc.category_label  AS category,
    gc.weight_pct      AS weight,
    a.title            AS assignment,
    a.max_points,
    a.due_date
FROM assignment       a
JOIN grading_category gc ON gc.category_id = a.category_id
JOIN course           c  ON c.course_id    = gc.course_id
WHERE c.course_number = '4480'
ORDER BY gc.category_label, a.due_date;

-- ------------------------------------------------------------
--  Q3: Final grade per student in a course
--  Oracle supports CTEs (WITH clause) in SELECT statements
-- ------------------------------------------------------------
WITH category_scores AS (
    SELECT
        e.enrollment_id,
        s.first_name || ' ' || s.last_name  AS student_name,
        gc.category_id,
        gc.category_label,
        gc.weight_pct,
        NVL(SUM(CASE WHEN sc.excused = 0 THEN sc.points_earned ELSE 0 END), 0) AS total_earned,
        NVL(SUM(CASE WHEN sc.excused = 0 THEN a.max_points     ELSE 0 END), 0) AS total_max
    FROM enrollment       e
    JOIN student          s   ON s.student_id    = e.student_id
    JOIN grading_category gc  ON gc.course_id    = e.course_id
    JOIN assignment       a   ON a.category_id   = gc.category_id
    LEFT JOIN score       sc  ON sc.enrollment_id = e.enrollment_id
                             AND sc.assignment_id  = a.assignment_id
    WHERE e.course_id = 'C000000001'
    GROUP BY e.enrollment_id, s.first_name, s.last_name,
             gc.category_id, gc.category_label, gc.weight_pct
),
weighted AS (
    SELECT
        enrollment_id,
        student_name,
        CASE WHEN total_max > 0
             THEN ROUND((total_earned / total_max) * weight_pct, 2)
             ELSE 0
        END AS weighted_contribution
    FROM category_scores
)
SELECT
    student_name,
    ROUND(SUM(weighted_contribution), 2) AS final_grade,
    CASE
        WHEN SUM(weighted_contribution) >= 90 THEN 'A'
        WHEN SUM(weighted_contribution) >= 80 THEN 'B'
        WHEN SUM(weighted_contribution) >= 70 THEN 'C'
        WHEN SUM(weighted_contribution) >= 60 THEN 'D'
        ELSE 'F'
    END AS letter_grade
FROM weighted
GROUP BY enrollment_id, student_name
ORDER BY final_grade DESC;

-- ------------------------------------------------------------
--  Q4: Update grade_cached for all students
--  Oracle UPDATE uses a subquery with MERGE or correlated UPDATE
-- ------------------------------------------------------------
UPDATE enrollment e
SET e.grade_cached = (
    SELECT ROUND(SUM(
        CASE WHEN total_max > 0
             THEN (total_earned / total_max) * weight_pct
             ELSE 0
        END
    ), 2)
    FROM (
        SELECT
            e2.enrollment_id,
            gc.weight_pct,
            NVL(SUM(CASE WHEN sc.excused = 0 THEN sc.points_earned ELSE 0 END), 0) AS total_earned,
            NVL(SUM(CASE WHEN sc.excused = 0 THEN a.max_points     ELSE 0 END), 0) AS total_max
        FROM enrollment       e2
        JOIN grading_category gc ON gc.course_id    = e2.course_id
        JOIN assignment       a  ON a.category_id   = gc.category_id
        LEFT JOIN score       sc ON sc.enrollment_id = e2.enrollment_id
                                AND sc.assignment_id  = a.assignment_id
        GROUP BY e2.enrollment_id, gc.category_id, gc.weight_pct
    ) cs
    WHERE cs.enrollment_id = e.enrollment_id
);

COMMIT;