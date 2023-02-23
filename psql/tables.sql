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



