# CSC4480FinalProject

# Users can add classes, students, assignments, grades, grading catergories, and enrollments! To add any of the listed items, check the code for the examples and change it based on you desires.
# You can add using the INSERT command. For example, do add a student named "Alice Inwonderland", I can type the line:
# INSERT INTO student VALUES ('grad year+4 random digits', 'Alice', 'Inwonderland', 'ainwonderland');
# *Make sure to take note of the sequenced values (i.e. the course ids, enrollment ids, etc.)

# You can also update values, such as grades or assignment due dates, by using the UPDATE command. For example, if a student scored a 95 but a 59 was inputted, you can run:
# UPDATE score SET points_earned = 95 WHERE enrollment_id = 'E000000002' AND assignment_id = 'A000000003';
# *Note the enrollment_id is that for the specific student in a specfic course and the assignment_id is the id for the assignment in said course
