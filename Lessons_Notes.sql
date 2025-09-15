#######BEGINNER##################
Select employee_id,first_name,salary
from parks_and_recreation.employee_salary
where salary >5000;

#-------------------LIKE STATEMENT--  
# % and _
SELECT *
FROM parks_and_recreation.employee_demographics
WHERE first_name LIKE 'a___';

SELECT *
FROM parks_and_recreation.employee_demographics
WHERE first_name LIKE '%a%';

SELECT *
FROM parks_and_recreation.employee_demographics
WHERE birth_date LIKE '_____07%' AND gender='male';

select * from employee_salary;

#--------------------Group by AND Order by

SELECT COUNT(AGE), MAX(age),MIN(age),  gender
FROM parks_and_recreation.employee_demographics
WHERE gender != 'male'
LIKE last_name = '%a__'
GROUP BY gender
;

#---------------------------------ORDER BY

SELECT* 
FROM employee_demographics
order by gender,age;


#-------------------------HAVING vs WHERE
SELECT gender, AVG(age)
FROM employee_demographics
GROUP BY gender
HAVING AVG(age)>=30;

SELECT occupation, AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING AVG(salary) > 7500;

#------------Limit and Aliasing-----------------------
SELECT *
FROM employee_demographics
ORDER BY age 
LIMIT 3;


#----Aliasing (more like renaming the table)
SELECT gender, AVG(age) AS avarage_age
FROM employee_demographics
GROUP BY gender
HAVING avarage_age>=30;




#----------------JOINS------------INNTER,OUTTER,SELF

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;


# INNTER returns raws that have the same values(the same in both tables)
SELECT *
FROM employee_demographics AS d
INNER JOIN employee_salary AS s
	ON d.employee_id = s.employee_id
;

#-------OUTTER JOINTS------left joint and right joint---
#---takes everything from the left and displays null if there are no values

SELECT *
FROM employee_demographics AS d
RIGHT JOIN employee_salary AS s
	ON d.employee_id = s.employee_id
;

#----------SELF JOIN
SELECT d.employee_id AS m1, s.employee_id AS M2, d.first_name AS f1, s.first_name AS f2
FROM employee_demographics AS d
JOIN employee_salary AS s
	ON d.employee_id+2 = s.employee_id
;


#----------JOING multiple tables, an only join tables that have coloums in common
#Make two tables one

SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id=sal.employee_id
INNER JOIN parks_departments AS pd
	ON sal.dept_id = pd.department_id
    ;
    
# UNIONS --------------allows to combine raws of data from different tables or the same
# UNION works as a DISTICT so if you dont use ALL it will distinct your data
#HLAKANYA DATA FROM DIFFERENT TABLES
 SELECT first_name, last_name
 FROM employee_demographics
 UNION ALL
 SELECT first_name, last_name
 FROM employee_salary;


SELECT first_name, last_name, 'OLD' AS Label
FROM employee_demographics
WHERE age>50
UNION ALL
SELECT first_name, last_name, 'Highly Paid' AS Label
FROM employee_salary
WHERE salary>70000
;




#--------------------------------------STRING FUNCTIONS------------------------------------

SELECT first_name , LENGTH(first_name) AS length
FROM employee_demographics;

SELECT first_name , UPPER(first_name) 
FROM employee_demographics;

SELECT first_name , LOWER(first_name) 
FROM employee_demographics;

#---------LEFT TRIM & RIGHT TRIM
SELECT TRIM(first_name) 
FROM employee_demographics;

SELECT RTRIM(first_name) 
FROM employee_demographics;

#---------SUBSTRING---------LEFT&RIGHT-------------------------
SELECT first_name , LEFT(first_name,3) AS SubStringLeft
FROM employee_demographics;

SELECT first_name , LEFT(first_name,3) AS SubStringLeft, RIGHT(first_name,3) AS SubStringRight
FROM employee_demographics;

SELECT SUBSTRING(first_name,2,2) #start from 2 and take 2
FROM employee_demographics;

SELECT SUBSTRING(birth_date,6,2) AS BirthMonth
FROM employee_demographics;


#-----------REPLACE---------------------------
SELECT first_name , REPLACE(first_name,'a','z') 
FROM employee_demographics;

#-----------LOCATE---------------------------
SELECT first_name , locate('L',first_name) 
FROM employee_demographics;

#----------CONCATINATE--------------------
SELECT first_name , last_name, CONCAT(first_name , ' ', last_name) AS Full_Name
FROM employee_demographics;


#------------------CASE STATEMENTS---------------------
SELECT first_name,last_name,age,
CASE 
	WHEN age<=30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age>51 THEN 'Retire'
END
AS Young_or_OLD
FROM employee_demographics;


#Compony is planning to increase and bonus 
#determine peoples end of year salary and how mucg bonus 
# <50000 = 5%
# >50000=7%
# finanve=10%

select* from employee_salary;

SELECT first_name,last_name,occupation,salary,
CASE
	WHEN salary>5000 THEN salary+(salary*0.05)
    WHEN salary<5000 THEN salary+(salary*0.07)
END 
AS BONUS1,
CASE
	WHEN dept_id = 6 THEN salary+(salary*0.10)
END 
AS BONUS
FROM employee_salary;

#--------------------SUBQUERIES--------------bsically a query inside a query-----------------
# WHERE and SELECT clause
# LOOKing for employees who work at parks and theres two different tables

SELECT *
FROM employee_demographics
WHERE employee_id IN (
						SELECT employee_id
                        FROM employee_salary
                        WHERE dept_id= 1
)
;

#LOOKING FOR AVERAGE SALARY OF ALL THE EMPLOYEES, THATS WHERE SELECT SELECT(YES DOUBLE SELECT) COMES in

SELECT first_name,salary ,(SELECT AVG(salary) 
							FROM employee_salary) AS Average_Sal
FROM employee_salary;


#-------------WINDOW FUNCTION-----------------------------------------------
#More like adding total of everything and every

SELECT dem.first_name, dem.last_name,gender,salary,SUM(salary) 
OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_total
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id=sal.employee_id

;

SELECT dem.employee_id,dem.first_name, dem.last_name, gender,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS dense_rank_num,
RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS rank_num
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

#===============================================================================================================
##################ADVANCE@@@@@@@@@@@@w


#+==================COMMON Table Expression  CTEs
#Building CTES you have to use them immediatelt after
#cant be reused is like a view once table

WITH CTE_example AS
(
	SELECT gender, AVG(salary) AS avg_sal,MIN(salary) AS min_sal,MAX(salary) AS max_sal,COUNT(salary) AS count_sal
    FROM employee_demographics dem
    JOIN employee_salary sal
		ON dem.employee_id=sal.employee_id
	GROUP BY gender
)
SELECT *
FROM CTE_example
;

WITH CTE_example AS
(
SELECT employee_id,gender,birth_date
FROM employee_demographics
WHERE birth_date> '1985-01-01'
),
CTE_example2 AS
(
SELECT employee_id,salary
FROM employee_salary
WHERE salary>50000
)
SELECT *
FROM CTE_example
JOIN CTE_example2
	ON CTE_example.employee_id=CTE_example.employee_id
;
#-----------------------------TEMP TABLES

CREATE TEMPORARY TABLE temp_table
(
	first_name VARCHAR (100),
    last_name VARCHAR (100),
    age INTEGER (2),
    fav_movie VARCHAR (500)
    
);

INSERT INTO temp_table
VALUES('Mav', 'Masemola', 26, 'Everything Everything');

SELECT *
FROM Temp_table;


# =======CREATING A TABLE BASED ON THE ALREADY EXISTING TABLE

CREATE TEMPORARY TABLE sal_over_70k
(
	SELECT *
    FROM employee_salary
    WHERE salary>= 70000
)
;
SELECT *
FROM sal_over_70k;

#========================== STORED PROCEDURE======a way to store code to reuse it over and over

CREATE PROCEDURE large_salaries()
SELECT * 
FROM employee_salary
WHERE SALARY >=70000
;

CALL large_salaries();

DELIMITER ||
CREATE PROCEDURE large_salaries3()
	SELECT * 
	FROM employee_salary
	WHERE SALARY >=70000;
	SELECT * 
	FROM employee_demographic
	WHERE gender = 'Female';
END ||

#returning back to normal delimeters
DELIMITER ;

#-------------------TRIGGER (AUTOMATION)AAND EVENTS----------------------------------------
 #writting a trigger that when data is updated in salary table it should 
 #also update in the demographics
 DELIMITER $$
 CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN 
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
 DELIMITER ;
 
	INSERT INTO employee_salary (employee_id, first_name, last_name,occupation, salary,dept_id)
	VALUES (15,'Lee','Chao','Analyst',500000,NULL);
    
    
#EVENTS - it is scheduled
# Create an event that checks people everyday to retire them after a certain age

DELIMITER $$
CREATE EVENT delete_OLD
ON SCHEDULE EVERY 1 SECOND
DO
BEGIN
		DELETE
        FROM employee_demographics
        WHERE age>=60;
END $$
DELIMITER ;


SELECT *
        FROM employee_demographics
        WHERE age>60;

SHOW VARIABLES LIKE 'event%';