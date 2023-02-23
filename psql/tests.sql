
-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC444'); 

-- TEST #2: registered to a limited course;.
-- EXPECTED OUTCOME: Student put on waiting list
INSERT INTO Registrations VALUES ('6666666666', 'CCC333'); 

-- TEST #3: waiting for a limited course;.
-- EXPECTED OUTCOME: Student put on waiting list
INSERT INTO Registrations VALUES ('6666666666', 'CCC222'); 

-- TEST #4: removed from a waiting list (with additional students in it). 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC333';


-- TEST #5: Unregister from an unlimited course. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';


-- TEST #6: unregistered from a limited course without a waiting list; 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC555';


-- TEST #7: unregistered from a limited course with a waiting list, when the student is registered;. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';

INSERT INTO Students VALUES ('7777777777','N1','ls7','Prog1');
INSERT INTO WaitingList VALUES ('7777777777', 'CCC222');
-- TEST #8: unregistered from a limited course with a waiting list, when the student is in the middle of the waiting list;. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC222';


-- TEST #9: unregistered from an overfull course with a waiting list. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222';



