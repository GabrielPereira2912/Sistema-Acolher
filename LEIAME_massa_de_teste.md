# Massa de dados de teste — Acolher

Tudo aqui é **fictício**. Serve para testar todas as telas e regras do sistema sem cadastrar nada à mão.

## Como importar (phpMyAdmin, nesta ordem)

1. `sql/banco_acolher_v3.sql` (recria o banco `acolher`)
2. `sql/dados_teste.sql` (usuários marina/ricardo/admin e as 5 turmas)
3. `sql/massa_de_teste.sql` (**esta massa**: 34 estudantes, 5 usuários extras, 4 turmas extras, 73 atendimentos…)

- Para repetir só a massa: rode `sql/limpar_massa_de_teste.sql` e importe `massa_de_teste.sql` de novo.
- Não precisa importar o `dados_ficticios_aluno.sql` (os 2 alunos 9999-). Se importar, os números abaixo sobem um pouco.
- As datas são relativas a **hoje**: prazos "vencidos" e "atendimentos no mês" continuam fazendo sentido em qualquer dia.

## Logins (senha de todos: `teste123`)

| E-mail | Perfil | Para que serve no teste |
|---|---|---|
| `marina@escola.test` | Psicóloga | Usuária principal (26 atendimentos) |
| `ricardo@escola.test` | Assistente social | Usuário principal (21 atendimentos) |
| `camila.torres@massa.test` | Psicóloga | Segunda psicóloga |
| `paulo.mendes@massa.test` | Assistente social | Segundo assistente social |
| `fernanda.lima@massa.test` | Psicóloga | **Nunca acessou** (aparece "Nunca acessou" em Usuários) |
| `helena.rocha@massa.test` | Assistente social | **Desativada**: não consegue entrar, mas o histórico dela aparece nos prontuários |
| `admin@escola.test` | ADMIN | Administrador principal |
| `coordenacao@massa.test` | ADMIN | Segundo administrador (permite testar as regras do "único admin") |

## Números que o Dashboard deve mostrar (só com a massa, sem os 9999-)

| Card | Valor |
|---|---|
| Estudantes acompanhados | **17** |
| Triagens pendentes | **7** |
| Aguardando 1º atendimento | **6** |
| Atendimentos no mês | varia com o dia (**1 a 24+**; os de hoje, ontem… entram só se caírem neste mês) |
| Encaminhamentos em aberto | **16**, com alerta **"7 com prazo vencido"** |
| Lista de estudantes | **34** (4 páginas: 10 + 10 + 10 + 4) |

Outros totais: 4 estudantes encerrados, 73 atendimentos, 7 destinos/tipos usados, 5 modalidades, 7 categorias de demanda (incluindo "Outras" com especificação).

## Casos especiais (o que cada estudante testa)

| Estudante | O que testa |
|---|---|
| Ana Clara Ferreira Lima | Prontuário **completo**: 7 atendimentos + acolhimento, 4 encaminhamentos (vencido, aberto, 2 concluídos), duas profissionais |
| Júlia Almeida Costa | Busca sem acento (`julia`); encaminhamento **cancelado**; histórico longo (200 dias) |
| João Pedro D'Ávila de Albuquerque e Silva Júnior | **Nome longo** com apóstrofo (layout, busca, XSS) |
| Rafael O'Connor Tavares / Sofia Cardoso-Nascimento | Apóstrofo e hífen |
| Helena Vasconcelos Prado | Turma do **ano anterior** (9º A, ano passado): a edição do admin mostra a turma com o ano |
| Valentina Gomes Carvalho | Atendimentos de uma profissional **desativada** (Helena Rocha) mais um atual |
| Enzo Gabriel Campos / Maria Eduarda Nogueira | Atendimento **hoje** (Dashboard ordena por atividade recente) |
| Beatriz Lemos Freitas e mais 5 | **Aguardando 1º atendimento** (têm triagem, sem atendimento). Registre um atendimento e o status vira "Em acompanhamento" |
| Laura Siqueira Neves | Triagem com **as 7 categorias** marcadas e especificação de "Outras" |
| Bernardo Vieira Castro | Triagem **sem descrição** complementar e com categoria de violação/negligência |
| Manuela Correia Andrade e mais 6 | **Triagem pendente** (sem acolhimento). Faça a triagem e ela passa para "Aguardando" |
| Samuel Duarte Pires, Yasmin Farias Quintela | Cadastrados pelo **administrador** (Dashboard mostra "Administrador" como responsável) |
| Gustavo Henrique Lacerda | **Sem responsável** cadastrado (prontuário mostra "—"; o admin cadastra o responsável pela edição) |
| Clara Mendonça Reis | Triagem pendente há 40 dias |
| Felipe, Camila, Vinícius, Emanuele | **Encerrados**, com histórico completo |

Encaminhamentos: 8 abertos **vencidos** (prazos de 3 a 62 dias atrás), 1 que vence **hoje** (não conta como vencido), vários futuros, 10 concluídos e 3 cancelados, usando os 5 destinos. Os 7 tipos de intervenção e as 5 modalidades aparecem em atendimentos reais.

## Roteiro rápido por perfil

**Psicóloga/assistente social** (marina ou ricardo)
1. Dashboard: confira os cards acima; busque `julia`, `d'ávila`, `Camila` (busca também por profissional); navegue pelas 4 páginas.
2. Abra a Ana Clara: linha do tempo com 8 registros e encaminhamentos com selo **Vencido/Aberto/Concluído**.
3. Triagem: o seletor mostra os 34 alunos e marca 27 como "já triado". Faça a triagem da **Manuela** (pendentes 7 → 6, aguardando 6 → 7).
4. Prontuário da **Beatriz Lemos**: registre um atendimento com encaminhamento e prazo futuro (aguardando 7 → 6, acompanhados 17 → 18, encaminhamentos em aberto +1).
5. Cadastro do Estudante: cadastre um aluno novo (matrícula `2026-99999`), você segue direto para a triagem.
6. Minha conta: troque a senha e entre de novo.
7. Tente abrir `usuarios.html` ou `estudantes.html`: volta para o Dashboard.

**Administrador** (admin ou coordenacao)
1. Menu: só Dashboard, Cadastro do Estudante, Estudantes, Usuários e Minha conta. Os nomes no Dashboard **não são links**; abrir `prontuario.html?id=1` volta para o Dashboard.
2. Usuários: cards **7 ativos / 3 psicólogas / 2 assistentes / 2 admins** e "1 desativado"; busca, filtro de situação, coluna Último acesso; crie, edite, desative/reative e redefina senha de alguém.
3. Regras: tente desativar a si mesmo, mudar o próprio perfil ou deixar o sistema sem admin ativo (bloqueado).
4. Estudantes: 34 cadastrados, busca por nome/matrícula/responsável, filtro por turma; **mude uma turma** (pede confirmação), corrija um nome e cadastre o responsável do Gustavo.
5. Cadastro do Estudante: o admin cadastra e **permanece** no formulário (não vai para a triagem).

## Para quem só quer ver rápido
Login `marina@escola.test` / `teste123` -> Dashboard -> "Ana Clara Ferreira Lima".

## Limitações
- Os números do Dashboard acima valem logo depois da importação; qualquer cadastro/atendimento que você fizer muda os totais (o roteiro diz quanto).
- As 4 turmas extras e os 5 usuários extras são removidos pelo `limpar_massa_de_teste.sql` (as turmas só se estiverem vazias).
- Importei e testei esta massa em um banco SQLite equivalente (todos os `INSERT` usam sintaxe padrão do MySQL). Se o phpMyAdmin acusar erro em alguma linha, me mande a mensagem.
