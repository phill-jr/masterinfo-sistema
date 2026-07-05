# Central Comercial · MasterInfo (Sistema)

Sistema-base com **login**, **3 perfis de acesso** e **página de administração**.
Protótipo funcional que roda **abrindo o `index.html` no navegador** (duplo-clique), sem instalar nada.

## Como usar
1. Abra o `index.html` no navegador (Chrome/Edge).
2. Entre com uma das contas de teste:

| Perfil | Usuário | Senha |
|--------|---------|-------|
| Gestor (admin) | `admin` | `admin123` |
| Líder | `lider` | `lider123` |
| Colaborador | `calouro` | `123` |

## O que cada perfil vê
- **Colaborador** — material de estudo e do dia a dia (Trilha, POPs, Cadência). Só visualiza.
- **Líder** — o do colaborador + Onboarding (aplicador) e Rotina da Liderança.
- **Gestor** — tudo + a aba **Admin**: cria/edita/exclui **usuários** e edita o **conteúdo** que cada perfil enxerga.

## Como o Gestor edita
Na aba **Admin**:
- **Usuários**: novo usuário, editar login/senha/tipo, excluir.
- **Conteúdo**: cada card tem título, link, categoria e um seletor de **quem vê** (marca os perfis). O que você marcar aparece no "Início" de quem tem aquele perfil.
- **Restaurar padrão**: volta usuários e conteúdo ao original.

## Banco de dados (temporário)
Os dados (usuários e conteúdo) ficam salvos no **navegador** (localStorage), na chave `masterinfo_sistema_v1`.
- ✅ Vantagem: funciona na hora, sem servidor, sem custo.
- ⚠️ Limitação: os dados vivem **só naquele navegador/computador** e a senha **não é criptografada**. É um protótipo para validar a visão, **não é seguro para produção**.

## Próximo passo (quando validar a visão)
Migrar o "banco temporário" para uma base real na nuvem (ex.: **Supabase**), ganhando:
- Login seguro (senha com hash), acesso de qualquer lugar.
- Dados compartilhados entre todos os usuários.
- A mesma estrutura de perfis e admin já pensada aqui.

## Estrutura
- `index.html` — o app inteiro (interface + lógica + "banco"), autocontido.

Os links dos cards apontam para os materiais em `../03 - Masterinfo Internet/` (mantenha as duas pastas lado a lado no Desktop para os links funcionarem).
