-- CIVILLINE SAFE MIGRATION - run on existing database
create extension if not exists pgcrypto;

alter table public.client_bills add column if not exists bill_path text;
alter table public.client_bills add column if not exists created_at timestamptz default now();

create table if not exists public.client_ledger(
 id uuid primary key default gen_random_uuid(),user_id uuid not null references public.profiles(id) on delete cascade,
 client_name text not null,project_id uuid references public.projects(id) on delete set null,date date not null default current_date,
 entry_type text not null check(entry_type in('bill','payment','adjustment')),reference_no text,description text,
 debit numeric(14,2) not null default 0,credit numeric(14,2) not null default 0,created_at timestamptz not null default now());

create table if not exists public.labour_contractors(
 id uuid primary key default gen_random_uuid(),user_id uuid not null references public.profiles(id) on delete cascade,
 name text not null,mobile text,work_type text,created_at timestamptz not null default now());

create table if not exists public.labour_ledger(
 id uuid primary key default gen_random_uuid(),user_id uuid not null references public.profiles(id) on delete cascade,
 contractor_id uuid references public.labour_contractors(id) on delete set null,contractor_name text not null,
 project_id uuid references public.projects(id) on delete set null,date date not null default current_date,
 entry_type text not null check(entry_type in('bill','payment','adjustment')),reference_no text,description text,
 debit numeric(14,2) not null default 0,credit numeric(14,2) not null default 0,created_at timestamptz not null default now());

alter table public.client_ledger enable row level security;
alter table public.labour_contractors enable row level security;
alter table public.labour_ledger enable row level security;

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from public.profiles where id=auth.uid() and role='admin');$$;

drop policy if exists client_ledger_select on public.client_ledger; create policy client_ledger_select on public.client_ledger for select to authenticated using(user_id=auth.uid() or public.is_admin());
drop policy if exists client_ledger_insert on public.client_ledger; create policy client_ledger_insert on public.client_ledger for insert to authenticated with check(user_id=auth.uid() or public.is_admin());
drop policy if exists client_ledger_update on public.client_ledger; create policy client_ledger_update on public.client_ledger for update to authenticated using(user_id=auth.uid() or public.is_admin()) with check(user_id=auth.uid() or public.is_admin());
drop policy if exists client_ledger_delete on public.client_ledger; create policy client_ledger_delete on public.client_ledger for delete to authenticated using(user_id=auth.uid() or public.is_admin());

drop policy if exists labour_contractors_select on public.labour_contractors; create policy labour_contractors_select on public.labour_contractors for select to authenticated using(user_id=auth.uid() or public.is_admin());
drop policy if exists labour_contractors_insert on public.labour_contractors; create policy labour_contractors_insert on public.labour_contractors for insert to authenticated with check(user_id=auth.uid() or public.is_admin());
drop policy if exists labour_contractors_update on public.labour_contractors; create policy labour_contractors_update on public.labour_contractors for update to authenticated using(user_id=auth.uid() or public.is_admin()) with check(user_id=auth.uid() or public.is_admin());
drop policy if exists labour_contractors_delete on public.labour_contractors; create policy labour_contractors_delete on public.labour_contractors for delete to authenticated using(user_id=auth.uid() or public.is_admin());

drop policy if exists labour_ledger_select on public.labour_ledger; create policy labour_ledger_select on public.labour_ledger for select to authenticated using(user_id=auth.uid() or public.is_admin());
drop policy if exists labour_ledger_insert on public.labour_ledger; create policy labour_ledger_insert on public.labour_ledger for insert to authenticated with check(user_id=auth.uid() or public.is_admin());
drop policy if exists labour_ledger_update on public.labour_ledger; create policy labour_ledger_update on public.labour_ledger for update to authenticated using(user_id=auth.uid() or public.is_admin()) with check(user_id=auth.uid() or public.is_admin());
drop policy if exists labour_ledger_delete on public.labour_ledger; create policy labour_ledger_delete on public.labour_ledger for delete to authenticated using(user_id=auth.uid() or public.is_admin());

insert into storage.buckets(id,name,public) values('contractor-bills','contractor-bills',false) on conflict(id) do update set public=false;

drop policy if exists bill_upload_own_folder on storage.objects;
create policy bill_upload_own_folder on storage.objects for insert to authenticated with check(bucket_id='contractor-bills' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists bill_read_own_or_admin on storage.objects;
create policy bill_read_own_or_admin on storage.objects for select to authenticated using(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()));
drop policy if exists bill_update_own_or_admin on storage.objects;
create policy bill_update_own_or_admin on storage.objects for update to authenticated using(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin())) with check(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()));
drop policy if exists bill_delete_own_or_admin on storage.objects;
create policy bill_delete_own_or_admin on storage.objects for delete to authenticated using(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()));

create index if not exists idx_client_ledger_user_date on public.client_ledger(user_id,date);
create index if not exists idx_labour_ledger_user_date on public.labour_ledger(user_id,date);
create index if not exists idx_labour_contractors_user on public.labour_contractors(user_id);
