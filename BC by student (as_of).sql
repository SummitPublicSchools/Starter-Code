SELECT DISTINCT
	-- Site
	schools.dbid AS school_id
	, basecamp_schools.use_name AS school_name
	, basecamp_schools.tableau_email AS tableau_email
	, basecamp_schools.region AS region
	, basecamp_schools.basecamp_mentor AS mentor 

	-- Student
	, students.grade_level AS grade_level
	, students.school_id AS student_id
	, students.last_name AS student_last_name
	, students.first_name AS student_first_name

	-- Mentor
	, mentors.last_name || ', ' || mentors.first_name AS mentor_name


FROM
	basecamp_site_info AS basecamp_schools

	-- Site Table
	LEFT OUTER JOIN scrape_sites AS schools
		ON schools.dbid = basecamp_schools.site_id

	-- Student and Mentors Table
	LEFT OUTER JOIN scrape_students AS students
		ON students.site_id = basecamp_schools.site_id
		AND students.visibility = 'visible'
		AND students.still_enrolled = TRUE
	LEFT OUTER JOIN scrape_teachers AS mentors
		ON mentors.dbid = students.mentor_id
		AND mentors.as_of = students.as_of

WHERE students.as_of = '2016-08-23'


ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
;
