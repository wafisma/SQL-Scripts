--Actual Script
SELECT fjd.gkey AS JOB_ID,fjl.state AS JOB_STATE,fjd.id AS JOB,fjl.job_start_date AS JOB_START_DATE,fjl.job_end_date AS JOB_END_DATE
FROM frm_job_log fjl
INNER JOIN frm_job_definition fjd ON fjd.gkey=fjl.job_definition_gkey
WHERE fjl.state <>'WARNING' AND fjl.state <>'FAIL' AND fjl.state <>'SUCCESS' AND fjl.state <>'CANCEL'

--Alternative Actual Script
SELECT fjd.gkey AS JOB_ID,fjl.state AS JOB_STATE,fjd.id AS JOB,fjl.job_start_date AS JOB_START_DATE,fjl.job_end_date AS JOB_END_DATE
FROM frm_job_log fjl
INNER JOIN frm_job_definition fjd ON fjd.gkey=fjl.job_definition_gkey
WHERE fjl.job_end_date IS NULL 

--Test Script
SELECT fjd.gkey AS JOB_ID,fjl.state AS JOB_STATE,fjd.id AS JOB,fjl.job_start_date AS JOB_START_DATE,fjl.job_end_date AS JOB_END_DATE
FROM frm_job_log fjl
INNER JOIN frm_job_definition fjd ON fjd.gkey=fjl.job_definition_gkey
WHERE fjl.state='WARNING' 

--updated Actual
SELECT fjd.gkey AS JOBId,fjl.state AS JobState,fjd.id AS JobName,fjl.job_start_date AS JobStartDate,fjl.job_end_date AS JobEndDate,
DATEDIFF(MINUTE, fjl.job_start_date, fjl.job_end_date) AS JobStartEndDiff
FROM frm_job_log fjl
INNER JOIN frm_job_definition fjd ON fjd.gkey=fjl.job_definition_gkey
WHERE fjl.state='FAIL' AND DATEDIFF(MINUTE, fjl.job_start_date, fjl.job_end_date)>=20

fjl.job_end_date IS NULL
