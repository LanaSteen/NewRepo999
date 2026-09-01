
CREATE DATABASE UNIVERSITY
go

USE UNIVERSITY
GO

------------------------------------------------------------------
-- 1. DDL: ცხრილების შექმნა და კავშირები (RELATIONSHIPS)
------------------------------------------------------------------

-- 1.1. FACULTY (ფაკულტეტები)
CREATE TABLE FACULTY
(
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE
);

-- 1.2. STUDENTS (სტუდენტები) - One-to-Many FACULTY-სთან
CREATE TABLE STUDENTS
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Age INT NOT NULL CHECK(Age BETWEEN 18 AND 100),
    GPA DECIMAL(3,2) CHECK(GPA BETWEEN 0.00 AND 4.00),
    PhoneNumber VARCHAR(20) NULL,
    IsActive BIT DEFAULT(1),
    RegisteredAt DATETIME2 DEFAULT(SYSDATETIME()),
    DepartmentID INT NULL,
    CONSTRAINT FK_STUDENTS_FACULTY FOREIGN KEY (DepartmentID) REFERENCES FACULTY(DepartmentID)
);

-- 1.3. STUDENT_DETAILS (სტუდენტის პროფილი) - One-to-One (1:1) STUDENTS-თან
-- (StudentID არის Primary Key და ამავდროულად Foreign Key)
CREATE TABLE STUDENT_DETAILS
(
    StudentID INT PRIMARY KEY,
    Address NVARCHAR(200) NULL,
    PassportNumber VARCHAR(50) NOT NULL UNIQUE,
    DateOfBirth DATE NOT NULL,
    CONSTRAINT FK_STUDENTDETAILS_STUDENTS FOREIGN KEY (StudentID) REFERENCES STUDENTS(ID) 
    ON DELETE CASCADE
);
















-- 1.4. INSTRUCTORS (ლექტორები)
CREATE TABLE INSTRUCTORS
(
    InstructorID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE
);

-- 1.5. COURSES (კურსები) - One-to-Many (1:M) INSTRUCTORS-თან
CREATE TABLE COURSES
(
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseTitle NVARCHAR(100) NOT NULL,
    Credits INT NOT NULL CHECK(Credits BETWEEN 1 AND 6),
    InstructorID INT NULL,
    CONSTRAINT FK_COURSES_INSTRUCTORS FOREIGN KEY (InstructorID) REFERENCES INSTRUCTORS(InstructorID)
);

-- 1.6. ENROLLMENTS (კურსზე რეგისტრაცია) - Many-to-Many (M:N) STUDENTS <-> COURSES
CREATE TABLE ENROLLMENTS
(
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATETIME2 DEFAULT(SYSDATETIME()),
    Grade DECIMAL(3,2) CHECK(Grade BETWEEN 0.00 AND 4.00),
    CONSTRAINT FK_ENROLLMENTS_STUDENTS FOREIGN KEY (StudentID) REFERENCES STUDENTS(ID) ON DELETE CASCADE,
    CONSTRAINT FK_ENROLLMENTS_COURSES FOREIGN KEY (CourseID) REFERENCES COURSES(CourseID),
    CONSTRAINT UQ_STUDENT_COURSE UNIQUE (StudentID, CourseID) -- ხელს უშლის განმეორებით რეგისტრაციას
);
GO

------------------------------------------------------------------
-- 2. DML: სატესტო მონაცემების შევსება
------------------------------------------------------------------

-- ფაკულტეტები
INSERT INTO FACULTY (DepartmentName) VALUES 
(N'Computer Science'),
(N'Mathematics'),
(N'Physics');

-- სტუდენტები
INSERT INTO STUDENTS (FirstName, LastName, Email, Age, GPA, PhoneNumber, DepartmentID) VALUES 
(N'გიორგი', N'გიორგაძე', 'giorgi@gmail.com', 20, 3.80, '+995599111111', 1),
(N'ნიკოლოზ', N'ბერიძე', 'nikoloz@gmail.com', 22, 2.90, '+995599222222', 1),
(N'ანა', N'კაპანაძე', 'ana@gmail.com', 21, 3.95, '+995599333333', 2),
(N'მარიამ', N'მშვიდობაძე', 'mariam@gmail.com', 19, 3.10, '+995599444444', 3),
(N'დავით', N'ქვარიანი', 'david@gmail.com', 23, 2.50, '+995599555555', NULL); -- ჯერ არ აქვს ფაკულტეტი

-- სტუდენტის პროფილები (1:1)
INSERT INTO STUDENT_DETAILS (StudentID, Address, PassportNumber, DateOfBirth) VALUES 
(1, N'თბილისი, რუსთაველის გამზ. 10', 'AB123456', '2004-05-15'),
(2, N'ქუთაისი, ჭავჭავაძის ქ. 5', 'AB654321', '2002-11-20'),
(3, N'ბათუმი, გორგილაძის ქ. 12', 'AC987654', '2003-01-10'),
(4, N'თბილისი, ვაჟა-ფშაველას გამზ. 45', 'AD456789', '2005-08-01'),
(5, N'რუსთავი, მეგობრობის გამზ. 2', 'AE112233', '2001-03-25');

-- ლექტორები
INSERT INTO INSTRUCTORS (FirstName, LastName, Email) VALUES 
(N'გიგა', N'ქორქია', 'giga.korkia@university.edu'),
(N'თამარ', N'ნაცვლიშვილი', 'tamar.nats@university.edu'),
(N'ირაკლი', N'დოლიძე', 'irakli.dolidze@university.edu');

-- კურსები (1:M)
INSERT INTO COURSES (CourseTitle, Credits, InstructorID) VALUES 
(N'C# / .NET Architecture', 6, 1),
(N'Database Systems & SQL', 5, 1),
(N'Linear Algebra', 4, 2),
(N'Quantum Mechanics', 5, 3);

-- რეგისტრაციები (M:N)
INSERT INTO ENROLLMENTS (StudentID, CourseID, Grade) VALUES 
(1, 1, 3.90), -- გიორგი -> C#
(1, 2, 4.00), -- გიორგი -> SQL
(2, 1, 2.70), -- ნიკოლოზ -> C#
(2, 2, 3.10), -- ნიკოლოზ -> SQL
(3, 3, 4.00), -- ანა -> Linear Algebra
(3, 1, 3.85), -- ანა -> C#
(4, 4, 3.20), -- მარიამ -> Quantum Mechanics
(4, 3, 3.00); -- მარიამ -> Linear Algebra
-- (სტუდენტი 5 არ არის დარეგისტრირებული არცერთ კურსზე)
GO





--1.	გამოიტანეთ ყველა სტუდენტის FirstName, Email, და მათი ფაკულტეტის დასახელება (DepartmentName).
SELECT s.FirstName, s.Email,
       f.DepartmentName
from STUDENTS s
JOIN FACULTY f on s.DepartmentID = f.DepartmentID

--2.	გამოიტანეთ კურსების სია (CourseTitle, Credits) მათ პასუხისმგებელ ლექტორებთან ერთად (FirstName, LastName).

SELECT c.CourseTitle, c.Credits,
       i.FirstName, i.LastName
from COURSES c
Join INSTRUCTORS i on c.InstructorID = i.InstructorID

--3.	გამოიტანეთ იმ სტუდენტების სია (FirstName, PassportNumber), რომელთა GPA აღემატება 3.00-ს.

   SELECT s.FirstName, ps.PassportNumber, s.GPA
   FROM STUDENTS s
   join STUDENT_DETAILS ps on s.ID = ps.StudentID
   WHERE S.GPA > 3.00
   

 --4.	გამოიტანეთ სტუდენტის სახელი (FirstName), კურსის დასახელება (CourseTitle) და მიღებული ქულა (Grade) ყველა რეგისტრაციისთვის.
 /*
 SELECT s.FirstName, c.CourseTitle, e.Grade
 FROM ENROLLMENTS e
 join STUDENTS s on s.ID = e.StudentID
 join COURSES c on e.CourseID = c.CourseID 
 */


 SELECT s.FirstName, c.CourseTitle, e.Grade
 FROM STUDENTS s
 join ENROLLMENTS e on s.ID = e.StudentID
 join COURSES c on e.CourseID = c.CourseID


 --5.	იპოვეთ თითოეული სტუდენტის საშუალო ქულა (AVG(Grade)), რომელიც მიიღო კურსებში. გამოიტანეთ სტუდენტის სახელი და საშუალო ქულა.

 SELECT s.FirstName + ' ' + s.LastName as FullName , AVG(e.Grade) as AVG_GRADE
 from ENROLLMENTS e
 join STUDENTS s  on e.StudentID = s.ID
 GROUP BY s.FirstName, s.ID, s.LastName


 --6.	დაითვალეთ, რამდენი სტუდენტია დარეგისტრირებული თითოეულ კურსზე (CourseTitle, StudentCount).


 SELECT c.CourseTitle, count(e.StudentID) as StudentCount
 from COURSES c
 LEFT JOIN ENROLLMENTS e on c.CourseID = e.CourseID
 GROUP BY c.CourseTitle
 

 --7.	გამოიტანეთ იმ სტუდენტების სია, რომლებსაც ჯერ არცერთ კურსზე არ გაუვლიათ რეგისტრაცია (LEFT JOIN / IS NULL).

 SELECT s.FirstName
 from STUDENTS s
 left join ENROLLMENTS e on s.ID = e.StudentID
 where StudentID is null


 --8.	იპოვეთ ყველაზე მაღალი GPA-ს მქონე სტუდენტის მიერ არჩეული კურსების დასახელებები.


 SELECT s.FirstName, c.CourseTitle, e.Grade
 FROM STUDENTS s
 join ENROLLMENTS e on s.ID = e.StudentID
 join COURSES c on e.CourseID = c.CourseID
 where s.GPA = (Select Max(GPA) from STUDENTS)

 --Select Max(GPA) from STUDENTS



 DECLARE @GPA DECIMAL(3,2)


 SELECT @GPA = GPA FROM STUDENTS WHERE ID =1

 IF @GPA >4.00
 BEGIN 
    PRINT N'წარმატებული'
 END
 ELSE IF @GPA > 3.70
   BEGIN
      PRINT N'საშუალო'
   END
 ELSE
  BEGIN
    PRINT N'არაა წარმაყებული'
  END




  SELECT gpa 
       GPA,
       CASE 
          WHEN GPA >3.50 THEN N'საშუალო'
          ELSE N'არაა წარმატებული'
          END  AS  RESULT
   
  FROM STUDENTS  S
  WHERE ID = 1




 -- WHILE

DECLARE @i int = 1

 while @i <=10
 begin 

  if @i = 5 
    begin 
      set @i = @i+1
      continue
     
    end

  if @i = 7
    break

  print @i
  set @i = @i+1
 end 


 

 CREATE FUNCTION Fn_GetStudentGPA2(@id int)
 returns decimal(3,2)
 as
 begin

    declare @StGpa decimal(3,2) 
    
     set @StGpa  = (select gpa from STUDENTS where ID = @id)

    return @StGpa

 end



select *, dbo.Fn_GetStudentGPA(ID) as fnresult from STUDENTS






CREATE FUNCTION Fn_GetAllStAVGGPA()
returns decimal(3,2)
begin 
   return (select AVG(gpa) from STUDENTS)
end

select dbo.Fn_GetAllStAVGGPA()  allStGpa

--5  10
-- procedure
CREATE PROCEDURE sp_GetTopSt
    @topSTAmount int
    as
    begin
        select Top(@topSTAmount) ID, FirstName, GPA
        from STUDENTS
        order by gpa desc

    end


exec dbo.sp_GetTopSt @topSTAmount = 5





CREATE PROCEDURE sp_UpdateGpaOnSingleStudent
    @StudentId INT,
    @NewGpa Decimal(3,2)
    as
    begin

       update STUDENTS
       set gpa = @NewGpa
       where id = @StudentId
    end


exec dbo.sp_UpdateGpaOnSingleStudent @StudentId = 1, @NewGpa = 3.99



select * from STUDENTS