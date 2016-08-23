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
		scrape_sites AS schools
	-- Student and Mentors Table
	LEFT OUTER JOIN scrape_students AS students
		ON students.site_id = schools.dbid
		AND students.visibility = 'visible'
		AND students.last_leave_on > CURRENT_DATE
		AND students.as_of = schools.as_of
	LEFT OUTER JOIN scrape_teachers AS mentors
		ON mentors.dbid = students.mentor_id
		AND mentors.as_of = students.as_of
	LEFT OUTER JOIN scrape_course_assignments AS cas
		ON cas.student_id = students.dbid
		AND cas.visibility = 'visible'
		AND cas.as_of = students.as_of
	LEFT OUTER JOIN scrape_courses As courses
		ON cas.course_id = courses.dbid
		AND courses.visibility = 'visible'
		AND cas.as_of = courses.as_of

WHERE students.as_of = '2016-08-23' AND
  schools.district_id = 1 AND
  schools.name NOT IN ('Unknown Summit','SPS Tour') AND
  courses.academic_year = 2017 AND
  students.still_enrolled = TRUE



ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
;
