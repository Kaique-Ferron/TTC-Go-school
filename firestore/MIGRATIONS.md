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

### `fotoPerfil` — sem Firebase Storage (plano Spark/gratuito)

| Campo        | Tipo   | Observação                                             |
|--------------|--------|---------------------------------------------------------|
| `fotoPerfil` | string | URL `https://...` **ou** `data:image/jpeg;base64,...`   |

O Firebase Storage exige o plano pago (Blaze) pra funcionar — mesmo
ficando dentro da cota gratuita, precisa de cartão cadastrado. Como o
projeto roda no plano gratuito (Spark), a foto de perfil é redimensionada
pequena (`ImagePicker` com `maxWidth`/`maxHeight: 240`, `imageQuality: 60`)
e gravada como string base64 **direto no documento do usuário**, em vez de
em `Firebase Storage` + salvar só a URL. Há uma checagem de tamanho
(`bytes.length > 700 * 1024`) pra nunca estourar o limite de 1MB por
documento do Firestore.

Código: `_selecionarEAtualizarFoto` em `lib/telas/motorista/tela_motorista.dart`
e `lib/telas/meu_perfil/editar_perfil.dart`. Toda exibição da foto passa por
`fotoPerfilProvider()` (`lib/widgets/foto_perfil_provider.dart`), que decide
entre `MemoryImage` (base64) e `NetworkImage` (URL antiga, se um dia o
projeto migrar pro plano Blaze e voltar a usar Storage).

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

---

## 007 — `usuarios/{motoristaUid}/chamadas` (subcoleção) — Chamada da Van

Criada em: 2026-10. Tela acessada pelo menu (☰) do Motorista → "Chamada":
confirma, pra cada criança da rota, se ela está presente na van num
dia/período. Em vez de um sistema de notificação push separado (que não
existia e mais ninguém leria), cada marcação manda uma mensagem real no
chat já existente pro responsável daquela criança.

Código: `lib/models/crianca_rota.dart`, `lib/services/firestore_service.dart`
→ `criancasDaRotaStream`, `chamadaStream`, `marcarPresenca`, `chamadaIdPara`.
UI: `lib/telas/motorista/tela_chamada.dart`.

Caminho: `usuarios/{motoristaUid}/chamadas/{chamadaId}`

`chamadaId` é determinístico: `'{yyyy-MM-dd}_{periodo}'` (ex.:
`2026-10-22_Manhã`) — uma chamada por dia/período; marcar de novo no mesmo
dia atualiza em vez de duplicar.

| Campo         | Tipo      | Observação                                          |
|---------------|-----------|------------------------------------------------------|
| `periodo`     | string    | `'Manhã'` ou `'Tarde'`                                |
| `atualizadoEm`| timestamp | `FieldValue.serverTimestamp()`, atualizado a cada marcação |
| `criancas`    | map       | `{ [filhoId]: { nome, responsavelUid, presente, confirmadoEm } }` |

`criancas` é um **map** (não array) justamente pra permitir atualizar uma
única criança via `set(..., SetOptions(merge: true))` sem precisar reler e
regravar a chamada inteira.

A lista de crianças da rota (`criancasDaRotaStream`) reusa a mesma consulta
collection group de `meusResponsaveisStream` (seção 005) — mesmo índice,
sem precisar de um novo. O filtro `status == 'Ativo'` é feito no cliente
pra não exigir um índice composto adicional.

Regra do Firestore: só o próprio Motorista lê/escreve sua subcoleção de
chamadas; o responsável nunca lê esse documento diretamente, só recebe a
mensagem no chat.

---

## 008 — `motoristas_publico/{uid}` (coleção) — Perfil público do Motorista

Criada em: 2026-10. Correção de segurança: antes, `motoristasStream()`
(aba "Serviços"/busca de motorista) lia o documento INTEIRO de
`usuarios/{uid}` de cada motorista, porque a regra do Firestore liberava
leitura de qualquer documento com `tipoPerfil == 'motorista'` pra qualquer
usuário logado. Regra do Firestore não filtra CAMPO dentro do documento —
só documento inteiro — então isso também expunha `cpf`/`cnh`/`endereço`
(cep/rua/numero/bairro) de cada motorista, que ficam no mesmo documento,
pra qualquer responsável logado, mesmo sem nunca ter contratado.

Esta coleção guarda só o subconjunto que a busca de fato exibe:

| Campo         | Tipo   | Observação                                  |
|---------------|--------|----------------------------------------------|
| `uid`         | string | mesmo id do documento                        |
| `nome`        | string |                                                |
| `veiculo`     | string |                                                |
| `placa`       | string |                                                |
| `licenca`     | string | exibido como "Registro" na busca              |
| `fotoPerfil`  | string | `data:image/...` (base64) ou URL — ver seção de foto |

Mantido em sincronia automaticamente por `FirestoreService.salvarUsuario` e
`atualizarUsuario`: toda vez que o documento de um usuário com
`tipoPerfil == 'motorista'` é salvo/atualizado, esses campos são
espelhados aqui (`_sincronizarPerfilPublico`). Nenhuma tela escreve aqui
diretamente.

Regra do Firestore: qualquer usuário logado lê (é exatamente o que já era
exibido); só o próprio motorista escreve, e só no próprio documento.
`usuarios/{uid}` passou a permitir leitura só pro dono, documento completo.

**Contas de motorista criadas antes dessa mudança não têm esse documento
ainda** (não há backfill automático) — somem da busca até a próxima vez
que o motorista salvar algo no perfil (editar cadastro, trocar foto, etc.),
o que recria o espelho.

---

## 009 — `usuarios/{motoristaUid}/localizacao_ativa` e
## `usuarios/{motoristaUid}/responsaveis_ativos` — Van ao vivo no mapa

Criada em: 2026-10. O motorista aperta "Iniciar corrida" em "Minhas
Rotas" e o app passa a reportar a posição GPS dele pro Firestore; o
Responsável vê a van se mexendo ao vivo no mapa do Painel Principal
(`CardAcompanharRota`) — igual ao app de entrega do 99/Uber. Sem nenhuma
API paga: é só o GPS do próprio aparelho (pacote `geolocator`, já usado
no app) + Firestore. Código: `lib/services/localizacao_service.dart`
(liga/desliga o GPS), `FirestoreService.atualizarLocalizacaoAtiva` /
`pararLocalizacaoAtiva` / `localizacaoAtivaStream`.

Caminho: `usuarios/{motoristaUid}/localizacao_ativa/atual`

| Campo         | Tipo      | Observação                                     |
|---------------|-----------|---------------------------------------------------|
| `lat`/`lng`   | double    | posição GPS mais recente                            |
| `emRota`      | bool      | `true` enquanto a corrida está ativa                 |
| `atualizadoEm`| timestamp | `FieldValue.serverTimestamp()`, a cada posição nova  |

`atualizadoEm`/posição são atualizados a cada ~15 metros de movimento
(`distanceFilter` do `Geolocator.getPositionStream`), não em um intervalo
fixo — evita gravar no Firestore enquanto o motorista está parado.

**Quem pode ver a localização ao vivo de um motorista** é controlado por
`usuarios/{motoristaUid}/responsaveis_ativos/{responsavelUid}` — um
documento vazio (`{ativo: true}`) cujo ID É o uid do responsável,
justamente pra regra do Firestore conseguir checar com `exists()` (sem
precisar de uma query) se quem está pedindo pra ler já contratou esse
motorista. Gravado uma vez, no momento da contratação
(`registrarContratacao` em `tela_contratacao.dart`). Não existe fluxo de
"descontratar", então esse acesso não é revogado automaticamente hoje —
mesma limitação que já existia pras outras informações da contratação.

Regra do Firestore: só o próprio motorista escreve a localização; lê o
próprio motorista ou um responsável com `responsaveis_ativos` marcado.
Ninguém mais (nem outro motorista, nem um responsável que nunca
contratou) consegue ler a localização ao vivo de ninguém.

---

## 010 — `escolaLat`/`escolaLng` em `usuarios/{uid}/filhos` e em
## `contratacoes` — destino da rota

Criada em: 2026-10. O cálculo de rota (`RotaService`, ver seção acima
nunca existente até aqui — agora 100% local, sem API externa, veja o
código) precisava de uma coordenada final pra onde ir depois de pegar as
crianças; o campo `escola` (texto livre) nunca teve coordenada nenhuma, só
o nome digitado. Resolvido deixando o responsável marcar a localização da
escola no mapa, no cadastro do filho (`CadastrarFilhoTela`, reusa
`TelaSelecionarLocal` — um seletor de mapa genérico que só devolve a
coordenada escolhida, sem salvar nada sozinho, ao contrário de
`MapaCasaTela`).

- `usuarios/{uid}/filhos/{filhoId}`: `escolaLat`/`escolaLng` (double,
  opcionais — nulos se o responsável nunca marcou).
- `usuarios/{responsavelUid}/contratacoes/{contratacaoId}`:
  `escolaNome`/`escolaLat`/`escolaLng`, copiados no momento da
  contratação do primeiro filho selecionado que já tinha a localização da
  escola marcada (simplificação: assume que os filhos de uma mesma
  contratação vão pra escolas compatíveis com uma rota só).

Sem a localização da escola marcada em nenhum filho do período, a rota
calculada continua funcionando — só termina na última casa, sem saber pra
onde ir depois (a tela avisa isso quando acontece).
