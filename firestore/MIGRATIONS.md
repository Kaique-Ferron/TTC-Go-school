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
