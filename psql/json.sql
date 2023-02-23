
SELECT idnr, COALESCE(SUM(PassedCourses.credits),0) as totalCredits 
FROM Students 
LEFT JOIN PassedCourses
ON Students.idnr = PassedCourses.student
GROUP BY Students.idnr

SELECT idnr, COALESCE(SUM(FinishedCourses.credits),0) as totalCredits 
FROM Students 
LEFT JOIN FinishedCourses
ON Students.idnr = FinishedCourses.student
GROUP BY Students.idnr