# Oracle APEX HRMS — Database Scripts

Database source scripts extracted and organized from the supplied `HRMS_SCRIPT.sql` export. This repository currently documents the database layer of an Oracle APEX Human Resource Management System.

## Modules represented in the schema

- Employee, department, position, role, and user management
- Attendance and holiday management
- Leave types and leave requests
- Payroll records and payroll runs
- PL/SQL functions, procedures, triggers, and the `VW_PAYROLL_RUNS` view

## Repository layout

```text
Oracle-APEX-HRMS-Database/
├── README.md
├── database/
│   ├── 01_tables.sql
│   ├── 02_foreign_keys.sql
│   ├── 03_functions.sql
│   ├── 04_procedures.sql
│   ├── 05_triggers.sql
│   ├── 06_views.sql
│   └── install.sql
└── docs/
    └── review-notes.md
```

## Installation

1. Use a disposable/test Oracle schema first. Do not run this over an existing schema without reviewing the DDL; the scripts create objects and are not migration scripts.
2. Open SQLcl or SQL*Plus in the `database` directory.
3. Run `@install.sql`.
4. Review compilation errors and validate object status with `USER_OBJECTS` and `USER_ERRORS`.
5. Add seed data separately only after reviewing and anonymizing it.

`install.sql` uses SQL*Plus-style `@@` includes; it is intended for SQLcl/SQL*Plus, not pasting into the APEX SQL Commands editor as one block.

## Important review notes

- The source export contained repeated definitions of `TRG_ATTENDANCE_STATUS` and `TRG_USERS_BI`; the organized scripts keep one definition of each.
- The source contained `TRG_BI_EMPLOYEES` targeting `OEHR_EMPLOYEES` and referencing `EMP_SEQ`. It was excluded because it appears to be unrelated sample-schema code, not part of the HRMS `EMPLOYEES` table. Confirm before adding it back.
- `CREATE_EMPLOYEE_WITH_USER` currently assigns the same hard-coded temporary password (`Test@12345`) to every new account in the source export. Do not use this behavior in a deployed system. Replace it with a per-user onboarding/reset workflow before production use.
- `TRG_USERS_BI` sets `IS_ACTIVE = 'N'` on every inserted account. New accounts are therefore inactive unless a separate approved activation process changes the flag. Confirm that this is intended.
- `HASH_PASSWORD` uses SHA-256 without a per-user salt. This is not suitable for production password storage; use a password-hashing approach designed for passwords, with salt and an appropriate work factor.
- Both `LOGIN_USER` and `HRMS_LOGIN_USER` appear in the source. Their use by the APEX Authentication Scheme must be verified in the target workspace; the presence of source code does not prove authentication is configured correctly.
- `VW_PAYROLL_RUNS` is included after the tables and PL/SQL objects. Confirm it compiles successfully in the target schema.
- The supplied export did not include an explicit `CREATE TABLE` for every possible object referenced by the application. Treat this as an organized snapshot of the supplied export, not a guarantee that it is a complete, clean-room rebuild of the entire APEX application.

## Security and data handling

Never commit real employee personal information, password values, workspace credentials, API keys, or production connection strings. Keep the application export and database scripts free of secrets.
