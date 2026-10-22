-- Oracle APEX HRMS database installation script
-- Run using SQLcl or SQL*Plus from this directory.
-- Review the security notes in README.md before installing.

SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

@@01_tables.sql
@@02_foreign_keys.sql
@@03_functions.sql
@@04_procedures.sql
@@05_triggers.sql
@@06_views.sql

PROMPT HRMS database objects submitted. Review compilation errors and object status.
