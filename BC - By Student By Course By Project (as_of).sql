--------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************************************************************************************

Basecamp Schools
By Student By Course By Project
Uses scrape tables with as of match

Rationale for Group By:
One course can have multiple teachers. To address this, teachers have been aggregated by course.

********************************************************************************************************************************************/

--------------------------------------------------------------------------------------------------------------------------------------------

SELECT
	-- School
	school_id
	, school
	, tableau_email
	, region
	, basecamp_mentor
	, enrollment_group

	-- Student
	, grade_level
	, student_id
	, student_last_name
	, student_first_name

	-- Mentor
	, mentor

	-- Subject
	, subject_id
	, subject

	-- Course
	, course_id
	, course

	-- Teachers
	, LISTAGG(teacher, '; ') WITHIN GROUP (ORDER BY teacher) AS teachers

	-- Project
	, project_id
	, project

FROM
	(

		SELECT
			-- School
			schools.dbid AS school_id
			, basecamp_schools.use_name AS school
			, basecamp_schools.tableau_email AS tableau_email
			, basecamp_schools.region AS region
			, basecamp_schools.basecamp_mentor AS basecamp_mentor
			, schools.enrollment_group AS enrollment_group

			-- Student
			, students.grade_level AS grade_level
			, students.school_id AS student_id
			, students.last_name AS student_last_name
			, students.first_name AS student_first_name

			-- Mentor
			, mentors.last_name || ', ' || mentors.first_name AS mentor

			-- Subject
			, subjects.dbid AS subject_id
			, subjects."name" AS subject

			-- Course
			, courses.dbid AS course_id
			, courses."name" AS course

			-- Teacher
			, teachers.dbid AS teacher_id
			, teachers.last_name || ', ' || teachers.first_name AS teacher

			-- Project
			, projects.dbid AS project_id
			, projects."name" AS project

		FROM 
			basecamp_site_info AS basecamp_schools

			-- Schools
			LEFT OUTER JOIN scrape_sites AS schools
				ON schools.dbid = basecamp_schools.site_id

			-- Students
			LEFT OUTER JOIN scrape_students AS students
				ON students.site_id = schools.dbid
				AND students.visibility = 'visible'
				AND students.still_enrolled IS TRUE
				AND students.as_of = schools.as_of

			-- Mentors
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
			LEFT OUTER JOIN scrape_sections AS sections
				ON sections.dbid = course_assignment_sections.section_id
				AND sections.as_of = course_assignment_sections.as_of
			LEFT OUTER JOIN scrape_section_teachers AS section_teachers
				ON section_teachers.section_id = sections.dbid
				AND section_teachers.visibility = 'visible'
				AND section_teachers.as_of = sections.as_of
			LEFT OUTER JOIN scrape_teachers AS teachers
				ON teachers.dbid = section_teachers.teacher_id
				AND teachers.visibility = 'visible'
				AND teachers.as_of = section_teachers.as_of

			-- Course Assignments --> Projects --> Project Assignments
			LEFT OUTER JOIN scrape_project_courses AS project_courses
				ON project_courses.course_id = course_assignments.course_id
				AND project_courses.as_of = course_assignments.as_of
			LEFT OUTER JOIN scrape_projects AS projects
				ON projects.dbid = project_courses.project_id
				AND projects.visibility = 'visible'
				AND projects.as_of = project_courses.as_of
			-- NOTE:  Used an INNER JOIN because we are only interested in projects that have been assigned.
			INNER JOIN scrape_project_assignments AS project_assignments
				ON project_assignments.student_id = students.dbid
				AND project_assignments.project_id = project_courses.project_id
				AND project_assignments.visibility = 'visible'
				AND project_assignments.as_of = students.as_of

		WHERE
			schools.as_of = CURRENT_DATE

	)

GROUP BY
	-- School
	school_id
	, school
	, tableau_email
	, region
	, basecamp_mentor
	, enrollment_group

	-- Student
	, grade_level
	, student_id
	, student_last_name
	, student_first_name

	-- Mentor
	, mentor

	-- Subject
	, subject_id
	, subject

	-- Course
	, course_id
	, course

	-- Project
	, project_id
	, project


ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
	, project_id ASC
;