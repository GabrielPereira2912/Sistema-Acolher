# Como cada tela usa o banco (v3)

Regra do grupo: **o banco manda; as telas se adaptam a ele.**
Importar na ordem: `sql/banco_acolher_v3.sql` e depois `sql/dados_teste.sql`.

| Tela | O que ela grava / lê | Ajuste feito na tela (em relação ao wireframe) |
|---|---|---|
| Cadastro do Estudante | grava `estudantes` + `responsaveis` (principal) + `log_acessos` | Campo **Parentesco** acrescentado. Turno e Etapa são preenchidos pela turma escolhida. |
| Triagem de Demandas | grava `acolhimentos` + `acolhimento_demandas` | 7 categorias vindas do banco (inclui **Outras** + campo de especificação). Data = hoje, profissional = usuário logado. |
| Prontuário (linha do tempo) | lê a view `linha_do_tempo` | A etiqueta de cada item mostra a **modalidade** (Individual, Telefone...). |
| Prontuário (Novo Atendimento) | grava `atendimentos` e, se houver, 1 `encaminhamentos` | **Profissional** = usuário logado (campo fixo). Encaminhamento = escolher destino + prazo; o responsável é o próprio usuário logado. |
| Dashboard (`index.html`) | lê a view `painel_estudantes` e faz COUNT para os cards | Cards: acompanhados (`EM_ACOMPANHAMENTO`), triagens pendentes (sem acolhimento registrado), aguardando 1º atendimento (triado, sem atendimentos), atendimentos do mês e encaminhamentos abertos (com aviso dos vencidos). Aluno sem atendimento mostra a data de cadastro e quem cadastrou. |
| Login | lê `usuarios`; grava `LOGIN` em `log_acessos` | Sessão PHP (cookie `ACOLHERSESS`, HttpOnly, SameSite=Lax). Todas as APIs exigem login (401 sem sessão). Expira após 30 min parado. Mensagem de erro igual para e-mail inexistente, senha errada e usuário desativado. |

## Mudanças no banco v2 -> v3 (só duas, nenhuma tabela nova)
1. View `linha_do_tempo` passou a trazer a coluna `modalidade`.
2. Nova view `painel_estudantes`: o dashboard vira `SELECT * FROM painel_estudantes`.

## Regras da tela de Prontuário (`prontuario.html?id=NUMERO`)
- Sem `?id`, a tela mostra a lista de estudantes para escolher.
- O profissional do atendimento é sempre o usuário logado; o **cargo fica gravado** no atendimento (`cargo_profissional`).
- Registrar o **primeiro atendimento** muda o status do estudante de `TRIAGEM` para `EM_ACOMPANHAMENTO`.
- Encaminhamento é opcional: se escolher um destino, o prazo passa a ser obrigatório e não pode ser antes da data do atendimento.
- Abrir um prontuário grava `VISUALIZOU` em `log_acessos`; registrar atendimento grava `CRIOU`.
- Encaminhamento aberto com prazo vencido aparece com o selo vermelho "Vencido".
- Perfil `ADMIN` não registra atendimento (o formulário some e a API recusa).

## Dados fictícios para testar (matrículas `9999-`)
Ordem de importação: `banco_acolher_v3.sql` -> `dados_teste.sql` -> `dados_ficticios_aluno.sql`.
- **Beatriz (9999-00001):** acolhimento com 5 demandas (inclui "Outras"), 8 atendimentos (as 5 modalidades, os 7 tipos de ação, psicóloga e assistente social) e 6 encaminhamentos (os 5 destinos; status Aberto, Aberto vencido, Concluído e Cancelado; um atendimento com 2 encaminhamentos). 3 responsáveis.
- **Lucas (9999-00002):** em Triagem, só com acolhimento. Registre o 1º atendimento dele e veja o status virar "Em acompanhamento".
- As datas são relativas a hoje, então o "Vencido" funciona em qualquer dia.
- Para apagar tudo: `limpar_dados_ficticios.sql` (só remove matrículas `9999-`; alunos reais ficam intactos).

## Regras da tela de Triagem (`triagem-demandas.html?estudante=NUMERO`)
- Fluxo: **Cadastro -> Triagem -> Prontuário**. O cadastro abre a triagem do aluno recém-cadastrado; a triagem, ao salvar, abre o prontuário dele.
- É preciso marcar ao menos 1 demanda e preencher a descrição. Marcou **Outras**? A especificação passa a ser obrigatória.
- Cada estudante tem **uma única triagem** (acolhimento inicial). Quem já foi triado aparece como "já triado" e o formulário é trocado por um link para o prontuário; novas ações são atendimentos.
- Registrar a triagem **não** muda o status: o estudante continua em `TRIAGEM` até o 1º atendimento, quando vira `EM_ACOMPANHAMENTO`.
- No prontuário, o item "Acolhimento inicial" mostra as demandas marcadas como etiquetas.
- Perfil `ADMIN` não registra triagem.

## Regras do Dashboard (`index.html`, a página inicial)
- A lista mostra todos os estudantes, do registro mais recente para o mais antigo. Clicar na linha abre o prontuário.
- A busca ignora acentos e maiúsculas e procura em nome, turma e profissional ("julia" encontra "Júlia").
- "Atendimentos no mês" conta do dia 1 ao último dia do mês atual. "Triagens pendentes" são os estudantes em `TRIAGEM` que **ainda não têm triagem registrada** (sem acolhimento). Quem já foi triado e espera o 1º atendimento não conta.
- "Aguardando 1º atendimento" conta quem **já tem triagem** e ainda não teve nenhum atendimento (status `TRIAGEM` + acolhimento + zero atendimentos). Ao registrar o 1º atendimento o aluno sai deste card e passa a contar em "Estudantes acompanhados".
- Se houver encaminhamento aberto com prazo vencido, o card mostra "N com prazo vencido" em vermelho.
- No prontuário, o botão "Voltar ao dashboard" leva para `index.html`.
- A lista é paginada: **10 estudantes por página** (constante `POR_PAGINA` em `dashboard.js`). O rodapé só aparece se houver mais de 10. Qualquer busca volta para a página 1.
- No celular (até 700px) a tabela vira uma lista de cartões, sem rolagem lateral.
- Se o servidor falhar, a lista mostra o erro com o botão "Tentar novamente".


## Login (como usar)

- Abra `http://localhost/acolher/login.html`. Qualquer outra página sem login volta para cá e, depois de entrar, retorna à página pedida.
- Usuários de teste (dados_teste.sql), senha de todos `teste123`: `marina@escola.test` (psicóloga), `ricardo@escola.test` (assistente social) e `admin@escola.test` (**ADMIN**, abre a tela de Usuários). O admin de teste é só para desenvolvimento/apresentação: antes de uso real, troque a senha em Minha conta ou desative-o e crie o seu pelo script.
- **Criar um ADMIN de verdade** (o `admin@escola.test` do seed é só de teste): no terminal, na pasta do projeto, rode `C:\xampp\php\php.exe scripts\criar_usuario.php` (Windows/XAMPP) ou `php scripts/criar_usuario.php`. A senha vira hash; nunca fica em texto no banco. O script só roda pelo terminal.
- Botão **Sair** (rodapé do menu) encerra a sessão.
- Para trocar o tempo de expiração: constante `TEMPO_SESSAO` em `api/conexao.php`.

### Limites conhecidos (protótipo)
- Não há bloqueio por tentativas (só um atraso de 0,4 s a cada erro). Em produção, criar uma tabela de tentativas.
- Em produção usar HTTPS (o cookie já vira `Secure` sozinho quando o site usa HTTPS).

## Usuários e Minha conta

| Tela | Quem vê | API | O que faz |
|---|---|---|---|
| `usuarios.html` | **só ADMIN** (menu escondido para os outros; a API devolve 403 e a página volta ao dashboard) | `api/usuarios.php` | Lista a equipe, cadastra usuário (perfil + registro CRP/CRESS), ativa/desativa e redefine a senha de outro usuário |
| `minha-conta.html` | todos os logados | `api/minha_senha.php` | Mostra os dados do usuário e troca a própria senha (exige a senha atual) |

Regras:
- Senha: de 8 a 72 caracteres (o bcrypt ignora o que passa de 72), sempre guardada como hash (`password_hash`).
- Registro de classe obrigatório para PSICOLOGO e ASSISTENTE_SOCIAL; ADMIN fica sem registro.
- Usuário nunca é apagado, só desativado (o histórico continua com o nome dele). Quem é desativado perde o acesso na hora.
- O ADMIN não pode desativar o próprio usuário, e sempre sobra pelo menos um ADMIN ativo.
- A API nunca devolve `senha_hash`.
- Limite conhecido: ao redefinir/trocar a senha, sessões já abertas em OUTROS navegadores seguem válidas até expirarem (30 min parado). A sessão atual recebe novo ID.

## Permissões por perfil

| Tela / API | ADMIN | PSICOLOGO / ASSISTENTE_SOCIAL |
|---|---|---|
| Dashboard (`dashboard.php`) | vê números e lista, **sem abrir prontuário** (nomes não são links) | vê e abre o prontuário |
| Cadastro do Estudante | cadastra e **permanece no cadastro** (não vai à triagem) | cadastra e segue para a triagem |
| Triagem de Demandas | bloqueado (tela volta ao Dashboard; `acolhimentos.php` 403) | sim |
| Prontuário | **bloqueado** (tela volta ao Dashboard; `prontuario.php` e a lista `GET estudantes.php` respondem 403; não gera log `VISUALIZOU`) | sim |
| Atendimentos | bloqueado (403) | sim |
| Usuários | sim (cards, busca, filtro, último acesso, **editar**, ativar/desativar, redefinir senha) | bloqueado (403) |
| Estudantes (`estudantes.html`) | **só ADMIN**: corrige identificação, **turma** e responsável principal | bloqueado (tela volta ao Dashboard; `estudantes_gestao.php` 403) |
| Minha conta | sim | sim |

O menu lateral mostra só o que o perfil pode usar (`ajustarMenu()` em `comum.js`), mas a regra de verdade está no PHP: esconder o botão não protege, o 403 da API protege.

## Edição pelo ADMIN

**Editar usuário** (`usuarios.php`, ação `editar`): nome, e-mail, perfil e registro de classe.
- E-mail único (outro usuário com o mesmo e-mail dá 409). Registro de classe obrigatório para profissionais; ADMIN fica sem registro.
- O ADMIN **não altera o próprio perfil** (para não se trancar para fora) e sempre sobra **pelo menos um ADMIN ativo**.
- Mudar o perfil vale **na hora**, mesmo com a pessoa logada (o login confere o banco a cada requisição). A tela pede confirmação.
- Os atendimentos antigos mantêm o cargo que a pessoa tinha na época (`cargo_profissional` é gravado no registro).
- A senha continua sendo trocada pela ação própria (Redefinir senha).

**Corrigir estudante e mudar de turma** (`estudantes_gestao.php`): nome, matrícula, data de nascimento, turma e responsável principal (nome, parentesco, telefone).
- **Privacidade:** a API não devolve nem altera composição familiar, necessidades de apoio, status, triagem ou atendimentos. O administrador continua sem acesso ao conteúdo do prontuário.
- Mesmas regras do cadastro (arquivo `regras_estudante.php`, compartilhado com `estudantes.php`): matrícula `0000-00000` e única entre os estudantes, data não futura, telefone com DDD.
- Mudar de turma pede confirmação. Cada correção grava `EDITOU` em `log_acessos` com o ADMIN e o estudante.
- Limite conhecido: o histórico não guarda a turma anterior (só o log de que houve edição).

## Esqueci a senha (recuperação)

| Quem esqueceu | O que fazer |
|---|---|
| Psicólogo(a) ou assistente social | Um ADMIN abre **Usuários > Redefinir senha** e define uma senha provisória. A pessoa entra e troca em **Minha conta**. |
| Um ADMIN (existe outro ADMIN) | O outro ADMIN redefine em **Usuários**. |
| O **único** ADMIN (ou todos) | Pelo terminal, no computador do servidor, na pasta do projeto: `C:\xampp\php\php.exe scripts\redefinir_senha.php` (Windows/XAMPP) ou `php scripts/redefinir_senha.php`. Informe o e-mail e a nova senha (8 a 72 caracteres). Se o usuário estiver desativado, o script pergunta se quer reativar. |

- A "chave" da recuperação é ter acesso ao servidor: o script só roda pelo terminal (pela web responde 403).
- Não existe "esqueci minha senha" por e-mail: isso exigiria um servidor de e-mail (SMTP) e uma tabela de tokens, fora do escopo do protótipo.
- Boa prática: manter pelo menos **dois** administradores ativos e entregar senhas provisórias pessoalmente, pedindo a troca no primeiro acesso.

## Massa de dados completa para testes

`sql/massa_de_teste.sql` (34 estudantes, 5 usuários extras, 73 atendimentos, encaminhamentos de todos os tipos, log de acessos) e `sql/limpar_massa_de_teste.sql`. O roteiro de testes e os números esperados estão em **`LEIAME_massa_de_teste.md`**.

## Modo escuro
- Botão de sol/lua ao lado do "Sair" (na tela de login, no canto superior direito).
- A escolha fica salva no navegador (`localStorage`, chave `acolher-tema`); sem escolha, o sistema segue o tema do computador/celular.
- `assets/js/tema.js` roda no `<head>` (evita piscar o tema errado) e só troca o atributo `data-tema` do `<html>`.
- Todas as cores ficam como variáveis no topo de `assets/css/style.css`; a paleta escura está em `:root[data-tema="escuro"]`. Para ajustar uma cor, mude só ali.
- No celular a barra do usuário (tema + Sair) agora aparece também (antes o "Sair" ficava escondido).

## Concluir ou cancelar encaminhamento
- No prontuário, cada encaminhamento **aberto** tem os botões **Concluir** e **Cancelar** (cancelar pede confirmação).
- `api/encaminhamentos.php` (POST `{id, acao: "concluir"|"cancelar"}`): só Psicólogo e Assistente Social (Admin recebe 403).
- Concluir grava `status = CONCLUIDO` e `concluido_em` = hoje. Cancelar grava `status = CANCELADO` (sem data).
- Só encaminhamento ABERTO pode ser encerrado (já encerrado devolve 409). Cada alteração entra no `log_acessos` como `EDITOU`.
- O Dashboard conta só os ABERTOS; ao encerrar, o número de "em aberto" e de "prazo vencido" diminui.
