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
- Usuários de teste (dados_teste.sql): `marina@escola.test` (psicóloga) e `ricardo@escola.test` (assistente social). Senha dos dois: `teste123`.
- **Criar o primeiro ADMIN** (não existe no seed): no terminal, na pasta do projeto, rode `C:\xampp\php\php.exe scripts\criar_usuario.php` (Windows/XAMPP) ou `php scripts/criar_usuario.php`. A senha vira hash; nunca fica em texto no banco. O script só roda pelo terminal.
- Botão **Sair** (rodapé do menu) encerra a sessão.
- Para trocar o tempo de expiração: constante `TEMPO_SESSAO` em `api/conexao.php`.

### Limites conhecidos (protótipo)
- Não há bloqueio por tentativas (só um atraso de 0,4 s a cada erro). Em produção, criar uma tabela de tentativas.
- Em produção usar HTTPS (o cookie já vira `Secure` sozinho quando o site usa HTTPS).
- Ainda não existe tela para cadastrar/desativar usuários: use o script ou o phpMyAdmin (`ativo = 0`).
