--------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************************************************************************************

Basecamp Schools
By Student By Course By Focus Area
Uses latest_scrape tables

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

	-- Focus Areas
	, focus_area_id
	, focus_area

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

			-- Focus Areas
			, focus_areas.dbid AS focus_area_id
			, focus_areas."name" AS focus_area

		FROM 
			basecamp_site_info AS basecamp_schools

			-- Schools
			LEFT OUTER JOIN latest_scrape_sites AS schools
				ON schools.dbid = basecamp_schools.site_id

			-- Students
			LEFT OUTER JOIN latest_scrape_students AS students
				ON students.site_id = basecamp_schools.site_id 
				AND students.visibility = 'visible'
				AND students.still_enrolled IS TRUE

			-- Mentors
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

			-- Courses --> Focus Areas
			LEFT OUTER JOIN latest_scrape_course_know_dos AS course_focus_areas
				ON course_focus_areas.course_id = courses.dbid
			-- NOTE:  Used an INNER JOIN to eliminate courses without Focus Areas	
			INNER JOIN latest_scrape_know_dos AS focus_areas
				ON focus_areas.dbid = course_focus_areas.know_do_id
				AND focus_areas.visibility = 'visible'
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

	-- Focus Areas
	, focus_area_id
	, focus_area

ORDER BY
	school_id ASC
	, grade_level ASC
	, student_id ASC
	, focus_area_id ASC
;
