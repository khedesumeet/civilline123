-- CIVILLINE: ADMIN-ONLY CONTRACTOR CREATION
-- WARNING: this recreates the application tables and deletes existing rows.

create extension if not exists pgcrypto;

drop table if exists public.client_bills cascade;
drop table if exists public.expenses cascade;
drop table if exists public.projects cascade;
drop table if exists public.profiles cascade;

create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 company_name text not null,
 owner_name text not null,
 mobile text not null,
 whatsapp text,
 email text,
 city text not null,
 area text,
 address text,
 services text[] default '{}',
 role text not null default 'contractor' check(role in ('contractor','admin')),
 status text not null default 'pending' check(status in ('pending','approved','rejected','suspended')),
 is_featured boolean not null default false,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table public.projects (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 name text not null,
 client_name text,
 location text,
 contract_amount numeric(14,2) not null default 0,
 start_date date,
 end_date date,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table public.expenses (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 project_id uuid references public.projects(id) on delete set null,
 date date not null default current_date,
 category text not null,
 vendor text,
 bill_number text,
 gst_included boolean not null default true,
 gst_percent numeric(5,2) not null default 18,
 amount numeric(14,2) not null default 0,
 total numeric(14,2) not null default 0,
 bill_path text,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table public.client_bills (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 project_id uuid references public.projects(id) on delete set null,
 bill_number text,
 date date not null default current_date,
 amount numeric(14,2) not null default 0,
 created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.expenses enable row level security;
alter table public.client_bills enable row level security;

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path=public
as $$
 select exists(select 1 from public.profiles where id=auth.uid() and role='admin');
$$;

-- IMPORTANT: There is intentionally NO public/contractor INSERT policy on profiles.
-- Only the Edge Function (service role) creates contractor profiles.

create policy "profiles_select_own_or_admin"
on public.profiles for select to authenticated
using(id=auth.uid() or public.is_admin());

create policy "profiles_update_own_or_admin"
on public.profiles for update to authenticated
using(id=auth.uid() or public.is_admin())
with check(id=auth.uid() or public.is_admin());

create policy "profiles_delete_admin"
on public.profiles for delete to authenticated
using(public.is_admin());

create policy "projects_select_own_or_admin"
on public.projects for select to authenticated
using(user_id=auth.uid() or public.is_admin());

create policy "projects_insert_own_or_admin"
on public.projects for insert to authenticated
with check(user_id=auth.uid() or public.is_admin());

create policy "projects_update_own_or_admin"
on public.projects for update to authenticated
using(user_id=auth.uid() or public.is_admin())
with check(user_id=auth.uid() or public.is_admin());

create policy "projects_delete_own_or_admin"
on public.projects for delete to authenticated
using(user_id=auth.uid() or public.is_admin());

create policy "expenses_select_own_or_admin"
on public.expenses for select to authenticated
using(user_id=auth.uid() or public.is_admin());

create policy "expenses_insert_own_or_admin"
on public.expenses for insert to authenticated
with check(user_id=auth.uid() or public.is_admin());

create policy "expenses_update_own_or_admin"
on public.expenses for update to authenticated
using(user_id=auth.uid() or public.is_admin())
with check(user_id=auth.uid() or public.is_admin());

create policy "expenses_delete_own_or_admin"
on public.expenses for delete to authenticated
using(user_id=auth.uid() or public.is_admin());

create policy "client_bills_select_own_or_admin"
on public.client_bills for select to authenticated
using(user_id=auth.uid() or public.is_admin());

create policy "client_bills_insert_own_or_admin"
on public.client_bills for insert to authenticated
with check(user_id=auth.uid() or public.is_admin());

create policy "client_bills_update_own_or_admin"
on public.client_bills for update to authenticated
using(user_id=auth.uid() or public.is_admin())
with check(user_id=auth.uid() or public.is_admin());

create policy "client_bills_delete_own_or_admin"
on public.client_bills for delete to authenticated
using(user_id=auth.uid() or public.is_admin());

insert into storage.buckets(id,name,public)
values('contractor-bills','contractor-bills',false)
on conflict(id) do update set public=false;

create policy "bill_upload_own_folder"
on storage.objects for insert to authenticated
with check(bucket_id='contractor-bills' and (storage.foldername(name))[1]=auth.uid()::text);

create policy "bill_read_own_or_admin"
on storage.objects for select to authenticated
using(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()));

create policy "bill_update_own_or_admin"
on storage.objects for update to authenticated
using(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()))
with check(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()));

create policy "bill_delete_own_or_admin"
on storage.objects for delete to authenticated
using(bucket_id='contractor-bills' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()));

-- After you create your first Auth account manually, promote it to admin:
-- update public.profiles set role='admin', status='approved' where email='YOUR_ADMIN_EMAIL';
