CREATE VIEW BasicInformation AS 
SELECT DISTINCT Students.idnr AS idnr, Students.name AS name, Students.login, 
Students.program, StudentBranches.branch AS branch
FROM Students
LEFT JOIN StudentBranches
ON Students.idnr = StudentBranches.student
ORDER BY Students.idnr;

CREATE VIEW FinishedCourses AS
SELECT Students.idnr AS student, Courses.code AS course, Taken.grade, 
Courses.credits 
FROM Students
JOIN Taken
ON Students.idnr = Taken.student
JOIN Courses 
ON Taken.course = Courses.code
ORDER BY Students.idnr;

CREATE VIEW PassedCourses AS
SELECT student, course, credits FROM FinishedCourses
WHERE grade != 'U';

CREATE VIEW Registrations AS
SELECT Students.idnr as student, Registered.course as course, 'registered' as status
FROM Students
JOIN Registered
ON Students.idnr = Registered.student
UNION
SELECT Students.idnr as student, WaitingList.course as course, 'waiting' as status
FROM Students
JOIN WaitingList
ON Students.idnr = WaitingList.student
ORDER BY student;

 
CREATE VIEW UnreadMandatory AS
    SELECT Students.idnr AS student, Courses.code AS course 
    FROM Students
    NATURAL JOIN MandatoryProgram
    JOIN Courses
    ON Courses.code = MandatoryProgram.course
UNION
    SELECT Students.idnr AS student, Courses.code AS course 
    FROM Students
    JOIN StudentBranches
    ON Students.idnr = StudentBranches.student
    JOIN MandatoryBranch
    ON MandatoryBranch.branch = StudentBranches.branch 
    AND MandatoryBranch.program = StudentBranches.program
    JOIN Courses
    ON Courses.code = MandatoryBranch.course
EXCEPT 
    SELECT student, course FROM PassedCourses;

    
CREATE VIEW PathToGraduation AS
WITH Name AS
(SELECT Students.idnr as student FROM Students),
Credits AS 
(SELECT idnr, COALESCE(SUM(PassedCourses.credits),0) as totalCredits 
FROM Students 
LEFT JOIN PassedCourses
ON Students.idnr = PassedCourses.student
GROUP BY Students.idnr),
MandatoryMissing AS
(SELECT Name.student, COUNT(UnreadMandatory.student) AS mandatoryLeft FROM Name
LEFT JOIN UnreadMandatory
ON Name.student = UnreadMandatory.student
GROUP BY Name.student),
MathCredits AS
(SELECT idnr, COALESCE(SUM(CASE WHEN Classified.classification = 'math' 
THEN PassedCourses.credits ELSE 0 END),0) AS mathCredits
FROM Students
LEFT JOIN PassedCourses
ON Students.idnr = PassedCourses.student
LEFT JOIN Classified
ON Classified.course = PassedCourses.course 
GROUP BY Students.idnr
),
ResearchCredits AS
(SELECT idnr, COALESCE(SUM(CASE WHEN Classified.classification ='research' 
THEN PassedCourses.credits ELSE 0 END),0) AS researchCredits
FROM Students
LEFT JOIN PassedCourses
ON Students.idnr = PassedCourses.student
LEFT JOIN Classified
ON Classified.course = PassedCourses.course
GROUP BY Students.idnr
),
SeminarCourses AS
(SELECT Name.student , COUNT(CASE WHEN Classified.classification = 'seminar' 
THEN PassedCourses.student END) AS seminarCourses 
FROM Name 
LEFT JOIN PassedCourses
ON Name.student = PassedCourses.student
LEFT JOIN Classified
ON Classified.course = PassedCourses.course
GROUP BY Name.student
),
RecommendedCoursesTaken AS
(SELECT Students.idnr AS student, COALESCE(SUM(PassedCourses.credits),0) AS credits FROM Students
JOIN StudentBranches
ON Students.idnr = StudentBranches.student
JOIN RecommendedBranch
ON StudentBranches.branch = RecommendedBranch.branch 
AND StudentBranches.program = RecommendedBranch.program
JOIN PassedCourses
ON PassedCourses.course = RecommendedBranch.course AND PassedCourses.student = StudentBranches.student
--WHERE Students.idnr IN (Select Student FROM PassedCourses)
GROUP BY Students.idnr
ORDER BY Students.idnr
)
SELECT Name.student, Credits.totalCredits, MandatoryMissing.mandatoryLeft AS mandatoryLeft, 
MathCredits.mathCredits, ResearchCredits.researchCredits,
SeminarCourses.seminarCourses AS seminarCourses, 
CASE 
    WHEN seminarCourses > 0
        AND MandatoryMissing.mandatoryLeft = 0
        AND MathCredits.mathCredits >= 20 
        AND ResearchCredits.researchCredits >= 10
        AND RecommendedCoursesTaken.credits >= 10 THEN TRUE
    ELSE FALSE
END AS qualified
FROM Name 
LEFT JOIN Credits
ON Name.student = Credits.idnr
LEFT JOIN MandatoryMissing
ON Name.student = MandatoryMissing.student
LEFT JOIN MathCredits
ON Name.student = MathCredits.idnr
LEFT JOIN ResearchCredits
ON Name.student = ResearchCredits.idnr
LEFT JOIN SeminarCourses
ON Name.student = SeminarCourses.student
LEFT JOIN RecommendedCoursesTaken
ON Name.student = RecommendedCoursesTaken.student
GROUP BY Name.student, Credits.totalCredits, MandatoryMissing.mandatoryLeft,MathCredits.mathCredits,
ResearchCredits.researchCredits, SeminarCourses.seminarCourses,RecommendedCoursesTaken.credits
ORDER BY Name.student;

CREATE VIEW CourseQueuePosition AS
SELECT student, course,row_number()over(partition by course) AS position FROM WaitingList
ORDER BY course, position;


