# Migrações do Firestore — GoSchool

O Firestore não tem um sistema de migrations como um banco SQL (não existe
`ALTER TABLE`). Este arquivo documenta cada mudança de schema nas coleções do
projeto, na ordem em que foram introduzidas, e como popular dados de exemplo
quando aplicável. Pense nisso como o "changelog" do banco.

---

## 001 — `usuarios` (coleção raiz)

Criada em: cadastro de usuário (Responsável/Motorista).
Código: `lib/services/firestore_service.dart` → `salvarUsuario`.

Caminho: `usuarios/{uid}`

| Campo         | Tipo      | Observação                                      |
|---------------|-----------|--------------------------------------------------|
| `uid`         | string    | Mesmo valor do ID do documento                    |
| `nome`        | string    |                                                    |
| `email`       | string    |                                                    |
| `telefone`    | string    |                                                    |
| `cpf`         | string    |                                                    |
| `tipoPerfil`  | string    | `'responsavel'` ou `'motorista'`                  |
| `endereco`    | string    | Endereço combinado (rua, número - bairro)         |
| `cep`,`rua`,`numero`,`bairro` | string | Campos de endereço separados          |
| `cnh`,`licenca`,`placa`,`veiculo` | string | Só preenchidos para Motorista      |
| `casa_lat`,`casa_lng` | double | Localização da casa (Responsável), via mapa |
| `casa_endereco` | string | Endereço legível da casa (geocoding reverso)     |
| `criadoEm`    | timestamp | `FieldValue.serverTimestamp()`                    |
| `atualizadoEm`| timestamp | Atualizado em edições de perfil                   |
| `tema`        | string    | `'Claro'`, `'Escuro'` ou `'Automático'` (padrão)   |
| `tamanhoFonte`| string    | `'Pequena'`, `'Média'` (padrão) ou `'Grande'`      |

`tema` e `tamanhoFonte` foram adicionados em 2026-10 (depois da coleção já
existir) pra tornar reais as opções de Aparência da tela de Configurações,
que antes eram só UI local sem efeito nenhum no app. Gravados por
`FirestoreService.salvarPreferencias` e lidos pelo `PreferenciasProvider`
(`lib/services/preferencias_provider.dart`), que aplica o `ThemeMode` e a
escala de fonte no `MaterialApp` inteiro. Usuários cadastrados antes disso
não têm esses dois campos — o `Usuario.fromMap` usa os padrões acima nesse caso.

---

## 002 — `usuarios/{uid}/filhos` (subcoleção)

Criada em: cadastro de filho pelo Responsável.
Código: `lib/services/firestore_service.dart` → `salvarFilho`.

| Campo | Tipo |
|---|---|
| `nome`, `idadeEAno`, `escola`, `turno`, `horario`, `tipoSanguineo`, `alergias`, `status` | string |

---

## 003 — `usuarios/{uid}/mensalidades` (subcoleção) — Finanças do Motorista

Criada em: 2026-10. Dados ainda **mockados** (ver seção "Seed" abaixo) —
quando houver um fluxo real de pagamento, passar a gravar aqui a partir
desse fluxo em vez do botão de seed.

Código: `lib/services/firestore_service.dart` → `mensalidadesStream`,
`semearMensalidadesMock`. Model: `lib/models/mensalidade_model.dart`.

Caminho: `usuarios/{motoristaUid}/mensalidades/{mensalidadeId}`

| Campo             | Tipo      | Observação                          |
|-------------------|-----------|--------------------------------------|
| `responsavelNome` | string    | Nome do responsável que pagou         |
| `filhoNome`       | string    | Nome do filho vinculado ao pagamento  |
| `valor`           | number    | Valor em reais (double)               |
| `data`            | timestamp | Data de referência da mensalidade     |
| `status`          | string    | `'Pago'` ou `'Pendente'`               |

### Como semear os dados de exemplo

Não há Admin SDK neste projeto (é um app Flutter puro, sem backend Node),
então a semeadura é feita **de dentro do próprio app**, autenticado como o
motorista, usando o SDK cliente do Firestore:

1. Faça login como um usuário com `tipoPerfil: 'motorista'`.
2. Abra **Finanças** (ícone 💲 na AppBar do painel do motorista).
3. Se a lista estiver vazia, toque em **"Carregar dados de exemplo"**.
4. Isso chama `FirestoreService.instance.semearMensalidadesMock(uid, ...)`,
   que grava 5 documentos mockados (`mock_1` a `mock_5`) vindos de
   `MensalidadeRepository.obterMensalidades()`.
5. A operação é **idempotente**: os IDs são fixos, então rodar de novo só
   sobrescreve os mesmos 5 documentos, nunca duplica.

Pra conferir manualmente: Firebase Console → Firestore Database →
`usuarios` → (documento do motorista) → `mensalidades`.

---

## 004 — `usuarios/{responsavelUid}/contratacoes` (subcoleção) — Tela de Contratação

Criada em: 2026-10. Gravada pela `TelaContratacao` quando o Responsável
confirma a contratação de um motorista pra um ou mais filhos.

Código: `lib/telas/contratacao/tela_contratacao.dart`.

Caminho: `usuarios/{responsavelUid}/contratacoes/{contratacaoId}` (ID
autogerado pelo Firestore, via `.add()`)

| Campo              | Tipo       | Observação                                |
|---------------------|-----------|---------------------------------------------|
| `motoristaUid`       | string    | uid do motorista — ver nota abaixo            |
| `motoristaNome`      | string    |                                               |
| `motoristaVeiculo`   | string    |                                               |
| `motoristaPlaca`     | string    |                                               |
| `responsavelNome`    | string    | Nome do responsável no momento da contratação |
| `filhosIds`          | array\<string\> | IDs dos documentos em `.../filhos`     |
| `filhosNomes`        | array\<string\> | Nomes no momento da contratação        |
| `periodo`            | string    | `'Manhã'` ou `'Tarde'`                        |
| `valorPorFilho`      | number    | Mensalidade do motorista (double)             |
| `valorTotal`         | number    | `valorPorFilho × quantidade de filhos`        |
| `status`             | string    | `'Ativo'` (sem fluxo de cancelamento ainda)   |
| `contratadoEm`       | timestamp | `FieldValue.serverTimestamp()`                |

Não precisa de seed — é criada organicamente pelo fluxo real de uso
(Serviços → tocar no motorista → "Contratar motorista").

`motoristaUid` e `responsavelNome` foram adicionados em 2026-10 (depois da
coleção já existir) pra dar pro motorista consultar "quem me contratou" —
ver seção 005. Contratações feitas antes disso não têm esses dois campos.

---

## 005 — "Meus contatos" do chat (consulta, não coleção nova)

Criada em: 2026-10. Não é uma coleção nova — são duas consultas em cima da
própria `contratacoes` (seção 004), usadas pela tela "Nova conversa"
(`TelaNovoChat`) pra listar com quem dá pra começar um chat.

Código: `lib/services/firestore_service.dart` →
`meusMotoristasContratadosStream`, `meusResponsaveisStream`.

- **Lado do Responsável**: lê a própria subcoleção
  `usuarios/{meuUid}/contratacoes` e tira os `motoristaUid`/`motoristaNome`
  distintos. Não precisa de índice especial.
- **Lado do Motorista**: usa uma consulta **collection group** em
  `contratacoes` filtrando por `motoristaUid == meuUid` (já que a
  contratação só existe do lado do Responsável). **Precisa de um índice de
  collection group pro campo `motoristaUid`** — na primeira vez que essa
  consulta rodar no app de verdade, o erro no console do navegador traz um
  link direto pra criar esse índice no Firebase Console; depois de criado
  (leva alguns minutos), a consulta passa a funcionar.

---

## 006 — `usuarios/{motoristaUid}/avaliacoes` (subcoleção) — Avaliação do Motorista

Criada em: 2026-10. Substitui a nota fixa que existia em texto no card e no
modal do motorista por uma avaliação real, feita pelo Responsável depois de
contratar.

Código: `lib/models/avaliacao_model.dart`, `lib/services/firestore_service.dart`
→ `avaliacoesStream`, `enviarAvaliacao`. UI: `lib/widgets/avaliacao_media.dart`
(mostra a média real) e `lib/widgets/dialog_avaliar_motorista.dart` (diálogo de
estrelas + comentário, acessível pelo ícone ⭐ na AppBar do chat quando quem
está conversando é o Responsável).

Caminho: `usuarios/{motoristaUid}/avaliacoes/{responsavelUid}`

ID do documento é o `uid` do responsável que avaliou — uma avaliação por
responsável por motorista; avaliar de novo sobrescreve a anterior em vez de
duplicar.

| Campo              | Tipo      | Observação                                |
|---------------------|-----------|-------------------------------------------|
| `responsavelUid`    | string    | Mesmo valor do ID do documento              |
| `responsavelNome`   | string    |                                             |
| `nota`              | number    | Inteiro de 1 a 5                           |
| `comentario`        | string    | Opcional, pode ser vazio                   |
| `criadoEm`          | timestamp | `FieldValue.serverTimestamp()`             |

A média exibida nos cards/modal é calculada no cliente (`AvaliacaoMedia`,
via `StreamBuilder` sobre `avaliacoesStream`) — sem campo de média
pré-calculado no documento do motorista. Não precisa de índice especial
(é uma subcoleção simples, sem collection group).
