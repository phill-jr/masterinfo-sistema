// Edge Function: create-user
// Cria um login (e-mail + senha) e define o perfil. SO o Gestor pode chamar.
// O navegador nunca ve a chave secreta: ela fica aqui no servidor do Supabase.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const authHeader = req.headers.get("Authorization") ?? "";

    // Quem esta chamando? (usa o token de quem esta logado no app)
    const asCaller = createClient(url, anon, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user } } = await asCaller.auth.getUser();
    if (!user) return json({ error: "Nao autenticado." }, 401);

    // Cliente admin (chave secreta, so aqui no servidor)
    const admin = createClient(url, service);

    // So o Gestor pode criar usuarios
    const { data: prof } = await admin
      .from("profiles").select("tipo").eq("id", user.id).single();
    if (!prof || prof.tipo !== "gestor") {
      return json({ error: "Apenas o Gestor pode criar usuarios." }, 403);
    }

    const body = await req.json().catch(() => ({}));
    const email = String(body.email ?? "").trim().toLowerCase();
    const password = String(body.password ?? "");
    const nome = String(body.nome ?? "").trim() || email.split("@")[0];
    const tipo = ["colaborador", "lider", "gestor"].includes(body.tipo)
      ? body.tipo : "colaborador";

    if (!email || !password) return json({ error: "Informe e-mail e senha." }, 400);
    if (password.length < 6) return json({ error: "A senha precisa ter ao menos 6 caracteres." }, 400);

    // Cria o login ja confirmado (nao precisa confirmar e-mail)
    const { data: created, error } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { nome },
    });
    if (error) {
      const msg = /already/i.test(error.message) ? "Ja existe um login com esse e-mail." : error.message;
      return json({ error: msg }, 400);
    }

    // Ajusta nome + tipo no perfil (a linha ja foi criada pelo gatilho)
    if (created?.user) {
      await admin.from("profiles").update({ nome, tipo }).eq("id", created.user.id);
    }

    return json({ ok: true });
  } catch (e) {
    return json({ error: String((e as Error)?.message ?? e) }, 500);
  }
});
