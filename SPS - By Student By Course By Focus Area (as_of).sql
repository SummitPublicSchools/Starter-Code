--------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************************************************************************************

Summit Schools
By Student By Course By Focus Area
Uses scrape tables with as of match

Rationale for Group By:
One course can have multiple teachers. To address this, teachers have been aggregated by course.

********************************************************************************************************************************************/

--------------------------------------------------------------------------------------------------------------------------------------------

SELECT
	-- School
	school_id
	, school

	-- Student
	, grade_level
	, student_id
	, student_last_name
	, student_first_name
	, ethnicity
	, socioeconomic_status
	, sped
	, english_proficiency

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
			, schools."name" AS school

			-- Student
			, students.grade_level AS grade_level
			, students.school_id AS student_id
			, students.last_name AS student_last_name
			, students.first_name AS student_first_name
			, CASE
				WHEN student_demographics.ethnicity IS NOT NULL THEN student_demographics.ethnicity
				ELSE 'Not Specified'
				END AS ethnicity
			, CASE
				WHEN student_demographics.socioeconomic_status = 'T' THEN 'Socioeconomically Disadvantaged'
				WHEN student_demographics.socioeconomic_status = 'F' THEN 'Not Socioeconomically Disadvantaged'
				ELSE 'Awaiting Paperwork'
				END AS socioeconomic_status
			, CASE
				WHEN student_demographics.is_sped = 'T' THEN 'Special Education'
				WHEN student_demographics.is_sped = 'F' THEN 'General Education'
				ELSE 'Awaiting Paperwork'
				END AS sped
			, CASE
				WHEN student_demographics.english_proficiency IS NOT NULL THEN student_demographics.english_proficiency
				ELSE 'Awaiting Paperwork'
				END AS english_proficiency

			-- Mentor
			, mentors.last_name || ', ' || mentors.first_name AS mentor

			-- Subject
			, subjects.dbid AS subject_id
			, subjects."name" AS subject

			-- Course
			, courses.dbid AS course_id
			, courses."name" AS course

			-- Teacher
			, teachers.last_name || ', ' || teachers.first_name AS teacher

			-- Focus Areas
			, focus_areas.dbid AS focus_area_id
			, focus_areas."name" AS focus_area

		FROM 
			scrape_sites AS schools

			-- Students
			LEFT OUTER JOIN scrape_students AS students
				ON students.site_id = schools.dbid
				AND students.visibility = 'visible'
				AND students.still_enrolled IS TRUE
				AND students.as_of = schools.as_of
			LEFT OUTER JOIN summit_student_demographics AS student_demographics
				ON student_demographics.student_id = students.dbid

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

			-- Courses --> Focus Areas
			LEFT OUTER JOIN scrape_course_know_dos AS course_focus_areas
				ON course_focus_areas.course_id = courses.dbid
				AND course_focus_areas.as_of = courses.as_of
			-- NOTE:  Used an INNER JOIN to eliminate courses without Focus Areas
			INNER JOIN scrape_know_dos AS focus_areas
				ON focus_areas.dbid = course_focus_areas.know_do_id
				AND focus_areas.visibility = 'visible'
				AND focus_areas.as_of = course_focus_areas.as_of

		WHERE
			schools.enrollment_group = 'summit'
			AND CAST(schools.sis_id AS integer) < 1000
			AND schools.as_of = CURRENT_DATE

	)

GROUP BY
	-- School
	school_id
	, school

	-- Student
	, grade_level
	, student_id
	, student_last_name
	, student_first_name
	, ethnicity
	, socioeconomic_status
	, sped
	, english_proficiency

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
	, course_id ASC
	, focus_area_id ASC
;
