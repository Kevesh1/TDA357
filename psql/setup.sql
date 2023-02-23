--TABLES

CREATE TABLE Departments(
    name TEXT PRIMARY KEY,
    abbreviation TEXT UNIQUE
);

CREATE TABLE Programs(
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL
);

CREATE TABLE DepartmentPrograms(
    department TEXT REFERENCES Departments,
    program TEXT REFERENCES Programs,
    PRIMARY KEY(department,program)
);

CREATE TABLE Students(
    idnr VARCHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL REFERENCES Programs,
    CONSTRAINT studentProgram UNIQUE (idnr, program)
);

CREATE TABLE Branches(
    name TEXT,
    program TEXT REFERENCES Programs,
    PRIMARY KEY(name, program)
);

CREATE TABLE StudentBranches(
    student TEXT PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY(branch, program) REFERENCES Branches(name,program),
    FOREIGN KEY(student, program) REFERENCES Students(idnr,program)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK(credits > 0),
    department TEXT NOT NULL
);


CREATE TABLE RecommendedBranch(
    course CHAR(6) REFERENCES Courses,
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE MandatoryBranch(
    course CHAR(6) REFERENCES Courses,
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE MandatoryProgram(
    course CHAR(6) REFERENCES Courses,
    program TEXT,
    PRIMARY KEY(course,program)
);

CREATE TABLE Prerequisities(
    course CHAR(6) REFERENCES Courses,
    passed CHAR(6) REFERENCES Courses
);

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course CHAR(6) REFERENCES Courses,
    classification TEXT REFERENCES Classifications,
    PRIMARY KEY(course, classification)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY REFERENCES Courses,
    capacity INT NOT NULL CHECK(capacity > 0)
);

CREATE TABLE Registered(
    student VARCHAR(10) REFERENCES Students,
    course CHAR(6) REFERENCES Courses,
    PRIMARY KEY(student,course)
);

CREATE TABLE Taken(
    student VARCHAR(10) REFERENCES Students,
    course CHAR(6) REFERENCES Courses,
    PRIMARY KEY(student,course),
    grade CHAR(1) NOT NULL CHECK(grade = 'U' or grade = '3' or grade = '4' or grade = '5') 
);

CREATE TABLE WaitingList(
    student VARCHAR(10) REFERENCES Students,
    course VARCHAR(6) REFERENCES LimitedCourses,
    position TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    PRIMARY KEY(student, course),
    UNIQUE(course, position)
);

--INSERTS

INSERT INTO Programs VALUES ('Prog1','P1');
INSERT INTO Programs VALUES ('Prog2','P2');

INSERT INTO Departments VALUES ('Computer Science','CS');
INSERT INTO Departments VALUES ('Compuer Science and Engineering program','CSEP');

INSERT INTO DepartmentPrograms VALUES ('Computer Science','Prog1');
INSERT INTO DepartmentPrograms VALUES ('Compuer Science and Engineering program','Prog2');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');

INSERT INTO Prerequisities VALUES ('CCC111','CCC555');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);
--Make CCC555 to limited course for testing
INSERT INTO LimitedCourses VALUES ('CCC555',5);


INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');
--INSERT INTO StudentBranches VALUES ('1111111111','B1','Prog2');


INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
--Register student to CCC555 for testing
INSERT INTO Registered VALUES ('5555555555','CCC555');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

--Removed the position attribute, using TIMESTAMP instead
INSERT INTO WaitingList VALUES('3333333333','CCC222');
INSERT INTO WaitingList VALUES('3333333333','CCC333');
INSERT INTO WaitingList VALUES('2222222222','CCC333');


--VIEWS

CREATE VIEW BasicInformation AS 
SELECT DISTINCT Students.idnr, Students.name AS name, Students.login, 
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



