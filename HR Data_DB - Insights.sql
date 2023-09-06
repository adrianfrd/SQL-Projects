-- IN THIS PROJECT I HAVE GATHERED INSIGHTS ABOUT HUMAN RESOURCE DATA
-- THE INSIGHTS ABOUT ALL ACTIVE/ATTRITION EMPLOYEE ON COMPANY AND ALL BACKGROUND EMPLOYEE
SELECT * FROM hrdata;

/* Total Employee Active */
SELECT 
	SUM(employee_count) - 
	(SELECT 
		 COUNT(attrition) 
	 FROM hrdata 
	 WHERE attrition = 'Yes') AS Employee_Active
FROM hrdata

/* Total Attrition from ALL Employee */
SELECT
	COUNT(Attrition) as Attrition
FROM hrdata
WHERE attrition = 'Yes'

/* Percentage Total Attrition from All Employee*/
SELECT
	ROUND(((SELECT
		SUM(employee_count) AS total_employee
	FROM hrdata
	WHERE attrition = 'Yes') * 100) /
	SUM(employee_count),2) AS Percentage_Attrition
FROM hrdata;


/* Total Attrition by gender */
SELECT
	gender,
	SUM(employee_count) AS total_employee
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY gender
ORDER BY total_employee DESC;



/* Percentage Attrition each Job Role */
SELECT 
	job_role, 
	COUNT(attrition),
	ROUND(
		(CAST(COUNT(attrition) AS NUMERIC) / 
		(SELECT COUNT(attrition) 
	   	 FROM hrdata 
	     WHERE attrition='Yes')) * 100
		,2) AS percentage
FROM hrdata
WHERE attrition ='Yes'
GROUP BY job_role
ORDER BY COUNT(attrition) DESC;


/* Average age employee each gender */
SELECT
	gender,
	ROUND(AVG(age),2)
FROM hrdata
GROUP BY gender;

/* Total Employee Active each Job Role */
SELECT 
	job_role,
	SUM(employee_count) AS Total_Active
FROM hrdata
WHERE attrition = 'No'
GROUP BY job_role
ORDER BY Total_Active DESC;
	

/* Total Employee who travel the most each Department  */	
SELECT * FROM CROSSTAB($$
	SELECT
		department,
		business_travel,
		SUM(employee_count) AS Total
	FROM hrdata
	GROUP BY department, business_travel
	ORDER BY department, Total DESC
$$) AS ct (department VARCHAR,
		  Travel_Rarely numeric,
		  Travel_Frequently numeric,
		  "Non-Travel" numeric)
ORDER BY Travel_rarely Desc;

/* Total Employee Background Education each Department */
SELECT * FROM CROSSTAB($$
	SELECT
		department,
		education,
		SUM(employee_count) AS Total
	FROM hrdata
	GROUP BY department, education
	ORDER BY department, Total DESC
$$) AS ct (department VARCHAR,
		  "Masters Degree" NUMERIC,
		  "Associates Degree" NUMERIC,
		  "Doctoral Degree" NUMERIC,
		  "High School" NUMERIC,
		  "Bachelors Degree" NUMERIC
		  )
ORDER BY department Desc;

/* Job Satisfaction each Job Role */
SELECT * FROM CROSSTAB($$
   SELECT job_role, job_satisfaction, sum(employee_count)
   FROM hrdata
   GROUP BY job_role, job_satisfaction
   ORDER BY job_role, job_satisfaction
$$) AS ct(job_role VARCHAR,
		  one NUMERIC,
		  two NUMERIC,
		  three NUMERIC,
		  four NUMERIC)
ORDER BY job_role;
	
	



