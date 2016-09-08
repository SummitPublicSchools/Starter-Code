SELECT DISTINCT
	-- Site
	schools.dbid AS school_id
	, basecamp_schools.use_name AS school_name
	, basecamp_schools.tableau_email AS tableau_email
	, basecamp_schools.region AS region
	, basecamp_schools.basecamp_mentor AS mentor 
  , schools.enrollment_group

	-- Student
	, students.grade_level AS grade_level
	, students.school_id AS student_id
	, students.last_name AS student_last_name
	, students.first_name AS student_first_name

	-- Mentor
	, mentors.last_name || ', ' || mentors.first_name AS mentor_name


FROM
	basecamp_site_info AS basecamp_schools
	LEFT OUTER JOIN latest_scrape_students AS students
		ON students.site_id = basecamp_schools.site_id
		AND students.visibility = 'visible'
		AND students.still_enrolled = TRUE
	LEFT OUTER JOIN latest_scrape_sites AS schools
		ON schools.dbid = basecamp_schools.site_id
		AND schools.as_of = students.as_of
	LEFT OUTER JOIN latest_scrape_teachers AS mentors
		ON mentors.dbid = students.mentor_id


ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
;
