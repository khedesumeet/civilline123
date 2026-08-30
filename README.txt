CIVILLINE IMPROVED VERSION

Files:
index.html
admin-login.html
admin.html
contractor-login.html
forgot-password.html
reset-password.html
dashboard.html
projects.html
expenses.html
client-bills.html
statements.html
common.css
app.js
supabase-migration.sql

SETUP
1. Upload all HTML/CSS/JS files to GitHub Pages.
2. In Supabase SQL Editor, run ONLY supabase-migration.sql on an existing project.
3. Do NOT run an old SQL file containing DROP TABLE statements.
4. Keep the Supabase publishable key in browser code; never put service-role key in HTML/GitHub.
5. The existing create-contractor Edge Function must remain deployed for Admin contractor creation.
6. Add your GitHub Pages URL + /reset-password.html to Supabase Authentication > URL Configuration > Redirect URLs.

LOGIN
Admin: Admin Login -> email + password.
Contractor: Contractor Login -> email + password.
Forgot Password sends a Supabase secure reset link.

CLIENT BILL PDF
Client Bills accepts PDF/JPG/PNG/WebP up to 10 MB and stores the file privately in contractor-bills under the logged-in contractor's folder.

STATEMENTS
Client Statement: Bill = Debit, Payment = Credit.
Labour Statement: Labour Bill = Payable/Debit, Payment = Credit.
Expense Summary: project/vendor/category/amount/GST/total.

SECURITY
RLS restricts contractor data by user_id. Storage files are private. Do not expose the Supabase service-role key.
