Drop Table Students;

Create table Students (
    student_id varchar(10) PRIMARY KEY NOT NULL, 
    first_name varchar(20) NOT NULL, 
    last_name varchar(20) NOT NULL , 
    email varchar(20) NOT NULL UNIQUE 
);

Insert into Students
Values('2026ABCDEF', 'Alexander', 'Edmonds', 'aedmonds');
Insert into Students
Values('2026ZYXWVU', 'Spongebob', 'Squarepants', 'ssquarepants');

select * from Students;

