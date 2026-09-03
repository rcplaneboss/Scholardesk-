# Product Requirements Document — v3.3

## 1. Application Overview

**Application Name:** School Attendance SMS — v3.3 (Per-School Independent Module Toggle System)

**Description:** A multi-tenant SaaS web application for Nigerian primary and secondary schools, providing student attendance tracking, parent SMS notifications (via Termii), fee management with automated payment reminders, student results calculation, and professionally formatted report card generation. v3.3 builds on v3.2 by adding the ability to independently toggle modules per school: each school can enable or disable any combination of the Attendance, Fees, and Results modules without data migration or redeployment. Super admins can turn modules on or off for any school at any time; both the UI and backend enforce access control in sync. All features from v1, v2, v3, v3.1, and v3.2 remain unchanged.

---

## 2. Users & Use Cases

### 2.1 Target Users

- **Super Admin:** Platform owner; manages all schools, billing, system settings, platform-level metrics, SMS usage analytics, and per-school module toggle configuration.
- **Admin:** School principal; manages classes, teachers, students, guardians, attendance reports, fee categories, fee assignments, payment records, outstanding balances, subjects, grading scale, terms, results overview, and report card generation — limited to modules enabled for their school.
- **Teacher:** Marks daily attendance for their assigned class, views class fee payment status (read-only, no amounts shown), and enters scores for assigned class subjects — limited to modules enabled for their school.
- **Parent / Guardian:** Contact record only (no login); receives SMS notifications for attendance, fee reminders, and results publication.

### 2.2 Core Use Cases

- Teacher marks attendance on a mobile device during the morning roll call.
- Admin defines fee categories and assigns them to students.
- Admin records parent payments and tracks outstanding balances in real time.
- Admin sends automated SMS reminders to parents of students with outstanding fees.
- Admin configures subjects, grading scale, and academic terms.
- Teacher enters continuous assessment and exam scores for assigned class subjects.
- Admin locks a term, then generates and prints professionally formatted report cards.
- Admin sends SMS notifications to parents when results are published.
- Parents receive instant SMS alerts when their child is absent/late, a fee is due, or results are released.
- New users complete an interactive onboarding tour on first login to learn the platform's core features.
- Users restart the onboarding tour via the Help button to review platform features.
- Super admin monitors SMS usage and cost per school, tracked against allocations and pricing.
- Super admin identifies schools approaching their SMS allocation limit to prevent message delivery failures.
- Super admin views platform-wide SMS totals, costs, and revenue profit margins.
- **Super admin independently enables/disables the Attendance, Fees, and Results modules for any school, with immediate effect.**
- **Schools can only access features for enabled modules; disabled modules are completely hidden in the UI and rejected by the backend.**
- **Schools can start with a single module and add more at any time without migration or reconfiguration.**

---

## 3. Page Structure & Feature Descriptions

### 3.1 Page Hierarchy

```
├── Auth Pages
│   ├── Login
│   └── Password Reset
├── Super Admin Dashboard
│   ├── School Management
│   ├── School Module Configuration (new)
│   ├── Platform Metrics
│   ├── Fee Overview
│   ├── SMS Analytics
│   └── Onboarding Tour (restartable)
├── Admin Dashboard
│   ├── Attendance Overview (shown only when Attendance module enabled)
│   ├── Flagged Students (shown only when Attendance module enabled)
│   ├── Class Management
│   ├── Teacher Management
│   ├── Student Management
│   ├── Guardian Management
│   ├── Fee Categories (shown only when Fees module enabled)
│   ├── Fee Assignments (shown only when Fees module enabled)
│   ├── Payment Recording (shown only when Fees module enabled)
│   ├── Outstanding Balances (shown only when Fees module enabled)
│   ├── Subject Management (shown only when Results module enabled)
│   ├── Grading Scale (shown only when Results module enabled)
│   ├── Term Management (shown only when Results module enabled)
│   ├── Results Overview (shown only when Results module enabled)
│   ├── Report Card Generator (shown only when Results module enabled)
│   └── Onboarding Tour (restartable)
├── Teacher Dashboard
│   ├── Mark Attendance (shown only when Attendance module enabled)
│   ├── Class Fee Status (shown only when Fees module enabled)
│   ├── Score Entry (shown only when Results module enabled)
│   └── Onboarding Tour (restartable)
└── Notifications Log
```

### 3.2 Auth Pages

#### 3.2.1 Login Page
- Email and password input fields
- Login button
- Password reset link
- Authenticates users via Supabase Auth
- Redirects by role: super_admin → Super Admin Dashboard, admin → Admin Dashboard, teacher → Teacher Dashboard
- Checks the has_seen_onboarding flag after successful login

#### 3.2.2 Password Reset Page
- Email input field
- Send reset link button
- Triggers a password reset email via Supabase Auth

### 3.3 Super Admin Dashboard

#### 3.3.1 School Management
- Lists all schools with subscription_status and trial_ends_at
- Add new school (name, contact info, subscription plan, trial period)
- Edit school details
- Deactivate / reactivate a school
- View admin users for a school

#### 3.3.2 School Module Configuration (new)

**Location:** Within each school's detail view on the School Management page, or as a dedicated sub-page.

**Features:**
- Displays toggle state for the three modules: Attendance, Fees, Results
- One toggle switch per module showing its current enabled/disabled state
- Toggles take effect immediately — no redeployment or data migration required
- When creating a new school, the super admin can set the initial module states (defaults are configurable)
- Short description shown beside each toggle:
  + Attendance Module: Student attendance tracking and parent SMS notifications
  + Fees Module: Fee management, payment recording, and overdue reminders
  + Results Module: Subject management, score entry, and report card generation

**Interactions:**
- Click a toggle to flip the module state
- Immediately updates the school_modules table
- Shows a confirmation toast: "Attendance/Fees/Results module enabled/disabled for [School Name]"
- The school's admins and teachers will see updated module access on next page refresh

#### 3.3.3 Platform Metrics
- Total number of schools
- Active subscriptions count
- Total students across the platform
- SMS notifications sent (last 30 days)
- Total fee assignments across all schools (current term)
- Total payments recorded across all schools (current term)

#### 3.3.4 Fee Overview
- Total fee assignments across all schools (current term)
- Total payments recorded (current term)
- Collection rate percentage per school
- Schools with the lowest collection rates

#### 3.3.5 SMS Analytics

**Per-school metrics table:**
- Lists all schools with the following columns:
  + School name
  + Total SMS sent this term (broken down: attendance alerts, fee reminders, results notifications)
  + Estimated SMS cost this term (messages sent × cost per message)
  + Student count (from school roster)
  + Usage vs. allocation progress bar (% of estimated term SMS budget used)
  + Alert threshold indicator:
    * Yellow flag at 75% usage
    * Red flag at 90% usage
  + Delivery success rate (% of SMS successfully delivered per Termii delivery status)
- Click a school row to expand a detailed breakdown by notification type
- Sortable by SMS volume (high to low)
- Filterable by alert status (All / Yellow / Red)

**Platform-level summary:**
- Total SMS sent this term (all schools combined)
- Total estimated SMS cost this term (all schools combined)
- Revenue this term (tiered fees + per-student overage totals)
- Profit margin figure (revenue vs. SMS cost)
- Ranked list: top 10 schools by SMS volume

**Data sources:**
- All metrics aggregated from the existing notifications_log table
- Student count pulled from each school's students table
- No new database tables required

#### 3.3.6 Onboarding Tour (Super Admin)
- Auto-triggers on first login if has_seen_onboarding is false
- Restartable via the sidebar/header Help button
- Step 1: Welcome modal with platform overview
- Step 2: Focus on School Management section, tooltip explains school creation
- Step 3: Focus on School Module Configuration, tooltip explains module toggles (new)
- Step 4: Focus on Platform Metrics, tooltip explains key indicators
- Step 5: Focus on SMS Analytics, tooltip explains usage monitoring
- Step 6: Focus on creating a school admin account
- Progress indicator shows current step (e.g. Step 2 of 6)
- All steps are skippable / dismissible
- Sets has_seen_onboarding to true on completion

### 3.4 Admin Dashboard

**Module access control:** The pages below are only shown when the corresponding module is enabled for the school. Pages for disabled modules are completely hidden from navigation.

#### 3.4.1 Attendance Overview (Attendance module only)
- Shows today's attendance summary across all classes
- Displays present / absent / late / excused student percentages
- Filterable by date range

#### 3.4.2 Flagged Students (Attendance module only)
- Automatically surfaces students with 3 or more absences in the last 7 days
- Shows student name, class, absence count, and last absent date
- Click a student to view detailed attendance history

#### 3.4.3 Class Management
- Lists all classes in the school
- Add new class (name, grade level)
- Edit class details
- Delete class (only if no students are assigned)
- Assign a teacher to a class

#### 3.4.4 Teacher Management
- Lists all teachers
- Add new teacher (name, email, assigned class, temporary password)
- Force password reset on teacher's first login
- Edit teacher details
- Deactivate a teacher account
- Reassign a teacher to a different class

#### 3.4.5 Student Management
- Lists all students with class assignments
- Add new student (name, class, date of birth)
- Edit student details
- Transfer to another class
- Deactivate a student record
- Link guardians to a student

#### 3.4.6 Guardian Management
- Lists all guardians with linked students
- Add new guardian (name, phone number, relationship)
- Edit guardian details
- Mark a guardian as the primary contact for a student
- Link a guardian to multiple students (siblings)

#### 3.4.7 Fee Categories (Fees module only)
- Lists all fee categories for the school (name, amount, term, due date, description)
- Add new fee category (name, amount ₦, term: First/Second/Third, academic year, due date, optional description)
- Edit fee category (name, amount, due date; editing blocked if payments have been recorded against it)
- Deactivate a fee category
- Duplicate a category to a new term

#### 3.4.8 Fee Assignments (Fees module only)
- Lists current assignments: student name, class, fee category, amount due, due date, payment status
- Bulk assignment: assign a fee category to an entire class at once
- Individual assignment: assign a fee category to a specific student
- Remove assignment (only if no payments have been recorded)
- Filterable by class, fee category, and payment status

#### 3.4.9 Payment Recording (Fees module only)
- Search students by name or admission number
- Shows all outstanding fee assignments with remaining balances
- Record payment (fee assignment, amount paid ₦, payment date, method: Cash / Bank Transfer / POS, optional reference number)
- Partial payments allowed
- View payment history per student with timestamps and recorded-by info
- Print receipt (browser print)

#### 3.4.10 Outstanding Balances (Fees module only)
- Lists all students with outstanding balances, sorted by total owed
- Displays: student name, class, number of outstanding items, total amount owed
- Filterable by class
- Click a student to expand itemised fee breakdown
- Send reminder SMS button per student
- Send All Reminders button with confirmation prompt showing count
- Export to CSV

#### 3.4.11 Subject Management (Results module only)
- Lists all subjects for the school (name, code, assigned classes)
- Add new subject (name, code)
- Edit subject name and code
- Assign subject to one or more classes
- Deactivate a subject

#### 3.4.12 Grading Scale (Results module only)
- Define score ranges (min score, max score, letter grade, remark)
- Edit ranges and remarks
- Grading scale is school-wide (not per subject or class)

#### 3.4.13 Term Management (Results module only)
- Lists terms (name, academic year, start date, end date, is_active, is_locked)
- Create new term (name, academic year, start date, end date)
- Set active term (only one active term per school at a time)
- Lock term (prevents teachers from editing scores)
- Unlock term (with confirmation warning)

#### 3.4.14 Results Overview (Results module only)
- Shows score entry progress for all classes and subjects
- Highlights incomplete subjects
- View raw scores for any class/subject combination
- Directly edit any score (admin override)
- Per-class summary statistics: highest total, lowest total, class average

#### 3.4.15 Report Card Generator (Results module only)
- Select class and term
- Preview the formatted report card layout
- Enter teacher remarks per student
- Enter principal remarks (one shared remark or per-student)
- Print a single report card (individual student)
- Print the entire class at once (all cards in one print job, one student per page)
- Notify Parents button (sends SMS to all primary guardians)

#### 3.4.16 Onboarding Tour (Admin)
- Auto-triggers on first login if has_seen_onboarding is false
- Restartable via the sidebar/header Help button
- Step 1: Welcome modal explaining the school setup flow
- Step 2: Focus on Term Management, tooltip explains term creation (shown only if Results module enabled)
- Step 3: Focus on Class Management, tooltip explains class setup
- Step 4: Focus on Subject Management, tooltip explains subject assignment (shown only if Results module enabled)
- Step 5: Focus on Teacher Management, tooltip explains adding teachers
- Step 6: Focus on Student Management, tooltip explains adding students
- Step 7: Focus on Attendance Overview, tooltip explains attendance tracking (shown only if Attendance module enabled)
- Step 8: Focus on Report Card Generator, tooltip explains results workflow (shown only if Results module enabled)
- Progress indicator shows current step (e.g. Step 3 of 8)
- All steps are skippable / dismissible
- Sets has_seen_onboarding to true on completion

### 3.5 Teacher Dashboard

**Module access control:** The pages below are only shown when the corresponding module is enabled for the school.

#### 3.5.1 Mark Attendance Page (Attendance module only)
- Shows the assigned class roster for the current date
- Displays student names with initials avatars
- Large touch-friendly buttons per student: Present, Absent, Late
- Single tap marks status; UI updates immediately (optimistic update)
- Progress indicator showing students marked vs. total
- Submit button activates once all students are marked
- On submit: saves all attendance records and queues SMS for absent/late students
- Confirmation shown with a stamp / seal visual feedback
- If save fails: reverts UI and shows an error message

#### 3.5.2 Class Fee Status (Fees module only)
- Shows assigned class only
- Lists students with paid / partial / unpaid indicators per term
- No amounts shown to teachers
- Read-only; no actions available

#### 3.5.3 Score Entry (Results module only)
- Teacher selects a subject from those assigned to their class
- Views the full class roster for that subject
- Enters CA score (max 40) and exam score (max 60) per student
- Total score auto-calculates (CA + Exam)
- Grade and remark auto-populate based on the grading scale
- Save button per subject (saves all at once)
- Pre-fills existing scores on revisit
- Visual indicator per subject: Not Started / In Progress / Completed
- Disabled when the term is locked

#### 3.5.4 Onboarding Tour (Teacher)
- Auto-triggers on first login if has_seen_onboarding is false
- Restartable via the sidebar/header Help button
- Step 1: Welcome modal explaining the teacher's responsibilities
- Step 2: Focus on assigned class section, tooltip explains the class roster
- Step 3: Focus on Mark Attendance, tooltip explains how to mark attendance (shown only if Attendance module enabled)
- Step 4: Focus on student list, tooltip explains viewing student details
- Step 5: Focus on Score Entry, tooltip explains entering CA and exam scores (shown only if Results module enabled)
- Progress indicator shows current step (e.g. Step 2 of 5)
- All steps are skippable / dismissible
- Sets has_seen_onboarding to true on completion

### 3.6 Notifications Log

- Lists all SMS notifications with status (Pending / Sent / Failed)
- Shows student name, guardian phone, message content, timestamp, and provider response
- Filterable by notification type (Attendance | Fee Reminder | Results Notification), date range, and status
- Admin view is automatically scoped to their school
- Super admin view includes a school filter
- Retry failed notifications

### 3.7 Help Button

- Persistent button in the sidebar/header on all dashboard pages
- Clicking it restarts the onboarding tour for the current user's role
- Tour always starts from Step 1 regardless of prior completion

---

## 4. Business Rules & Logic

### 4.1 Multi-Tenancy & Data Isolation

- Each school is an independent tenant identified by school_id.
- All tenant-scoped tables (classes, students, guardians, attendance_records, fee_categories, fee_assignments, fee_payments, subjects, class_subjects, grading_scale, terms, score_records, report_card_remarks) must have Row-Level Security policies.
- Admin and teacher users can only access data for their assigned school's school_id.
- Super admins can access data for all schools.
- A user's school_id is stored in the profiles table, linked to auth.users.

### 4.2 Role-Based Access Control

- **super_admin:** Full platform access; manages all schools; views fee revenue overview, platform-level metrics, SMS analytics, and school module configuration.
- **admin:** Manages their school's data only (classes, teachers, students, guardians, attendance reports, fee categories, fee assignments, payment records, outstanding balances, subjects, grading scale, terms, results overview, report card generation); access limited to the school's enabled modules.
- **teacher:** Can only mark attendance for their assigned class, view class fee status read-only (no amounts), and enter scores for assigned class subjects; cannot edit student/guardian/fee/subject/term data; access limited to the school's enabled modules.

### 4.3 Module Access Control Rules (new)

#### 4.3.1 Module Definitions

- **Attendance Module (attendance_enabled):** Attendance marking, attendance overview, flagged students, attendance-related SMS notifications.
- **Fees Module (fees_enabled):** Fee categories, fee assignments, payment recording, outstanding balances, fee reminder SMS.
- **Results Module (results_enabled):** Subject management, grading scale, term management, score entry, results overview, report card generation, results notification SMS.

#### 4.3.2 UI-Layer Enforcement

- All pages, navigation items, and buttons for a disabled module are completely hidden from admin and teacher dashboards — not greyed out or locked, but entirely absent.
- Examples:
  + If fees_enabled is false, the admin dashboard shows no Fee Categories, Fee Assignments, Payment Recording, or Outstanding Balances pages.
  + If results_enabled is false, the teacher dashboard shows no Score Entry page.

#### 4.3.3 Backend / RLS-Layer Enforcement (critical — cannot be skipped)

- Even when the UI hides a module, the backend must independently verify a school's module access before allowing any related data operation.
- This must be enforced as strictly as tenant isolation — RLS policies (or equivalent server-side checks) must reject any attendance/fees/results operation if the module is disabled for that school, regardless of what the UI shows.
- Rationale: relying on UI-only hiding means anyone with direct API access (e.g. via browser dev tools) could access modules they have not paid for. This is the same class of risk as cross-tenant RLS — hiding in the UI does not mean actually blocking.
- Implementation:
  + RLS policies on all attendance-related tables (attendance_records) must check school_modules.attendance_enabled = true.
  + RLS policies on all fee-related tables (fee_categories, fee_assignments, fee_payments) must check school_modules.fees_enabled = true.
  + RLS policies on all results-related tables (subjects, class_subjects, grading_scale, terms, score_records, report_card_remarks) must check school_modules.results_enabled = true.
  + API endpoints must verify module-enabled status before processing requests.

#### 4.3.4 Module Toggle Effect Mechanism

- When a super admin toggles a module, school_modules is updated immediately.
- The school's admins and teachers will see updated access on next page refresh or re-login.
- No application redeployment or data migration is needed.
- When a module is disabled, its existing data is retained in the database but both UI and backend refuse access.
- When a module is re-enabled, the previously stored data becomes immediately accessible again.

#### 4.3.5 Default Module States for New Schools

- When a super admin creates a new school, they can set the initial module-enabled states.
- Default values are configurable in platform settings (e.g. all enabled by default, or all disabled).

### 4.4 Attendance Marking Rules

- One attendance record per student per day.
- Status options: Present, Absent, Late, Excused.
- Teachers can only mark attendance for the current date.
- Teachers can update attendance status before submitting.
- On submit, attendance records store the teacher's profile_id and a timestamp.
- If attendance has already been submitted for the day, teachers can view it but not edit.

### 4.5 SMS Notification Logic (Attendance)

- SMS is only triggered for students marked Absent or Late.
- Message includes the student's name and status.
- SMS is sent to the primary guardian's phone number.
- If no primary guardian exists, it is sent to the first guardian in student_guardians.
- If no guardian or no valid phone number exists, skip SMS for that student and mark as "SMS not sent."
- Notification is written to notifications_log with status "pending" and notification_type "attendance."
- A separate background worker processes pending notifications via the Termii API.
- notifications_log is updated to sent/failed with the provider response.

### 4.6 Fee Category Rules

- Amounts are stored in kobo (integer) to avoid floating-point currency errors; displayed as ₦ in the UI.
- Fee categories belong to a single school (scoped by school_id, enforced by RLS).
- Once a payment has been recorded against a fee category, its amount cannot be edited.
- Admins must deactivate the old category and create a new one to change the amount.

### 4.7 Fee Assignment Rules

- One assignment record per student per fee category (unique constraint).
- Assignments store the amount at the time of assignment.
- If a fee category amount is later changed on a new category, existing assignments are unaffected.
- Payment status is derived from the sum of payments recorded against that assignment.
- Assignments can only be removed if no payments have been recorded.

### 4.8 Payment Recording Rules

- Payment amount cannot exceed the outstanding balance for that assignment.
- Payments must store the logged-in admin's profile_id in recorded_by (audit trail).
- Payments cannot be deleted; they can only be voided with a reason (to maintain audit trail).
- Partial payments are allowed.
- Voided payments are excluded from balance calculations.

### 4.9 Outstanding Balance Calculation

- Outstanding balance = sum of (assigned amount − non-voided payments) for all active assignments where balance > 0.
- Calculated on read when the admin loads the dashboard.

### 4.10 SMS Notification Logic (Fee Reminders)

- Message format: "Dear [Parent Name], this is a reminder that [Student Name]'s [Fee Name] of ₦[Amount] is due on [Due Date]. Please contact [School Name] to make payment. Thank you."
- Reminder SMS is queued only when the guardian has a valid phone number.
- Rate limit: maximum one reminder per student per guardian per day.
- Notification written to notifications_log with notification_type "fee_reminder."
- If no valid guardian phone exists, flag on the Outstanding Balances screen; does not block bulk send.

### 4.11 Flagged Students Logic

- System automatically identifies students with 3 or more absences in the last 7 days.
- Calculated on read when the admin loads the dashboard.
- Admin can view flagged students on the dashboard.

### 4.12 Guardian–Student Relationship

- One student can have multiple guardians.
- One guardian can be linked to multiple students (siblings).
- Each student must have at least one guardian marked as primary contact.
- SMS notifications are sent to primary guardians only.

### 4.13 Teacher–Class Assignment

- One teacher is assigned to one class.
- One class can have only one teacher.
- Admins can reassign a teacher to a different class.

### 4.14 Subject Management Rules

- Subjects belong to a school (scoped by school_id).
- A subject can be assigned to multiple classes.
- A class can have multiple subjects.
- Subjects are not term-specific; they persist across terms.
- Scores are term-specific.

### 4.15 Grading Scale Rules

- Grading scale is school-wide (not per subject or class).
- Grading scale changes do not retroactively alter already-published results.

### 4.16 Term Management Rules

- Teachers can only enter scores for an active, unlocked term.
- Once locked, score entry is disabled for all teachers.
- Admin sees a read-only view when the term is locked.
- Locking a term triggers report card generation availability.
- Only one active term per school at a time.

### 4.17 Score Entry Rules

- CA max score is server-side enforced (default 40; configurable per school in term settings).
- Exam max score is server-side enforced (default 60).
- Total score = CA + Exam (always calculated, never manually entered).
- One score record per student per subject per term.
- Teachers can only enter scores for their assigned class.
- Grade and remark are auto-populated from the grading scale based on the total score.

### 4.18 Report Card Generation Rules

- Report cards can only be generated after the term is locked.
- Class rank = ranked by sum of all subjects' total scores (calculated via SQL RANK() window function; not stored).
- If two students have the same grand total, they share the same rank (RANK() handles ties).
- Outstanding fee balance shown on the report card is read-only information.
- Attendance data is automatically pulled from attendance_records within the term's date range.

### 4.19 SMS Notification Logic (Results)

- Message format: "Dear [Parent Name], [Student Name]'s results for [Term] [Year] are now available. Position: [X] of [Y] students. Average: [Z]%. Please visit the school to collect the report card. — [School Name]"
- Manually triggered by the admin clicking "Notify Parents" on the Report Card Generator page.
- Only triggered after the term is locked.
- One SMS per student sent to the primary guardian.
- Notification written to notifications_log with notification_type "results_notification."

### 4.20 Onboarding Tour Rules

- Tour auto-triggers on first login if has_seen_onboarding is false.
- Tour is role-specific: super_admin, admin, and teacher each have different steps.
- First step is always a welcome modal, followed by an interactive walkthrough.
- The walkthrough uses a focus/tooltip overlay style to highlight key UI areas.
- Progress indicator shows current step and total steps (e.g. Step 2 of 5).
- User can skip or dismiss the tour at any time via a Skip/Close button.
- On completion or dismissal, has_seen_onboarding in the profiles table is set to true.
- User can restart the tour at any time via the sidebar/header Help button.
- Restarted tour always begins from Step 1 regardless of prior completion.
- The tour overlay does not block underlying UI interaction (user can click through as needed).

### 4.21 SMS Analytics Rules

- All SMS metrics are aggregated from the existing notifications_log table.
- The cost per SMS message is a configurable platform setting (super admin sets the default).
- Estimated SMS allocation per school is calculated as: student count × expected messages per student per term.
- Expected messages per student per term is a configurable platform setting.
- Usage percentage = (total SMS sent this term / estimated allocation) × 100.
- Alert thresholds:
  + Yellow flag triggered at 75% usage.
  + Red flag triggered at 90% usage.
- Delivery success rate = (SMS with delivery_status = "delivered" / total SMS sent) × 100.
- Platform-level profit margin = revenue this term − total SMS cost this term.
- All metrics are scoped to each school's current active term.
- Super admin can select a past term to view historical data.

---

## 5. Database Schema

### 5.1 school_modules table (new)

```sql
create table school_modules (
  school_id uuid primary key references schools(id) on delete cascade,
  attendance_enabled boolean default true,
  fees_enabled boolean default true,
  results_enabled boolean default true,
  updated_at timestamptz default now()
);
```

### 5.2 profiles table (updated in v3.1)

```sql
alter table profiles add column has_seen_onboarding boolean default false;
```

### 5.3 subjects table

```sql
create table subjects (
  id uuid primary key default uuid_generate_v4(),
  school_id uuid not null references schools(id) on delete cascade,
  name text not null,
  code text,
  is_active boolean default true,
  created_at timestamptz default now()
);
```

### 5.4 class_subjects table

```sql
create table class_subjects (
  class_id uuid references classes(id) on delete cascade,
  subject_id uuid references subjects(id) on delete cascade,
  primary key (class_id, subject_id)
);
```

### 5.5 grading_scale table

```sql
create table grading_scale (
  id uuid primary key default uuid_generate_v4(),
  school_id uuid not null references schools(id) on delete cascade,
  min_score integer not null,
  max_score integer not null,
  grade text not null,
  remark text not null,
  created_at timestamptz default now()
);
```

### 5.6 terms table

```sql
create table terms (
  id uuid primary key default uuid_generate_v4(),
  school_id uuid not null references schools(id) on delete cascade,
  name text not null,
  academic_year text not null,
  start_date date not null,
  end_date date not null,
  is_active boolean default false,
  is_locked boolean default false,
  resumption_date date,
  ca_max_score integer default 40,
  exam_max_score integer default 60,
  created_at timestamptz default now()
);
```

### 5.7 score_records table

```sql
create table score_records (
  id uuid primary key default uuid_generate_v4(),
  school_id uuid not null references schools(id) on delete cascade,
  student_id uuid not null references students(id) on delete cascade,
  subject_id uuid not null references subjects(id) on delete cascade,
  term_id uuid not null references terms(id) on delete cascade,
  class_id uuid not null references classes(id) on delete cascade,
  ca_score integer,
  exam_score integer,
  total_score integer generated always as (coalesce(ca_score, 0) + coalesce(exam_score, 0)) stored,
  entered_by uuid not null references profiles(id),
  updated_at timestamptz default now(),
  unique (student_id, subject_id, term_id)
);
```

### 5.8 report_card_remarks table

```sql
create table report_card_remarks (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid not null references students(id) on delete cascade,
  term_id uuid not null references terms(id) on delete cascade,
  teacher_remark text,
  principal_remark text,
  updated_at timestamptz default now(),
  unique (student_id, term_id)
);
```

### 5.9 RLS Policy Examples (Module Access Control)

**attendance_records table:**

```sql
create policy \"Users can only access attendance if module enabled\"
  on attendance_records
  for all
  using (
    exists (
      select 1 from school_modules sm
      where sm.school_id = attendance_records.school_id
      and sm.attendance_enabled = true
    )
    and school_id = (select school_id from profiles where id = auth.uid())
  );
```

**fee_categories table:**

```sql
create policy \"Users can only access fees if module enabled\"
  on fee_categories
  for all
  using (
    exists (
      select 1 from school_modules sm
      where sm.school_id = fee_categories.school_id
      and sm.fees_enabled = true
    )
    and school_id = (select school_id from profiles where id = auth.uid())
  );
```

**score_records table:**

```sql
create policy \"Users can only access results if module enabled\"
  on score_records
  for all
  using (
    exists (
      select 1 from school_modules sm
      where sm.school_id = score_records.school_id
      and sm.results_enabled = true
    )
    and school_id = (select school_id from profiles where id = auth.uid())
  );
```

### 5.10 Rank Calculation Example

```sql
select
  s.full_name,
  s.admission_number,
  sum(sr.total_score) as grand_total,
  round(avg(sr.total_score), 1) as average,
  rank() over (order by sum(sr.total_score) desc) as position_in_class
from score_records sr
join students s on s.id = sr.student_id
where sr.class_id = $1 and sr.term_id = $2
group by s.id, s.full_name, s.admission_number
order by grand_total desc;
```

### 5.11 SMS Analytics Query Examples

**SMS usage per school for the current term:**

```sql
select
  s.id as school_id,
  s.name as school_name,
  count(nl.id) filter (where nl.notification_type = 'attendance') as attendance_sms,
  count(nl.id) filter (where nl.notification_type = 'fee_reminder') as fee_reminder_sms,
  count(nl.id) filter (where nl.notification_type = 'results_notification') as results_sms,
  count(nl.id) as total_sms,
  count(nl.id) filter (where nl.delivery_status = 'delivered') as delivered_sms,
  (count(nl.id)::float / nullif((select student_count from schools where id = s.id) * (select expected_messages_per_student from platform_settings), 0)) * 100 as usage_percentage
from schools s
left join notifications_log nl on nl.school_id = s.id and nl.created_at >= (select start_date from terms where school_id = s.id and is_active = true)
group by s.id, s.name;
```

**Platform-level SMS summary:**

```sql
select
  count(id) as total_sms_sent,
  count(id) filter (where delivery_status = 'delivered') as total_delivered,
  sum((select sms_cost_per_message from platform_settings)) as total_sms_cost
from notifications_log
where created_at >= (select min(start_date) from terms where is_active = true);
```

---

## 6. Report Card Print Layout

- School logo and name centred at the top, bold
- Thin border surrounding the entire card
- Student details section: name, class, term, year, admission number
- Scores table: Subject | CA | Exam | Total | Grade | Remark (alternating row shading)
- Summary box: Grand Total | Average | Class Position | Number of Subjects
- Attendance box: days school was open, days present, days absent (from v1 attendance_records)
- Fee status row: outstanding balance (from v2 student_fee_balances)
- Teacher remark in a handwriting-style font (Caveat from Google Fonts)
- Principal remark with signature line
- Next resumption date at the bottom
- Stamp placeholder box at bottom right
- Print stylesheet hides all navigation / buttons

---

## 7. Edge Cases & Error Handling

| Scenario | Handling |
|----------|----------|
| Teacher marks attendance but network fails before submit | Optimistic UI reverts, error message shown, retry allowed |
| Student has no linked guardian | Entire class attendance still saves; that student is flagged with a visible warning; SMS skipped for that student |
| Guardian phone number is invalid or missing | Attendance saves, student flagged, SMS skipped, admin prompted to fix the contact |
| SMS delivery fails (Termii API error) | Failure and provider response logged in notifications_log; manual retry allowed from Notifications Log |
| Teacher attempts to mark attendance for a past date | Action blocked; message shown: "Only today's date is allowed" |
| Admin attempts to delete a class with students | Deletion blocked; message shown: "Please transfer students first" |
| School subscription expired | Blocks admin and teacher login; message shown: "Please contact your super admin" |
| Student has multiple guardians with none marked primary | First guardian in the list is used for SMS |
| Teacher opens attendance page after today's submission | Read-only view of the submitted attendance is shown |
| Admin attempts to edit a fee amount after a payment is recorded | Edit blocked; message: "Deactivate this fee and create a new one" |
| Payment amount exceeds outstanding balance | Validation error blocks save |
| Bulk reminder SMS — some students have no guardian | Sends to those who have one; shows summary after: "X reminders sent, Y skipped (no guardian contact)" |
| Fee category deactivated mid-term | Existing assignments and payments are unaffected; no new assignments can be created against it |
| Admin attempts to delete a fee assignment with payments | Deletion blocked; void option offered |
| Student transfers class mid-term | Fee assignments follow the student (linked by student_id, not class_id) |
| Duplicate payment recorded accidentally | Admin can void with a reason; voided payments excluded from balance calculations |
| Teacher attempts to access Payment Recording page | Redirected to their read-only Class Fee Status page |
| Teacher attempts to enter scores for a locked term | Score fields disabled, read-only view shown; message: "This term has been locked by the admin." |
| Student has no scores for one or more subjects | That subject row shows "—" on the report card. Rank is calculated based on subjects with scores. |
| Two students tied on grand total | Both receive the same rank. Next rank is skipped accordingly (two tied at 3rd → next is 5th). |
| Admin locks term then finds a score needs correction | Admin can unlock, teacher corrects, admin re-locks. Unlock requires a confirmation step with a warning. |
| Attendance data missing for part of the term | Report card shows available data with a note: "Partial attendance data." Does not block card generation. |
| School has no grading scale configured | Score entry is allowed but grade/remark columns show "—" on report cards. Admin is prompted to configure the grading scale. |
| Student transfers in from another class mid-term | Scores entered under the old class are retained. Admin can manually enter remaining subject scores under the new class. |
| Print job fails or is interrupted | Each student's card is a separate page — partial printing still produces valid cards for the pages that printed. |
| Class has no subjects assigned | Score Entry page shows message: "No subjects assigned to this class. Please contact your admin." |
| User closes onboarding tour mid-way | has_seen_onboarding set to true; user can restart from the Help button |
| User clicks Skip on onboarding tour | has_seen_onboarding set to true; user can restart from the Help button |
| User restarts tour after completing it | Tour starts from Step 1 and shows all steps again |
| User clicks outside the focused area during tour | Tour continues; user can interact with the UI as needed |
| Tour is active and user navigates away | Tour pauses; resumes when user returns to the dashboard |
| School has no enrolled students | SMS analytics shows 0% usage; no alert flags triggered |
| School roster size doesn't match pricing tier | SMS analytics highlights the mismatch with a visual indicator; super admin can review |
| SMS delivery status not yet received from Termii | Pending messages are excluded from delivery success rate calculation |
| Super admin views SMS analytics for a school with no active term | Message shown: "No active term. Select a past term to view historical data." |
| Platform-level revenue data unavailable | Profit margin calculation shows "—" with note: "Revenue data not configured." |
| Super admin disables a module for a school | That school's admins and teachers see the related pages disappear from navigation on next refresh; backend rejects all data operations for that module |
| User attempts to directly access a disabled module via API | RLS policy rejects the request and returns a permission error |
| School has only the Attendance module enabled | Admin and teacher dashboards show only attendance-related pages; Fees and Results pages are completely hidden |
| School upgrades from one module to multiple | Super admin flips the toggle to enable the new module; that school's users see the new pages immediately on refresh — no migration needed |
| Existing data for a module that gets disabled | Data is retained in the database but both UI and backend refuse access; data becomes accessible again immediately when the module is re-enabled |

---

## 8. Acceptance Criteria

1. Teacher logs in and is redirected to the Mark Attendance page, showing today's assigned class roster.
2. Teacher taps Present for 15 students and Absent for 2; UI updates immediately on each tap.
3. Teacher clicks Submit; system saves all 17 attendance records and queues SMS notifications for the 2 absent students.
4. Admin logs in and creates a fee category "2025/2026 First Term School Fees" for ₦45,000 due 2026-10-31.
5. Admin bulk-assigns it to JSS1A (30 students) in one action.
6. Admin opens Payment Recording, searches "Ahmed Bello", and records a ₦20,000 partial payment by Cash.
7. Outstanding Balances page shows Ahmed Bello with ₦25,000 remaining.
8. Admin clicks "Send Reminder SMS" for Ahmed Bello; guardian receives: "Dear Mrs. Bello, this is a reminder that Ahmed Bello's 2025/2026 First Term School Fees of ₦45,000 is due on 31 October 2026. Please contact [School Name] to make payment. Thank you."
9. Admin creates subjects: Mathematics, English Language, Basic Science, Social Studies, Christian Religious Knowledge.
10. Admin assigns all five subjects to JSS1A.
11. Admin configures grading scale: A (75–100, Excellent) through F (0–39, Fail).
12. Admin creates "2025/2026 First Term" and sets it as active.
13. Teacher logs in, selects Mathematics, and enters CA and Exam scores for all 30 students — total and grade auto-calculate on each entry.
14. Teacher completes all five subjects — all show "Completed" status.
15. Admin locks the term.
16. Admin opens the Report Card Generator, selects JSS1A, and previews Ahmed Bello's card: scores table shows all five subjects with correct scores, grades, and remarks; position shows "3rd of 30 students"; attendance summary shows present/absent days from v1 data; outstanding balance shows the v2 amount.
17. Admin prints the entire class — 30 cards, one per page, clean layout with no UI chrome.
18. Admin clicks "Notify Parents" — 30 SMS are sent; guardians receive a results summary with position and average.
19. A new admin logs in for the first time with has_seen_onboarding false; the onboarding tour auto-triggers and shows the welcome modal.
20. Admin completes all 8 tour steps with focus highlights on Term Management, Class Management, Subject Management, Teacher Management, Student Management, Attendance Overview, and Report Card Generator.
21. Admin finishes the tour; has_seen_onboarding is set to true.
22. Admin clicks the Help button in the sidebar; the onboarding tour restarts from Step 1.
23. Super admin logs in and navigates to the SMS Analytics page.
24. SMS Analytics shows a table of all schools with columns: School Name, Total SMS this term (broken down by type), Estimated SMS Cost, Student Count, Usage % progress bar, Alert Flags (yellow at 75%, red at 90%), Delivery Success Rate.
25. Super admin clicks a school row to expand the detailed breakdown showing attendance alert, fee reminder, and results notification counts.
26. Platform-level summary section shows: total SMS sent this term across all schools, total estimated SMS cost, revenue this term, profit margin figure (revenue minus SMS cost), and ranked top-10 schools by SMS volume.
27. Super admin filters schools by alert status (Yellow/Red flags) to identify schools approaching their SMS allocation limit.
28. Super admin sorts schools by SMS volume; highest-usage school appears at the top.
29. SMS Analytics page shows a yellow flag for a school at 78% usage and a red flag for a school at 92% usage.
30. Super admin views a school's delivery success rate of 94.2%, indicating 94.2% of sent SMS were successfully delivered.
31. **Super admin opens a school's module configuration from the School Management page.**
32. **Super admin sees three module toggles: Attendance Module (enabled), Fees Module (enabled), Results Module (disabled).**
33. **Super admin flips the Results Module toggle to enabled; system shows confirmation: "Results module enabled for [School Name]."**
34. **That school's admin refreshes the page; Subject Management, Grading Scale, Term Management, Results Overview, and Report Card Generator pages appear in navigation immediately.**
35. **Super admin disables the Fees Module for a different school.**
36. **That school's admin refreshes the page; Fee Categories, Fee Assignments, Payment Recording, and Outstanding Balances pages disappear completely from navigation.**
37. **That school's teacher refreshes the page; the Class Fee Status page disappears from navigation.**
38. **That school's admin attempts to access the Fee Categories API directly via browser dev tools; backend returns a permission error and rejects the request.**
39. **Super admin creates a new test school and sets the initial module state to Attendance only.**
40. **The new school's admin logs in for the first time and sees only attendance-related pages; Fees and Results pages are not shown.**

---

## 9. Out of Scope for This Release

- Student login to view their own results
- Parent-facing online results portal
- Cumulative results across terms (running average across three terms)
- Progression / retention decisions (pass/fail to next class)
- Subject-teacher assignments (multiple teachers per class for different subjects)
- Bulk score import from Excel
- PDF generation (browser print introduced in v3.2 is sufficient)
- Results appeal or correction workflow
- National exam results (WAEC, NECO, JAMB)
- Online payment integration (Paystack, Flutterwave)
- Parent-facing fee portal or sending payment receipts directly to parents
- Automatic recurring fee generation (auto-create fees each term)
- Fee discounts or scholarship tracking
- Multi-currency
- Bulk payment record import from Excel
- Financial reports beyond outstanding balance export (P&L, term summary)
- Parent portal or parent login accounts
- Multi-class support for teachers
- Student or staff photo uploads
- Bulk student data import/export
- Email notifications (SMS only)
- Editing attendance history after submission
- Custom SMS message templates
- Integration with other school management systems
- Native mobile app (web only, mobile-responsive)
- Biometric attendance (fingerprint/facial recognition)
- Geofencing or location-based attendance verification
- Video tutorials or help documentation within the onboarding tour
- Per-school custom onboarding steps
- Onboarding completion rate analytics
- Multi-language support for the onboarding tour
- Automatic SMS allocation adjustment based on actual usage patterns
- SMS cost optimisation suggestions
- SMS usage predictive analytics
- Detailed SMS delivery failure analysis (beyond success-rate percentage)
- SMS provider comparison or multi-provider support
- Real-time SMS usage alerts pushed to super admin
- Historical SMS usage trend charts
- Per-school SMS budget configuration with enforcement
- Automatic billing adjustments based on SMS overage
- Dynamic pricing model based on actual usage (flagged only in this release, not built)
- Per-school custom module pricing configuration
- Module usage analytics and reporting
- Module access history log
- Bulk module configuration operations (setting modules for multiple schools at once)