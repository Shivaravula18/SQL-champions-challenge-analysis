
-- Day 1 - Assignment
CREATE SCHEMA `project-c.learning_sql`;
CREATE SCHEMA `project-c.practice_sql`;

CREATE TABLE `project-c.learning_sql.learning_table_1` (
  student_id INT64,
  student_name STRING,
  course_enrolled STRING,
  enrollment_date DATE,
  course_progress FLOAT64,
  is_active BOOL
);

-- Day 2 - Assignment
CREATE TABLE `project-c.learning_sql.students_info` (
  student_id INT64 PRIMARY KEY,
  student_name STRING NOT NULL,
  course_enrolled STRING NOT NULL,
  course_progress FLOAT64,
  is_active BOOL
);

ALTER TABLE `project-c.learning_sql.students_info`
ADD COLUMN email STRING;

CREATE OR REPLACE TABLE `project-c.learning_sql.students_info` AS
SELECT 
  student_id,
  student_name,
  course_enrolled,
  ROUND(course_progress, 2) AS course_progress,
  is_active,
  email
FROM `project-c.learning_sql.students_info`;

CREATE OR REPLACE TABLE `project-c.learning_sql.students_info` AS
SELECT * FROM `project-c.learning_sql.students_info`
WHERE TRUE;

ALTER TABLE `project-c.learning_sql.students_info`
ADD CONSTRAINT unique_email UNIQUE(email);

ALTER TABLE `project-c.learning_sql.students_info`
ADD CONSTRAINT check_course_progress CHECK(course_progress BETWEEN 0 AND 100);

ALTER TABLE `project-c.learning_sql.students_info`
DROP COLUMN email;

ALTER TABLE `project-c.learning_sql.students_info`
RENAME COLUMN student_name TO full_name;

ALTER TABLE `project-c.learning_sql.students_info`
ALTER COLUMN is_active SET DEFAULT TRUE;

ALTER TABLE `project-c.learning_sql.students_info`
DROP CONSTRAINT check_course_progress;

TRUNCATE TABLE `project-c.learning_sql.students_info`;

-- Day 3 - Assignment
SELECT
  user_id,
  lesson_id,
  datetime,
  SUM(day_completion_percentage) OVER(PARTITION BY user_id, lesson_id ORDER BY datetime) AS cumulative_completion
FROM `project-c.learning_sql.day_wise_user_learning_activity`;

WITH max_completion AS (
  SELECT
    user_id,
    lesson_id,
    MAX(overall_completion_percentage) AS max_completion
  FROM `project-c.learning_sql.day_wise_user_learning_activity`
  GROUP BY user_id, lesson_id
),
avg_completion AS (
  SELECT
    lesson_id,
    AVG(max_completion) AS average_completion_percentage
  FROM max_completion
  GROUP BY lesson_id
)
SELECT
  lesson_id,
  average_completion_percentage,
  RANK() OVER (ORDER BY average_completion_percentage DESC) AS rank_of_lesson
FROM avg_completion;

SELECT
  user_id,
  lesson_id,
  MIN(DATE(datetime)) AS lesson_start_date,
  MAX(DATE(datetime)) AS lesson_end_or_last_progress_date
FROM `project-c.learning_sql.day_wise_user_learning_activity`
GROUP BY user_id, lesson_id;

SELECT
  user_id,
  MAX(IF(lesson_id = 'lesson_1', overall_completion_percentage, NULL)) AS lesson_1_completion_percentage,
  MAX(IF(lesson_id = 'lesson_2', overall_completion_percentage, NULL)) AS lesson_2_completion_percentage,
  MAX(IF(lesson_id = 'lesson_3', overall_completion_percentage, NULL)) AS lesson_3_completion_percentage,
  MAX(IF(lesson_id = 'lesson_4', overall_completion_percentage, NULL)) AS lesson_4_completion_percentage,
  MAX(IF(lesson_id = 'lesson_5', overall_completion_percentage, NULL)) AS lesson_5_completion_percentage
FROM `project-c.learning_sql.day_wise_user_learning_activity`
WHERE overall_completion_percentage = 100
GROUP BY user_id;

WITH completed AS (
  SELECT user_id, lesson_id, MIN(datetime) AS completed_at
  FROM `project-c.learning_sql.day_wise_user_learning_activity`
  WHERE overall_completion_percentage = 100
  GROUP BY user_id, lesson_id
)
SELECT
  lesson_id,
  user_id,
  RANK() OVER (PARTITION BY lesson_id ORDER BY completed_at) AS rank
FROM completed
ORDER BY lesson_id, rank;

WITH completed AS (
  SELECT user_id, lesson_id, MIN(datetime) AS completed_at
  FROM `project-c.learning_sql.day_wise_user_learning_activity`
  WHERE overall_completion_percentage = 100
  GROUP BY user_id, lesson_id
)
SELECT
  user_id,
  lesson_id,
  RANK() OVER (PARTITION BY user_id ORDER BY completed_at) AS order_of_completion
FROM completed
ORDER BY user_id, order_of_completion;

WITH completed AS (
  SELECT
    lesson_id,
    user_id,
    MIN(datetime) AS completed_at
  FROM `project-c.learning_sql.day_wise_user_learning_activity`
  WHERE overall_completion_percentage = 100
  GROUP BY lesson_id, user_id
),
ranked AS (
  SELECT
    lesson_id,
    user_id,
    completed_at,
    RANK() OVER (PARTITION BY lesson_id ORDER BY completed_at) AS rank_of_user
  FROM completed
),
with_neighbors AS (
  SELECT
    a.lesson_id,
    a.user_id,
    a.rank_of_user,
    COALESCE(b.user_id, 'No User') AS previous_user_who_completed,
    COALESCE(c.user_id, 'No User') AS next_user_who_completed
  FROM ranked a
  LEFT JOIN ranked b
    ON a.lesson_id = b.lesson_id AND a.rank_of_user = b.rank_of_user + 1
  LEFT JOIN ranked c
    ON a.lesson_id = c.lesson_id AND a.rank_of_user = c.rank_of_user - 1
)
SELECT * FROM with_neighbors;

WITH completed AS (
  SELECT
    lesson_id,
    user_id,
    MIN(datetime) AS completed_at
  FROM `project-c.learning_sql.day_wise_user_learning_activity`
  WHERE overall_completion_percentage = 100
  GROUP BY lesson_id, user_id
),
ranked AS (
  SELECT
    lesson_id,
    user_id,
    RANK() OVER (PARTITION BY lesson_id ORDER BY completed_at) AS rnk
  FROM completed
)
SELECT
  lesson_id,
  user_id AS fourth_person_who_completed
FROM ranked
WHERE rnk = 4;

-- Day 6 - Assignment
SELECT table_name
FROM `my_project.my_dataset.INFORMATION_SCHEMA.TABLES`
WHERE table_type = 'BASE TABLE';

SELECT
  column_name,
  data_type,
  is_nullable
FROM `my_project.my_dataset.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'my_table';

SELECT
  referenced_table_name AS table_name,
  COUNT(*) AS query_count
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE project_id = 'my_project'
  AND referenced_table_name IS NOT NULL
GROUP BY referenced_table_name
ORDER BY query_count DESC;

SELECT
  table_name
FROM `my_project.my_dataset.__TABLES__`
WHERE row_count = 0;

SELECT
  table_name,
  creation_time,
  view_definition
FROM `my_project.my_dataset.INFORMATION_SCHEMA.VIEWS`;

SELECT schema_name
FROM `my_project.INFORMATION_SCHEMA.SCHEMATA`;
