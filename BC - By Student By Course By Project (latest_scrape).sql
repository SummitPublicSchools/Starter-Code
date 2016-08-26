---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 

Basecamp Schools
By Student By Course By Project Starter
Uses latest_scrape tables

*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT DISTINCT
	-- School
	schools.dbid AS school_id
	, basecamp_schools.use_name AS school_name
	, basecamp_schools.tableau_email AS tableau_email
	, basecamp_schools.region AS region


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

	-- Project
	, projects.dbid AS project_id
	, projects."name" AS project_name

FROM 
	basecamp_site_info AS basecamp_schools

	-- School
	LEFT OUTER JOIN latest_scrape_sites AS schools
		ON schools.dbid = basecamp_schools.site_id

	-- Student and Mentor
	LEFT OUTER JOIN latest_scrape_students AS students
		ON students.site_id = basecamp_schools.site_id 
		AND students.visibility = 'visible'
		AND students.still_enrolled IS TRUE
	LEFT OUTER JOIN latest_scrape_teachers AS mentors
		ON mentors.dbid = students.mentor_id

	-- Students --> Course Assignments --> Courses --> Subject
	-- NOTE:  Used an INNER JOIN because we are only interested in courses where there are course assignments.
	INNER JOIN latest_scrape_course_assignments AS course_assignments
		ON course_assignments.student_id = students.dbid
		AND course_assignments.visibility = 'visible'
	INNER JOIN latest_scrape_courses AS courses
		ON courses.dbid = course_assignments.course_id
		AND courses.visibility = 'visible'
		AND courses.academic_year = 2017
	LEFT OUTER JOIN latest_scrape_subjects AS subjects
		ON subjects.dbid = courses.subject_id

	-- Course Assignments --> Sections --> Teachers
	LEFT OUTER JOIN latest_scrape_course_assignment_sections AS course_assignment_sections
		ON course_assignment_sections.course_assignment_id = course_assignments.dbid
	LEFT OUTER JOIN latest_scrape_sections AS sections
		ON sections.dbid = course_assignment_sections.section_id
	LEFT OUTER JOIN latest_scrape_section_teachers AS section_teachers
		ON section_teachers.section_id = sections.dbid
		AND section_teachers.visibility = 'visible'
	LEFT OUTER JOIN latest_scrape_teachers AS teachers
		ON teachers.dbid = section_teachers.teacher_id
		AND teachers.visibility = 'visible'

	-- Course Assignment --> Project --> Project Assignments
	LEFT OUTER JOIN latest_scrape_project_courses AS project_courses
		ON project_courses.course_id = course_assignments.course_id
	LEFT OUTER JOIN latest_scrape_projects AS projects
		ON projects.dbid = project_courses.project_id
		AND projects.visibility = 'visible'
	-- NOTE:  Used an INNER JOIN because we are only interested in projects that have been assigned.
	INNER JOIN latest_scrape_project_assignments AS project_assignments
		ON project_assignments.student_id = students.dbid
		AND project_assignments.project_id = project_courses.project_id
		AND project_assignments.visibility = 'visible'

ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
	, course_id ASC
	, teacher_name ASC
	, project_id ASC
;