const SB_URL='https://aoicywtjwvqzzhmxkxvs.supabase.co';const SB_KEY='sb_publishable_8oZE-6157A8F7sRZEWCrhw_8OQ4yz0W';const sb=supabase.createClient(SB_URL,SB_KEY);
const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));
const money=n=>'₹'+Number(n||0).toLocaleString('en-IN',{maximumFractionDigits:2});
async function auth(requiredRole='contractor'){const u=await sb.auth.getUser();if(!u.data.user){location.href=requiredRole==='admin'?'admin-login.html':'contractor-login.html';return null}const p=await sb.from('profiles').select('*').eq('id',u.data.user.id).single();if(p.error||p.data?.role!==requiredRole||(requiredRole==='contractor'&&p.data?.status!=='approved')){await sb.auth.signOut();location.href=requiredRole==='admin'?'admin-login.html':'contractor-login.html';return null}return {user:u.data.user,profile:p.data}}
function msg(t,ok=true){const e=document.getElementById('msg');if(!e)return;e.textContent=t;e.className='msg '+(ok?'successmsg':'errormsg');e.style.display='block';setTimeout(()=>e.style.display='none',4000)}
async function logout(){await sb.auth.signOut();location.href='contractor-login.html'}
