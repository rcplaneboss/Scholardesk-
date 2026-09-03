begin;

insert into public.schools (
  id, name, slug, contact_email, contact_phone, address,
  subscription_status, subscription_plan, trial_ends_at, is_active
)
values
  ('11111111-1111-4111-8111-111111111111', 'ScholarDesk Demo Academy', 'scholardesk-demo', 'demo@scholardesk.invalid', '+2340000000000', 'Test address only', 'trial', 'all-modules', '2030-12-31T23:59:59Z', true),
  ('22222222-2222-4222-8222-222222222222', 'ScholarDesk Boundary School', 'boundary-school', 'boundary@scholardesk.invalid', '+2340000000001', 'Cross-tenant test address only', 'trial', 'attendance-only', '2030-12-31T23:59:59Z', true)
on conflict (id) do nothing;

insert into public.school_modules (school_id, attendance_enabled, fees_enabled, results_enabled)
values
  ('11111111-1111-4111-8111-111111111111', true, true, true),
  ('22222222-2222-4222-8222-222222222222', true, false, false)
on conflict (school_id) do nothing;

insert into public.classes (id, school_id, name, grade_level, is_active)
values ('31111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'JSS1A', 'JSS 1', true)
on conflict (id) do nothing;

insert into public.students (id, school_id, class_id, full_name, admission_number, date_of_birth, is_active)
values
  ('41111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', '31111111-1111-4111-8111-111111111111', 'Demo Student One', 'DEMO-001', '2012-05-14', true),
  ('42222222-2222-4222-8222-222222222222', '11111111-1111-4111-8111-111111111111', '31111111-1111-4111-8111-111111111111', 'Demo Student Two', 'DEMO-002', '2012-08-21', true),
  ('43333333-3333-4333-8333-333333333333', '11111111-1111-4111-8111-111111111111', '31111111-1111-4111-8111-111111111111', 'Demo Student Three', 'DEMO-003', '2013-01-09', true)
on conflict (id) do nothing;

insert into public.guardians (id, school_id, full_name, phone_number, relationship)
values
  ('51111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'Demo Guardian One', '+2340000000010', 'Parent'),
  ('52222222-2222-4222-8222-222222222222', '11111111-1111-4111-8111-111111111111', 'Demo Guardian Two', '+2340000000011', 'Guardian')
on conflict (id) do nothing;

insert into public.student_guardians (student_id, guardian_id, is_primary)
values
  ('41111111-1111-4111-8111-111111111111', '51111111-1111-4111-8111-111111111111', true),
  ('42222222-2222-4222-8222-222222222222', '52222222-2222-4222-8222-222222222222', true),
  ('43333333-3333-4333-8333-333333333333', '51111111-1111-4111-8111-111111111111', true)
on conflict (student_id, guardian_id) do nothing;

insert into public.terms (id, school_id, name, academic_year, start_date, end_date, is_active, is_locked, resumption_date, ca_max_score, exam_max_score)
values ('61111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'First Term', '2026/2027', '2026-09-01', '2026-12-18', true, false, '2027-01-11', 40, 60)
on conflict (id) do nothing;

insert into public.subjects (id, school_id, name, code, is_active)
values
  ('71111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'Mathematics', 'MATH', true),
  ('72222222-2222-4222-8222-222222222222', '11111111-1111-4111-8111-111111111111', 'English Language', 'ENG', true),
  ('73333333-3333-4333-8333-333333333333', '11111111-1111-4111-8111-111111111111', 'Basic Science', 'BSC', true)
on conflict (id) do nothing;

insert into public.class_subjects (class_id, subject_id)
values
  ('31111111-1111-4111-8111-111111111111', '71111111-1111-4111-8111-111111111111'),
  ('31111111-1111-4111-8111-111111111111', '72222222-2222-4222-8222-222222222222'),
  ('31111111-1111-4111-8111-111111111111', '73333333-3333-4333-8333-333333333333')
on conflict (class_id, subject_id) do nothing;

insert into public.grading_scale (id, school_id, min_score, max_score, grade, remark)
values
  ('81111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 0, 39, 'F', 'Fail'),
  ('82222222-2222-4222-8222-222222222222', '11111111-1111-4111-8111-111111111111', 40, 49, 'E', 'Pass'),
  ('83333333-3333-4333-8333-333333333333', '11111111-1111-4111-8111-111111111111', 50, 59, 'D', 'Average'),
  ('84444444-4444-4444-8444-444444444444', '11111111-1111-4111-8111-111111111111', 60, 69, 'C', 'Good'),
  ('85555555-5555-4555-8555-555555555555', '11111111-1111-4111-8111-111111111111', 70, 74, 'B', 'Very good'),
  ('86666666-6666-4666-8666-666666666666', '11111111-1111-4111-8111-111111111111', 75, 100, 'A', 'Excellent')
on conflict (id) do nothing;

insert into public.fee_categories (id, school_id, name, amount_kobo, term, academic_year, due_date, description, is_active)
values ('91111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'Demo First Term School Fees', 4500000, 'first', '2026/2027', '2026-10-31', 'Test-only fee category', true)
on conflict (id) do nothing;

insert into public.fee_assignments (id, school_id, student_id, fee_category_id, amount_kobo)
values
  ('a1111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', '41111111-1111-4111-8111-111111111111', '91111111-1111-4111-8111-111111111111', 4500000),
  ('a2222222-2222-4222-8222-222222222222', '11111111-1111-4111-8111-111111111111', '42222222-2222-4222-8222-222222222222', '91111111-1111-4111-8111-111111111111', 4500000),
  ('a3333333-3333-4333-8333-333333333333', '11111111-1111-4111-8111-111111111111', '43333333-3333-4333-8333-333333333333', '91111111-1111-4111-8111-111111111111', 4500000)
on conflict (id) do nothing;

commit;