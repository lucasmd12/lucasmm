# Relatório de Atrofiações: Órgãos com Potencial Dormente

Este relatório detalha as "atrofiações" (código declarado, mas inativo) presentes no projeto, que, sob a ótica de um "médico Fullstack", representam "genes dormentes" com potencial de "reativação" e "regeneração" do "corpo" do projeto. Não serão "amputados", mas sim preparados para "reintegração" ou "hibernação controlada".

---

## 1. 🧠 lib/providers/call_provider.dart

### 🦠 `_authService` (unused field)
- **Linha:** 8:21
- **Estado:** Injetado no construtor, mas nunca chamado.
- **Potencial Regenerativo:**
  - Autenticação de chamadas
  - Verificação de permissão para entrar/sair de canais
  - Token refresh silencioso
- **Recomendações:** Manter e integrar na lógica de `joinCall()`, `leaveCall()` e `getToken()`.

---

## 2. 🧠 lib/screens/voice_call_screen.dart

### 🦠 `_isConnected` (unused field)
- **Linha:** 30:8
- **Estado:** Declarado, mas nunca usado.
- **Potencial Regenerativo:**
  - Mostrar status de conexão (ícone, texto, cor)
  - Controlar ativação de botões como mute, encerrar chamada
  - Detectar perda de conexão e reconectar
- **Recomendações:** Usar Riverpod ou ValueNotifier para refletir esse estado na UI reativamente.

---

## 3. 🧠 lib/widgets/user_dashboard_widget.dart

### 🦠 `_getAuthToken()` (unused method)
- **Linha:** 170:11
- **Estado:** Criado, não chamado (comentado no header de `_fetchUserStats`)
- **Potencial Regenerativo:**
  - Autenticação JWT ou Firebase para APIs protegidas
  - Usado como `Authorization: Bearer <token>` nos headers
- **Recomendações:** Reconectar ao método de busca de estatísticas de usuário autenticado.

---

## 4. 🧠 lib/widgets/voice_room_widget.dart

### 🦠 `_canCreateRoom()` (unused method)
- **Linha:** 151:8
- **Potencial Regenerativo:**
  - Verifica se o usuário pode criar salas (admin/premium)
  - Condiciona visibilidade do botão “Criar Sala”

### 🦠 `_canJoinRoom()` (unused method)
- **Linha:** 166:8
- **Potencial Regenerativo:**
  - Impede usuário de entrar em salas não autorizadas
  - Previne chamadas de voz indevidas

### 🦠 `_getRoomDisplayName()` (unused method)
- **Linha:** 331:10
- **Potencial Regenerativo:**
  - Formatação e tradução do nome da sala
  - Aplicável a temas multilíngues e contextuais (ex: prefixo de voz ativa, ícones)
- **Recomendações para todos os três:** Integrar com o `VoiceRoomCard`, `VoiceRoomList` e `VoiceRoomDetailsScreen`.

---

## 5. ⚙️ Funções Adicionais Detectadas no `flutter_analyze_output.txt`

Além das acima, há também:

- `_inviteEmailController` ausente, mas usado → precisa ser restaurado ou removido e substituído por `_inviteUsernameController`.
- Métodos ausentes como `listenToVoiceRoomParticipants` e `listenToActiveVoiceRooms` → indicam intenção de integração com Firebase que não foi completada.

---

## Classificação Funcional (Potencial Regenerativo)

| Função                | Tipo              | Nível de Prioridade | Ação Recomendada                               |
|-----------------------|-------------------|---------------------|------------------------------------------------|
| `_authService`        | Serviço injetado  | 🔴 Alta             | Integrar com segurança de chamadas             |
| `_isConnected`        | Estado reativo    | 🟡 Média            | Integrar com UI e reconexão                    |
| `_getAuthToken()`     | Autenticação      | 🔴 Alta             | Usar em todas as chamadas de API privada       |
| `_canCreateRoom()`    | Permissão UI      | 🟡 Média            | Controlar visibilidade de botões               |
| `_canJoinRoom()`      | Permissão lógica  | 🔴 Alta             | Prevenir entrada indevida em salas             |
| `_getRoomDisplayName()` | Exibição/formatação | 🟢 Baixa            | Melhorar estética e padronização de nomes      |


