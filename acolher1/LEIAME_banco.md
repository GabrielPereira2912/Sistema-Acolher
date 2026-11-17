# Como cada tela usa o banco (v3)

Regra do grupo: **o banco manda; as telas se adaptam a ele.**
Importar na ordem: `sql/banco_acolher_v3.sql` e depois `sql/dados_teste.sql`.

| Tela | O que ela grava / lê | Ajuste feito na tela (em relação ao wireframe) |
|---|---|---|
| Cadastro do Estudante | grava `estudantes` + `responsaveis` (principal) + `log_acessos` | Campo **Parentesco** acrescentado. Turno e Etapa são preenchidos pela turma escolhida. |
| Triagem de Demandas | grava `acolhimentos` + `acolhimento_demandas` | 7 categorias vindas do banco (inclui **Outras** + campo de especificação). Data = hoje, profissional = usuário logado. |
| Prontuário (linha do tempo) | lê a view `linha_do_tempo` | A etiqueta de cada item mostra a **modalidade** (Individual, Telefone...). |
| Prontuário (Novo Atendimento) | grava `atendimentos` e, se houver, 1 `encaminhamentos` | **Profissional** = usuário logado (campo fixo). Encaminhamento = escolher destino + prazo; o responsável é o próprio usuário logado. |
| Dashboard | lê a view `painel_estudantes` e cards de COUNT | Sem mudança. Aluno sem atendimento mostra a data de cadastro e quem cadastrou. |
| Login (ainda não existe no wireframe) | lê `usuarios` | Por enquanto tudo é gravado como usuário 1 (`USUARIO_LOGADO_ID` em `api/conexao.php`). |

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
