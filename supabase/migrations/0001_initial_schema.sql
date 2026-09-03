create extension if not exists pgcrypto;

create table public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  contact_email text,
  contact_phone text,
  address text,
  logo_url text,
  subscription_status text not null default 'trial' check (subscription_status in ('trial', 'active', 'past_due', 'cancelled', 'expired')),
  subscription_plan text,
  trial_ends_at timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  school_id uuid references public.schools(id) on delete restrict,
  full_name text not null,
  role text not null check (role in ('super_admin', 'admin', 'teacher')),
  approval_status text not null default 'approved' check (approval_status in ('pending', 'approved', 'rejected', 'inactive')),
  has_seen_onboarding boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint super_admin_has_no_school check (role <> 'super_admin' or school_id is null),
  constraint school_user_has_school check (role = 'super_admin' or school_id is not null)
);

create table public.school_modules (
  school_id uuid primary key references public.schools(id) on delete cascade,
  attendance_enabled boolean not null default true,
  fees_enabled boolean not null default true,
  results_enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.classes (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null,
  grade_level text,
  assigned_teacher uuid references public.profiles(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (school_id, name),
  unique (assigned_teacher)
);

create table public.students (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  class_id uuid references public.classes(id) on delete set null,
  full_name text not null,
  admission_number text,
  date_of_birth date,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (school_id, admission_number)
);

create table public.guardians (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  full_name text not null,
  phone_number text,
  relationship text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.student_guardians (
  student_id uuid not null references public.students(id) on delete cascade,
  guardian_id uuid not null references public.guardians(id) on delete cascade,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (student_id, guardian_id)
);

create unique index one_primary_guardian_per_student on public.student_guardians(student_id) where is_primary;

create table public.attendance_records (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  class_id uuid not null references public.classes(id) on delete restrict,
  marked_by uuid not null references public.profiles(id) on delete restrict,
  attendance_date date not null,
  status text not null check (status in ('present', 'absent', 'late', 'excused')),
  submitted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, attendance_date)
);

create table public.fee_categories (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null,
  amount_kobo bigint not null check (amount_kobo >= 0),
  term text not null check (term in ('first', 'second', 'third')),
  academic_year text not null,
  due_date date not null,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.fee_assignments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete restrict,
  fee_category_id uuid not null references public.fee_categories(id) on delete restrict,
  amount_kobo bigint not null check (amount_kobo >= 0),
  created_at timestamptz not null default now(),
  unique (student_id, fee_category_id)
);

create table public.fee_payments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  fee_assignment_id uuid not null references public.fee_assignments(id) on delete restrict,
  amount_kobo bigint not null check (amount_kobo > 0),
  payment_date date not null default current_date,
  payment_method text not null check (payment_method in ('cash', 'bank_transfer', 'pos')),
  reference_number text,
  recorded_by uuid not null references public.profiles(id) on delete restrict,
  voided_at timestamptz,
  voided_by uuid references public.profiles(id) on delete restrict,
  void_reason text,
  created_at timestamptz not null default now(),
  constraint void_reason_required check (voided_at is null or nullif(trim(void_reason), '') is not null)
);

create table public.subjects (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null,
  code text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (school_id, name)
);

create table public.class_subjects (
  class_id uuid not null references public.classes(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  primary key (class_id, subject_id)
);

create table public.grading_scale (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  min_score integer not null check (min_score >= 0),
  max_score integer not null check (max_score <= 100),
  grade text not null,
  remark text not null,
  created_at timestamptz not null default now(),
  constraint valid_score_range check (min_score <= max_score)
);

create table public.terms (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null,
  academic_year text not null,
  start_date date not null,
  end_date date not null,
  is_active boolean not null default false,
  is_locked boolean not null default false,
  resumption_date date,
  ca_max_score integer not null default 40 check (ca_max_score > 0),
  exam_max_score integer not null default 60 check (exam_max_score > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint valid_term_dates check (start_date <= end_date)
);

create unique index one_active_term_per_school on public.terms(school_id) where is_active;

create table public.score_records (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete restrict,
  term_id uuid not null references public.terms(id) on delete restrict,
  class_id uuid not null references public.classes(id) on delete restrict,
  ca_score integer check (ca_score >= 0),
  exam_score integer check (exam_score >= 0),
  total_score integer generated always as (coalesce(ca_score, 0) + coalesce(exam_score, 0)) stored,
  entered_by uuid not null references public.profiles(id) on delete restrict,
  updated_at timestamptz not null default now(),
  unique (student_id, subject_id, term_id)
);

create table public.report_card_remarks (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  term_id uuid not null references public.terms(id) on delete restrict,
  teacher_remark text,
  principal_remark text,
  updated_at timestamptz not null default now(),
  unique (student_id, term_id)
);

create table public.platform_settings (
  id boolean primary key default true check (id),
  sms_cost_kobo bigint not null default 0 check (sms_cost_kobo >= 0),
  expected_messages_per_student integer not null default 0 check (expected_messages_per_student >= 0),
  revenue_per_school_kobo bigint check (revenue_per_school_kobo >= 0),
  updated_at timestamptz not null default now()
);

insert into public.platform_settings (id) values (true) on conflict (id) do nothing;

create table public.notifications_log (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid references public.students(id) on delete set null,
  guardian_id uuid references public.guardians(id) on delete set null,
  notification_type text not null check (notification_type in ('attendance', 'fee_reminder', 'results_notification')),
  phone_number text not null,
  message text not null,
  status text not null default 'pending' check (status in ('pending', 'sent', 'failed')),
  delivery_status text check (delivery_status in ('pending', 'delivered', 'failed', 'unknown')),
  provider_response jsonb,
  retry_count integer not null default 0 check (retry_count >= 0),
  last_attempted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid not null references public.profiles(id) on delete restrict,
  actor_role text not null check (actor_role in ('super_admin', 'admin', 'teacher')),
  school_id uuid references public.schools(id) on delete set null,
  action_type text not null,
  target_type text not null,
  target_id uuid,
  before_state jsonb,
  after_state jsonb,
  created_at timestamptz not null default now()
);

create index schools_active_idx on public.schools(is_active);
create index profiles_school_role_idx on public.profiles(school_id, role);
create index classes_school_idx on public.classes(school_id);
create index students_school_class_idx on public.students(school_id, class_id);
create index guardians_school_idx on public.guardians(school_id);
create index attendance_school_date_idx on public.attendance_records(school_id, attendance_date);
create index fee_categories_school_idx on public.fee_categories(school_id, is_active);
create index fee_assignments_school_idx on public.fee_assignments(school_id, student_id);
create index fee_payments_school_idx on public.fee_payments(school_id, payment_date);
create index subjects_school_idx on public.subjects(school_id, is_active);
create index grading_scale_school_idx on public.grading_scale(school_id, min_score);
create index terms_school_active_idx on public.terms(school_id, is_active);
create index scores_school_term_class_idx on public.score_records(school_id, term_id, class_id);
create index notifications_school_type_created_idx on public.notifications_log(school_id, notification_type, created_at);
create index notifications_status_idx on public.notifications_log(status, delivery_status);
create index audit_school_created_idx on public.audit_log(school_id, created_at desc);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array['schools', 'profiles', 'school_modules', 'classes', 'students', 'guardians', 'attendance_records', 'fee_categories', 'fee_payments', 'subjects', 'terms', 'score_records', 'report_card_remarks', 'platform_settings', 'notifications_log'] loop
    execute format('create trigger %I_touch_updated_at before update on public.%I for each row execute function public.touch_updated_at()', table_name, table_name);
  end loop;
end;
$$;

create or replace function public.current_profile_school_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select school_id from public.profiles where id = auth.uid() and approval_status = 'approved';
$$;

create or replace function public.current_profile_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid() and approval_status = 'approved';
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_profile_role() = 'super_admin', false);
$$;

create or replace function public.is_school_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_profile_role() = 'admin', false);
$$;

create or replace function public.current_teacher_class_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id from public.classes where assigned_teacher = auth.uid() and school_id = public.current_profile_school_id() limit 1;
$$;

create or replace function public.module_enabled(target_school_id uuid, module_name text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select case module_name
    when 'attendance' then coalesce(attendance_enabled, false)
    when 'fees' then coalesce(fees_enabled, false)
    when 'results' then coalesce(results_enabled, false)
    else false
  end
  from public.school_modules where school_id = target_school_id;
$$;

create or replace function public.validate_score_record()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  term_row public.terms%rowtype;
begin
  select * into term_row from public.terms where id = new.term_id and school_id = new.school_id;
  if not found then raise exception 'Term does not belong to this school'; end if;
  if term_row.is_locked then raise exception 'This term has been locked'; end if;
  if new.ca_score is not null and new.ca_score > term_row.ca_max_score then raise exception 'CA score exceeds the term maximum'; end if;
  if new.exam_score is not null and new.exam_score > term_row.exam_max_score then raise exception 'Exam score exceeds the term maximum'; end if;
  return new;
end;
$$;

create trigger validate_score_before_write before insert or update on public.score_records for each row execute function public.validate_score_record();

create or replace function public.record_audit_event(
  event_action text,
  event_target_type text,
  event_target_id uuid,
  event_school_id uuid,
  event_before jsonb default null,
  event_after jsonb default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  new_id bigint;
begin
  if public.current_profile_role() is null then raise exception 'Authenticated profile required'; end if;
  insert into public.audit_log(actor_id, actor_role, school_id, action_type, target_type, target_id, before_state, after_state)
  values (auth.uid(), public.current_profile_role(), event_school_id, event_action, event_target_type, event_target_id, event_before, event_after)
  returning id into new_id;
  return new_id;
end;
$$;

revoke all on function public.record_audit_event(text, text, uuid, uuid, jsonb, jsonb) from public;
grant execute on function public.record_audit_event(text, text, uuid, uuid, jsonb, jsonb) to authenticated;

create or replace function public.find_schools(search_query text)
returns table (id uuid, name text, slug text)
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_query text := nullif(trim(search_query), '');
begin
  if normalized_query is null or char_length(normalized_query) < 2 then return; end if;
  return query
    select s.id, s.name, s.slug
    from public.schools s
    where s.is_active
      and (s.name ilike '%' || normalized_query || '%' or s.slug ilike '%' || normalized_query || '%')
    order by s.name
    limit 10;
end;
$$;

revoke all on function public.find_schools(text) from public;
grant execute on function public.find_schools(text) to anon, authenticated;

alter table public.schools enable row level security;
alter table public.profiles enable row level security;
alter table public.school_modules enable row level security;
alter table public.classes enable row level security;
alter table public.students enable row level security;
alter table public.guardians enable row level security;
alter table public.student_guardians enable row level security;
alter table public.attendance_records enable row level security;
alter table public.fee_categories enable row level security;
alter table public.fee_assignments enable row level security;
alter table public.fee_payments enable row level security;
alter table public.subjects enable row level security;
alter table public.class_subjects enable row level security;
alter table public.grading_scale enable row level security;
alter table public.terms enable row level security;
alter table public.score_records enable row level security;
alter table public.report_card_remarks enable row level security;
alter table public.platform_settings enable row level security;
alter table public.notifications_log enable row level security;
alter table public.audit_log enable row level security;

create policy schools_select on public.schools for select to authenticated using (public.is_super_admin() or id = public.current_profile_school_id());
create policy schools_manage on public.schools for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());

create policy profiles_select on public.profiles for select to authenticated using (public.is_super_admin() or id = auth.uid() or school_id = public.current_profile_school_id());
create policy profiles_self_update_onboarding on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid() and role = public.current_profile_role() and school_id = public.current_profile_school_id());

create policy modules_select on public.school_modules for select to authenticated using (public.is_super_admin() or school_id = public.current_profile_school_id());
create policy modules_manage on public.school_modules for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());

create policy classes_select on public.classes for select to authenticated using (public.is_super_admin() or school_id = public.current_profile_school_id());
create policy classes_admin_manage on public.classes for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id())) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id()));

create policy students_select on public.students for select to authenticated using (public.is_super_admin() or (school_id = public.current_profile_school_id() and (public.is_school_admin() or class_id = public.current_teacher_class_id())));
create policy students_admin_manage on public.students for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id())) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id()));

create policy guardians_admin_access on public.guardians for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id())) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id()));
create policy student_guardians_admin_access on public.student_guardians for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and exists (select 1 from public.students s where s.id = student_id and s.school_id = public.current_profile_school_id()))) with check (public.is_super_admin() or (public.is_school_admin() and exists (select 1 from public.students s where s.id = student_id and s.school_id = public.current_profile_school_id())));

create policy attendance_select on public.attendance_records for select to authenticated using (public.is_super_admin() or (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'attendance') and (public.is_school_admin() or class_id = public.current_teacher_class_id())));
create policy attendance_teacher_write on public.attendance_records for insert to authenticated with check (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'attendance') and public.current_profile_role() = 'teacher' and class_id = public.current_teacher_class_id() and attendance_date = current_date and marked_by = auth.uid());
create policy attendance_admin_write on public.attendance_records for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'attendance'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'attendance')));

create policy fees_admin_categories on public.fee_categories for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'fees'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'fees')));
create policy fees_admin_assignments on public.fee_assignments for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'fees'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'fees')));
create policy fees_admin_payments on public.fee_payments for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'fees'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'fees')));

create policy subjects_access on public.subjects for select to authenticated using (public.is_super_admin() or (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results')));
create policy subjects_admin_manage on public.subjects for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results')));
create policy class_subjects_access on public.class_subjects for select to authenticated using (public.is_super_admin() or exists (select 1 from public.classes c join public.subjects s on s.id = subject_id where c.id = class_id and c.school_id = public.current_profile_school_id() and public.module_enabled(c.school_id, 'results')));
create policy class_subjects_admin_manage on public.class_subjects for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and exists (select 1 from public.classes c where c.id = class_id and c.school_id = public.current_profile_school_id()))) with check (public.is_super_admin() or (public.is_school_admin() and exists (select 1 from public.classes c join public.subjects s on s.id = subject_id where c.id = class_id and s.school_id = public.current_profile_school_id() and public.module_enabled(c.school_id, 'results'))));
create policy grading_scale_admin on public.grading_scale for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results')));
create policy terms_access on public.terms for select to authenticated using (public.is_super_admin() or (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results')));
create policy terms_admin_manage on public.terms for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results')));
create policy scores_access on public.score_records for select to authenticated using (public.is_super_admin() or (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results') and (public.is_school_admin() or class_id = public.current_teacher_class_id())));
create policy scores_teacher_write on public.score_records for insert to authenticated with check (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results') and public.current_profile_role() = 'teacher' and class_id = public.current_teacher_class_id() and entered_by = auth.uid());
create policy scores_teacher_update on public.score_records for update to authenticated using (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results') and public.current_profile_role() = 'teacher' and class_id = public.current_teacher_class_id()) with check (school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results') and public.current_profile_role() = 'teacher' and class_id = public.current_teacher_class_id());
create policy scores_admin_manage on public.score_records for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results')));
create policy remarks_admin on public.report_card_remarks for all to authenticated using (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results'))) with check (public.is_super_admin() or (public.is_school_admin() and school_id = public.current_profile_school_id() and public.module_enabled(school_id, 'results')));

create policy platform_settings_super_admin on public.platform_settings for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy notifications_super_admin on public.notifications_log for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy audit_select on public.audit_log for select to authenticated using (public.is_super_admin() or school_id = public.current_profile_school_id());

revoke insert, update, delete on public.audit_log from anon, authenticated;
revoke all on public.platform_settings from anon, authenticated;

create view public.class_score_rankings with (security_invoker = true) as
select sr.school_id, sr.class_id, sr.term_id, s.full_name, s.admission_number,
  sum(sr.total_score) as grand_total,
  round(avg(sr.total_score)::numeric, 1) as average,
  rank() over (partition by sr.class_id, sr.term_id order by sum(sr.total_score) desc) as position_in_class
from public.score_records sr
join public.students s on s.id = sr.student_id
group by sr.school_id, sr.class_id, sr.term_id, s.id, s.full_name, s.admission_number;

create view public.sms_school_analytics with (security_invoker = true) as
select s.id as school_id, s.name as school_name,
  count(distinct n.id) filter (where n.notification_type = 'attendance' and n.status = 'sent') as attendance_sms,
  count(distinct n.id) filter (where n.notification_type = 'fee_reminder' and n.status = 'sent') as fee_reminder_sms,
  count(distinct n.id) filter (where n.notification_type = 'results_notification' and n.status = 'sent') as results_sms,
  count(distinct n.id) filter (where n.status = 'sent') as total_sms,
  count(distinct n.id) filter (where n.status = 'sent' and n.delivery_status = 'delivered') as delivered_sms,
  count(distinct st.id) as student_count,
  count(distinct n.id) filter (where n.status = 'sent') * p.sms_cost_kobo as estimated_cost_kobo,
  round((count(distinct n.id) filter (where n.status = 'sent')::numeric / nullif(count(distinct st.id) * p.expected_messages_per_student, 0)) * 100, 1) as usage_percentage,
  case
    when count(distinct st.id) * p.expected_messages_per_student = 0 then 'none'
    when (count(distinct n.id) filter (where n.status = 'sent')::numeric / nullif(count(distinct st.id) * p.expected_messages_per_student, 0)) * 100 >= 90 then 'red'
    when (count(distinct n.id) filter (where n.status = 'sent')::numeric / nullif(count(distinct st.id) * p.expected_messages_per_student, 0)) * 100 >= 75 then 'yellow'
    else 'normal'
  end as alert_status,
  round((count(distinct n.id) filter (where n.status = 'sent' and n.delivery_status = 'delivered')::numeric / nullif(count(distinct n.id) filter (where n.status = 'sent' and coalesce(n.delivery_status, 'unknown') <> 'pending'), 0)) * 100, 1) as delivery_success_percentage
from public.schools s
cross join public.platform_settings p
left join public.terms t on t.school_id = s.id and t.is_active
left join public.notifications_log n on n.school_id = s.id and t.id is not null and n.created_at >= t.start_date and n.created_at < (t.end_date + 1)
left join public.students st on st.school_id = s.id and st.is_active
group by s.id, s.name, p.sms_cost_kobo, p.expected_messages_per_student;