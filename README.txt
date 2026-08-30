CIVILLINE - ADMIN ONLY CONTRACTOR MANAGEMENT

Supabase:
https://aoicywtjwvqzzhmxkxvs.supabase.co

Frontend publishable key:
sb_publishable_8oZE-6157A8F7sRZEWCrhw_8OQ4yz0W

IMPORTANT:
1. There is NO public contractor registration.
2. Admin creates every contractor account.
3. The service-role key is used ONLY inside the Supabase Edge Function.
4. NEVER put SUPABASE_SERVICE_ROLE_KEY into HTML, GitHub, or browser JavaScript.

SETUP

A. Run supabase.sql in Supabase SQL Editor.

B. Create your FIRST admin Auth account:
   Supabase Dashboard -> Authentication -> Users -> Add user

   Create your admin email and password.

C. That first account needs a profile row because RLS requires it.
   Run:

   insert into public.profiles
   (id, company_name, owner_name, mobile, email, city, role, status)
   select
     id,
     'CivilLine Admin',
     'Administrator',
     '0000000000',
     email,
     'Admin',
     'admin',
     'approved'
   from auth.users
   where email = 'YOUR_ADMIN_EMAIL';

D. Deploy the Edge Function:

   supabase functions deploy create-contractor

   Make sure the Edge Function has the standard Supabase
   SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY secrets available.

E. Open admin-login.html and log in.

F. Admin can now create contractor accounts from admin.html.

Contractor:
- Cannot register themselves.
- Admin-created account only.
- Contractor must be approved.
- Contractor can manage only their own projects, expenses and client bills.
- Bills are stored privately in contractor-bills storage.
- Forgot password opens WhatsApp: 9975304937.

If you use GitHub Pages, upload the HTML files only. Do NOT upload the service-role key.
