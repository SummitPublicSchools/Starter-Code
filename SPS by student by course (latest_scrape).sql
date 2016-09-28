--pulls latest student and course level information. includes demographics: don't share SPED data

SELECT

  -- Student Information
  sites.name AS "Site",
  students.grade_level AS "Grade Level",
  students.school_id AS "Student ID",
  students.last_name AS "Student Last Name",
  students.first_name AS "Student First Name",
  students.email AS "Student Email",

 CASE
                WHEN student_demographics.reported_race IS NOT NULL THEN student_demographics.reported_race
                ELSE 'Not Specified'
                END AS ethnicity
            , CASE
                WHEN student_demographics.sed = 'T' THEN 'Socioeconomically Disadvantaged'
                WHEN student_demographics.Sed = 'F' THEN 'Not Socioeconomically Disadvantaged'
                ELSE 'Awaiting Paperwork'
                END AS socioeconomic_status
            , CASE
                WHEN student_demographics.sped = 'T' THEN 'Special Education'
                WHEN student_demographics.sped = 'F' THEN 'General Education'
                ELSE 'Awaiting Paperwork'
                END AS sped
            , CASE
                WHEN student_demographics.english_proficiency IS NOT NULL THEN student_demographics.english_proficiency
                ELSE 'Awaiting Paperwork'
                END AS english_proficiency,


  -- Mentor Information
  mentors.last_name AS "Mentor Last Name",
  mentors.first_name AS "Mentor First Name",
  mentors.email AS "Mentor Email Address",

  -- SPED Information
  sped_cases.dbid IS NOT NULL AS "Student Is Special Ed?",
  case_managers.last_name AS "Case Manager Last Name",
  case_managers.first_name AS "Case Manager First Name",

  -- Course, Teacher, Section Information
  subjects.name AS "Subject",
  courses.name AS "Course Name",
  courses.grade_level AS "Course Grade Level",
  courses.default_seventy_pcnt_score AS "Default 70 Percent Score",
  courses.alternate_seventy_pcnt_score AS "Alternate 70 Percent Score",
  sections.sis_id AS "Illuminate Section ID",
  sections.name AS "Period Name",

  -- Grades
  course_assignments.target_letter_grade AS "Grade Goal",
  course_assignments.letter_grade AS "Current Letter Grade",
  course_assignments.overall_score AS "Overall Course Score",
  course_assignments.power_expected_pcnt AS "Power FAs Expected %",

  -- Cog Skill Information (course-level)
  course_assignments.project_score AS "Cog Skill Percentage",
  ROUND(course_assignments.raw_cog_skill_score,5) AS "Cog Skill Score",

  -- Focus Areas: Power
  course_assignments.power_num_mastered AS "Power FAs Mastered",
  course_assignments.power_out_of AS "Total Power FAs in Course",
  course_assignments.power_out_of - course_assignments.power_num_mastered AS "Power FAs Left",
  course_assignments.power_num_behind AS "Power FAs Behind",
  ROUND(course_assignments.power_expected,3) AS "Power FAs Expected by End of Year",
  course_assignments.power_on_track AS "On Track to Pass All Power Focus Areas",

  -- Focus Areas: Additional
  course_assignments.addl_num_mastered AS "Additional FAs Mastered",
  course_assignments.addl_out_of AS "Total Additional FAs in Course",
  course_assignments.addl_out_of - course_assignments.addl_num_mastered AS "Additional FAs Left",
  ROUND(course_assignments.addl_expected,3) AS "Additional FAs Expected by End of Year",

  -- Projects
  course_assignments.num_projects_overdue AS "Number of Projects Overdue",
  course_assignments.num_projects_graded as "Number of Projects Graded",
  course_assignments.num_projects_ungraded as "Number of Projects Ungraded",
  course_assignments.num_projects_total AS "Total Number of Projects",
  COALESCE(course_assignments.num_projects_overdue, 0) = 0 AND
  COALESCE(course_assignments.project_score, 100) >= 85 AS "On Track for Projects"


FROM
  latest_scrape_students AS students
	LEFT OUTER JOIN summit_student_demographics AS student_demographics
		ON student_demographics.student_id = students.dbid
  LEFT OUTER JOIN latest_scrape_sped_cases AS sped_cases
    ON sped_cases.student_id = students.dbid
		AND students.visibility = 'visible'
  LEFT OUTER JOIN latest_scrape_teachers AS case_managers
    ON case_managers.dbid = sped_cases.teacher_id
  INNER JOIN latest_scrape_sites AS sites
    ON sites.dbid = students.site_id
  LEFT OUTER JOIN latest_scrape_teachers AS mentors
    ON mentors.dbid = students.mentor_id
  INNER JOIN latest_scrape_course_assignments AS course_assignments
    ON course_assignments.student_id = students.dbid
		AND course_assignments.visibility = 'visible'
  INNER JOIN latest_scrape_courses AS courses
    ON courses.dbid = course_assignments.course_id
		AND courses.visibility = 'visible'
  LEFT OUTER JOIN latest_scrape_subjects AS subjects
    ON subjects.dbid = courses.subject_id
  LEFT OUTER JOIN latest_scrape_course_assignment_sections AS course_assignment_sections
    ON course_assignment_sections.course_assignment_id = course_assignments.dbid
  INNER JOIN latest_scrape_sections AS sections
    ON sections.dbid = course_assignment_sections.section_id


WHERE
  sites.district_id = 1 AND
  sites.name NOT IN ('Unknown Summit','SPS Tour') AND
  subjects.core = TRUE AND
  courses.academic_year = 2017 AND
  course_assignments.as_of - CURRENT_DATE > -1 AND
  students.still_enrolled = TRUE


ORDER BY
  "Site",
  "Grade Level",
  "Student Last Name",
  "Student First Name"
  ;
