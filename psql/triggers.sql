
CREATE VIEW CourseQueuePositions AS
SELECT course, student,row_number()over(partition by course) AS place FROM WaitingList
ORDER BY course, position;

CREATE FUNCTION register() RETURNS trigger AS $$
BEGIN
    --Check if student already is registered
    IF EXISTS (SELECT * FROM Registered WHERE student = NEW.Student AND course = NEW.course) THEN
        RAISE EXCEPTION 'Student % is already registered for %', NEW.student, NEW.course;
        RETURN NULL;
    --Check if student already is on waiting list
    ELSIF EXISTS (SELECT * FROM WaitingList WHERE student = NEW.Student AND course = NEW.course) THEN
        RAISE EXCEPTION 'Student % is already on the waiting list for %', NEW.student, NEW.course;
        RETURN NULL;
    END IF;

    --Check if student exist
    IF NOT EXISTS (SELECT * FROM Students WHERE idnr = NEW.student) THEN
        RAISE EXCEPTION 'Can not register Student: % because they do not exist', NEW.student;
        RETURN NULL;
    END IF;

    --Check if course has prerequisities
    IF EXISTS (SELECT * FROM Prerequisities WHERE course = NEW.course) THEN
        --Check if prerequisites courses are read
        IF NOT (SELECT course FROM PassedCourses WHERE student = NEW.student) IN (SELECT passed FROM Prerequisities WHERE course = NEW.course) THEN 
            RAISE EXCEPTION 'Student % not eligible to read the course: %', NEW.student ,NEW.course;
            RETURN NULL;
        END IF;
    END IF;
    --Check if course is limited
    IF(SELECT code FROM Courses WHERE code = NEW.course) IN (SELECT code FROM LimitedCourses WHERE code = NEW.course) THEN 
        --If course is full
        IF (SELECT COUNT(*) FROM Registered WHERE course = NEW.course) >= (SELECT capacity FROM LimitedCourses WHERE code = NEW.course) THEN
            --Put student in waiting list
            INSERT INTO WaitingList VALUES (NEW.student, NEW.course, NOW());
            RAISE NOTICE 'Course % is full, % is put on the waiting list', NEW.course, NEW.student;
            RETURN NULL;
        END IF;
        --course is not full
    END IF;
    --Always register the user unless they are set on the waiting list
    INSERT INTO Registered VALUES (NEW.student, NEW.course);
    RAISE NOTICE 'Student % registered for course %', NEW.student, NEW.course;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION unregister() RETURNS trigger AS $$ 
BEGIN
    RAISE NOTICE 'Missing ELSE';
    --If student is registered
    IF EXISTS(SELECT * FROM Registered WHERE student = OLD.student AND course = OLD.course) THEN
        DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
        RAISE NOTICE 'Student % was removed from the course %', OLD.student, OLD.course;
        --Check if the deleted student was from a limited course
        IF (SELECT course FROM Registrations WHERE course = OLD.course LIMIT 1) IN (SELECT code FROM LimitedCourses WHERE code = OLD.course) THEN
            --Check if course is full
            IF (SELECT COUNT(*) FROM Registered WHERE course = OLD.course) >= (SELECT capacity FROM LimitedCourses WHERE code = OLD.course) THEN
                RAISE NOTICE 'Course is still full';
                RETURN NULL;
            ELSE
                --If their are available spots, the first student in the waiting list is registered to the course if their are any
                IF EXISTS (SELECT * FROM CourseQueuePositions WHERE course = OLD.course LIMIT 1) THEN
                    INSERT INTO Registered SELECT student, OLD.course 
                    FROM CourseQueuePositions 
                    WHERE course = OLD.course LIMIT 1;
                    DELETE FROM WaitingList WHERE student = (SELECT student FROM CourseQueuePositions WHERE course = OLD.course Limit 1) AND course = OLD.course;
                    RAISE NOTICE 'The first student in the waiting list is now registered';
                    RETURN NULL;
                END IF;
            END IF;
        END IF;   
        RETURN NULL;
    --If student is on waiting list
    ELSIF EXISTS(SELECT * FROM WaitingList WHERE student = OLD.student AND course = OLD.course) THEN
        DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
        RAISE NOTICE 'Student % was removed from the waiting list %', OLD.student, OLD.course;
        RETURN NULL;
    --ELSE 
    --    RAISE EXCEPTION 'Student % does not exist or is not registered for the course: %', OLD.student, OLD.course;
    --    RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER register_trigger
    INSTEAD OF INSERT ON Registrations
    FOR EACH ROW 
    EXECUTE FUNCTION register();

CREATE TRIGGER unregister_trigger
    INSTEAD OF DELETE ON Registrations
    FOR EACH ROW 
    EXECUTE FUNCTION unregister();