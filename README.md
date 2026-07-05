# Central Comercial · MasterInfo (Sistema)

Sistema interno com **login de verdade**, **3 perfis de acesso** e **página de administração**, usando **Supabase** (login seguro + banco na nuvem).

🔗 **Online:** https://phill-jr.github.io/masterinfo-sistema/

## Como entrar
Use o **e-mail e a senha** cadastrados no Supabase. O primeiro usuário criado vira **Gestor**.

## Perfis
- **Colaborador** — vê o material de estudo/dia a dia. Só visualiza.
- **Líder** — o do colaborador + Onboarding (aplicador) e Rotina da Liderança.
- **Gestor** — tudo + a aba **Admin**.

## Admin (Gestor)
- **Usuários** — vê todos, edita o **nome** e o **tipo (perfil)** de cada um.
  Criar/remover login (e-mail e senha) é no painel do Supabase (Authentication → Users). Ao criar, a pessoa aparece na lista e você define o perfil.
- **Conteúdo** — cria/edita/exclui os cards e marca **quem vê** (por perfil).

## Como funciona por dentro
- `index.html` — o app inteiro (interface + lógica), autocontido. Fala com o Supabase via a biblioteca `@supabase/supabase-js` (CDN).
- **Supabase** — autenticação (e-mail/senha) + banco Postgres:
  - tabela `profiles` (quem é quem + o tipo/perfil)
  - tabela `content` (os cards e quem vê cada um)
  - **RLS** (Row Level Security): todos logados leem; só o Gestor edita.
- `supabase/schema.sql` — o SQL que monta o banco (rode no SQL Editor do Supabase).

## Segurança
- A **chave publicável** (`sb_publishable_...`) fica no código de propósito: ela é feita pra isso e só permite o que a RLS libera.
- A **senha do banco** e a **service_role** NÃO ficam no projeto (são secretas).

## Configuração
No topo do `<script>` em `index.html`:
- `SUPABASE_URL` = URL do projeto
- `SUPABASE_KEY` = chave publicável (anon)

## Deploy
Hospedado no **GitHub Pages**. Qualquer `git push` na branch `main` atualiza o site em ~1 min.
