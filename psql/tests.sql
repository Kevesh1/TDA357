
-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC444'); 

-- TEST #2: registered to a limited course;.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC555'); 

-- TEST #3: waiting for a limited course;.
-- EXPECTED OUTCOME: Pass
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


INSERT INTO Registered VALUES ('1111111111', 'CCC111');
-- TEST #10: register student to a course it is registered for
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('1111111111', 'CCC111');

-- TEST #11: register student to a course it is in the waiting list for
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('3333333333', 'CCC222');

-- TEST #12: register student that does not exist
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('333', 'CCC222');

INSERT INTO Prerequisities VALUES ('CCC111', 'CCC444')
-- TEST #13: register student to a course that is not eligeble to read it
-- EXPECTED OUTCOME: Fail
DELETE FROM Taken WHERE student = '4444444444' AND course = 'CCC111';
INSERT INTO Registrations VALUES ('4444444444', 'CCC111');

-- TEST #14: register student to a course they have already passed
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('4444444444', 'CCC111');

