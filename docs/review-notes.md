# Source export review notes

## Findings from `HRMS_SCRIPT.sql`

1. Eleven tables were found: `ATTENDANCE`, `DEPARTMENTS`, `EMPLOYEES`, `HOLIDAYS`, `LEAVE_REQUESTS`, `LEAVE_TYPES`, `PAYROLL`, `PAYROLL_RUNS`, `POSITIONS`, `ROLES`, and `USERS`.
2. Functions found: `DETERMINE_ATTENDANCE_STATUS`, `GET_APPROVED_LEAVE_TYPE`, `HASH_PASSWORD`, `HRMS_LOGIN_USER`, `IS_WORKING_DAY`, and `LOGIN_USER`.
3. Procedures found: `ADD_USER`, `CREATE_EMPLOYEE_WITH_USER`, `DELETE_EMPLOYEE_ACCOUNT`, `GENERATE_DAILY_ATTENDANCE`, and `GENERATE_PAYROLL_RUN`.
4. The view `VW_PAYROLL_RUNS` was found.
5. `TRG_ATTENDANCE_STATUS` and `TRG_USERS_BI` appeared more than once in the export; one definition of each is retained.
6. `TRG_BI_EMPLOYEES` targets `OEHR_EMPLOYEES`, not the project table `EMPLOYEES`, and was excluded from the organized scripts as likely unrelated.
7. The source export includes explicit unique index statements that overlap indexes created for primary-key/unique constraints. They were not copied into the organized files because constraint DDL already defines those keys. Review if custom index details are required.
8. No seed-data inserts were included in this organized package.

## Items to verify in Oracle before calling this a reproducible deployment

- Compile status for all functions, procedures, triggers, and the view.
- Whether every foreign key and check constraint from the source export is present.
- Authentication Scheme configuration and actual login behavior.
- Whether all new user accounts should begin inactive.
- A secure password creation/reset and first-login workflow.
- Whether `PAYROLL_RUNS.CREATED_BY` and `APPROVED_BY` should reference employee IDs or user IDs; the source schema currently references `EMPLOYEES(EMPLOYEE_ID)`.
- Whether the application uses additional objects not included in the export.
