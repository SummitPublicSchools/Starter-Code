SELECT DISTINCT
	-- Site
	schools.dbid AS school_id

	-- Student
	, students.grade_level AS grade_level
	, students.school_id AS student_id
	, students.last_name AS student_last_name
	, students.first_name AS student_first_name

	-- Mentor
	, mentors.last_name || ', ' || mentors.first_name AS mentor_name


FROM

	-- Site Table
latest_scrape_sites AS schools
	-- Student and Mentors Table
	LEFT OUTER JOIN latest_scrape_students AS students
		ON students.site_id = schools.dbid
		AND students.visibility = 'visible'
		AND students.last_leave_on > CURRENT_DATE
	LEFT OUTER JOIN latest_scrape_teachers AS mentors
		ON mentors.dbid = students.mentor_id
	LEFT OUTER JOIN latest_scrape_course_assignments AS cas
		ON cas.student_id = students.dbid
		AND cas.visibility = 'visible'
	LEFT OUTER JOIN latest_scrape_courses As courses
		ON cas.course_id = courses.dbid
		AND courses.visibility = 'visible'

WHERE
  schools.district_id = 1 AND
  schools.name NOT IN ('Unknown Summit','SPS Tour') AND
  courses.academic_year = 2017 AND
  students.still_enrolled = TRUE


ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
;
