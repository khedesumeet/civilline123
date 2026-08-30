import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json"
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", {headers:cors});

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceKey);

    const auth = req.headers.get("Authorization");
    if (!auth) throw new Error("Missing authorization.");

    const token = auth.replace("Bearer ", "");
    const { data: caller, error: callerError } = await admin.auth.getUser(token);
    if (callerError || !caller.user) throw new Error("Unauthorized.");

    const { data: adminProfile } = await admin
      .from("profiles")
      .select("role")
      .eq("id", caller.user.id)
      .single();

    if (adminProfile?.role !== "admin") throw new Error("Admin access required.");

    const body = await req.json();

    for (const field of ["email","password","company_name","owner_name","mobile","city"]) {
      if (!body[field]) throw new Error(`${field} is required.`);
    }

    if (String(body.password).length < 6)
      throw new Error("Password must be at least 6 characters.");

    const { data: created, error: createError } =
      await admin.auth.admin.createUser({
        email: String(body.email).trim(),
        password: String(body.password),
        email_confirm: true,
        user_metadata: {
          company_name: body.company_name,
          owner_name: body.owner_name
        }
      });

    if (createError) throw createError;

    const { error: profileError } = await admin
      .from("profiles")
      .insert({
        id: created.user.id,
        company_name: body.company_name,
        owner_name: body.owner_name,
        mobile: body.mobile,
        whatsapp: body.whatsapp || null,
        email: body.email,
        city: body.city,
        area: body.area || null,
        address: body.address || null,
        services: Array.isArray(body.services) ? body.services : [],
        role: "contractor",
        status: "approved",
        is_featured: false
      });

    if (profileError) {
      await admin.auth.admin.deleteUser(created.user.id);
      throw profileError;
    }

    return new Response(JSON.stringify({
      success: true,
      user_id: created.user.id
    }), {status:200,headers:cors});

  } catch (e) {
    return new Response(JSON.stringify({
      error: e instanceof Error ? e.message : String(e)
    }), {status:400,headers:cors});
  }
});
