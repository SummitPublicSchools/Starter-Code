---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 

Summit Schools
By Student By Course By Focus Area Starter
Uses scrape tables with as of match

*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT DISTINCT
	-- School
	schools.dbid AS school_id
	, schools."name" AS school_name

	-- Student
	, students.grade_level AS grade_level
	, students.school_id AS student_id
	, students.last_name AS student_last_name
	, students.first_name AS student_first_name

	-- Mentor
	, mentors.last_name || ', ' || mentors.first_name AS mentor_name

	-- Subject
	, subjects.dbid AS subject_id
	, subjects."name" AS subject

	-- Course
	, courses.dbid AS course_id
	, courses."name" AS course_name

	-- Teacher
	, teachers.last_name || ', ' || teachers.first_name AS teacher_name

	-- Focus Areas
	, focus_areas.dbid AS focus_area_id
	, focus_areas."name" AS focus_area_name

FROM 
	scrape_sites AS schools

	-- Student and Mentor
	LEFT OUTER JOIN scrape_students AS students
		ON students.site_id = schools.dbid
		AND students.visibility = 'visible'
		AND students.still_enrolled IS TRUE
		AND students.as_of = schools.as_of

	LEFT OUTER JOIN scrape_teachers AS mentors
		ON mentors.dbid = students.mentor_id
		AND mentors.as_of = students.as_of

	-- Students --> Course Assignments --> Courses --> Subject
	-- NOTE:  Used an INNER JOIN because we are only interested in courses where there are course assignments.
	INNER JOIN scrape_course_assignments AS course_assignments
		ON course_assignments.student_id = students.dbid
		AND course_assignments.visibility = 'visible'
		AND course_assignments.as_of = students.as_of
	INNER JOIN scrape_courses AS courses
		ON courses.dbid = course_assignments.course_id
		AND courses.visibility = 'visible'
		AND courses.academic_year = 2017
		AND courses.as_of = course_assignments.as_of
	LEFT OUTER JOIN scrape_subjects AS subjects
		ON subjects.dbid = courses.subject_id
		AND subjects.as_of = courses.as_of

	-- Course Assignments --> Sections --> Teachers
	LEFT OUTER JOIN scrape_course_assignment_sections AS course_assignment_sections
		ON course_assignment_sections.course_assignment_id = course_assignments.dbid
		AND course_assignment_sections.as_of = course_assignments.as_of
	LEFT OUTER JOIN latest_scrape_sections AS sections
		ON sections.dbid = course_assignment_sections.section_id
		AND sections.as_of = course_assignment_sections.as_of
	LEFT OUTER JOIN latest_scrape_section_teachers AS section_teachers
		ON section_teachers.section_id = sections.dbid
		AND section_teachers.visibility = 'visible'
		AND section_teachers.as_of = sections.as_of
	LEFT OUTER JOIN latest_scrape_teachers AS teachers
		ON teachers.dbid = section_teachers.teacher_id
		AND teachers.visibility = 'visible'
		AND teachers.as_of = section_teachers.as_of

	-- Courses --> Focus Areas
	LEFT OUTER JOIN scrape_course_know_dos AS course_focus_areas
		ON course_focus_areas.course_id = courses.dbid
		AND course_focus_areas.as_of = courses.as_of
	LEFT OUTER JOIN latest_scrape_know_dos AS focus_areas
		ON focus_areas.dbid = course_focus_areas.know_do_id
		AND focus_areas.visibility = 'visible'
		AND focus_areas.as_of = course_focus_areas.as_of

WHERE
	schools.enrollment_group = 'summit'
	AND CAST(schools.sis_id AS integer) < 1000
	AND schools.as_of = CURRENT_DATE

ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
	, course_id ASC
	, teacher_name ASC
	, focus_area_id ASC
;