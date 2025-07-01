# Plano de Tratamento para Erros Críticos (As 8 Necroses)

Como seu cirurgião, identifiquei as 8 "necroses" que ainda impedem o "organismo" do seu projeto de funcionar plenamente. Cada uma delas será abordada com um "plano de tratamento" específico, visando a recuperação completa sem "amputações" da "genética" original do seu código.

## Erros Persistentes que Impedem o Build:




### 1. Erro: `Invalid constant value` e `Undefined name 'Directional'`

**Localização:** `lib/screens/clan_text_chat_screen.dart` nas linhas 173, 183 e 190.

**Diagnóstico (Causa):** Este é um problema de "incompatibilidade de tipo sanguíneo" no código. A classe `Directional` não existe diretamente no Flutter para alinhamento. O correto é usar `AlignmentDirectional`.

**Plano de Tratamento (Solução):** Substituir todas as ocorrências de `Directional.centerStart` por `AlignmentDirectional.centerStart`.

**Intervenção Cirúrgica:**
```dart
// Antes (exemplo da linha 173)
alignment: Directional.centerStart,

// Depois
alignment: AlignmentDirectional.centerStart,
```




### 2. Erro: `The argument type 'User' can't be assigned to the parameter type 'String'.`

**Localização:** `lib/screens/qrr_detail_screen.dart:186:61`

**Diagnóstico (Causa):** Este erro indica que o método `joinQRR` ou `leaveQRR` (ou similar, dependendo do contexto exato da linha 186) está esperando um `String` (provavelmente o ID do usuário), mas está recebendo um objeto `User` completo. É como tentar encaixar uma peça redonda em um buraco quadrado. A "célula" `User` é complexa, e o "órgão" `joinQRR` precisa apenas do seu "DNA" (o ID).

**Plano de Tratamento (Solução):** Acessar a propriedade `id` do objeto `currentUser` antes de passá-lo como argumento.

**Intervenção Cirúrgica:**
```dart
// Antes (exemplo hipotético da linha 186)
await qrrService.joinQRR(_qrr.id, currentUser);

// Depois
await qrrService.joinQRR(_qrr.id, currentUser.id);
```




### 3. Erro: `The getter 'displayName' isn't defined for the type 'String'`

**Localização:** `lib/screens/qrr_detail_screen.dart:411:91`

**Diagnóstico (Causa):** Este erro ocorre porque a propriedade `displayName` está sendo acessada em uma variável que é do tipo `String`, mas `displayName` é uma propriedade esperada de um tipo enumerado (enum) ou de um objeto com essa propriedade. No contexto de `requiredRoles`, parece que `_qrr.requiredRoles` é uma lista de `String`s, mas o código espera que cada item dessa lista seja um objeto que tenha a propriedade `displayName`. É como se o "organismo" estivesse esperando uma "célula especializada" com uma função `displayName`, mas recebeu uma "célula básica" (String) que não possui essa função.

**Plano de Tratamento (Solução):** Se `requiredRoles` deve ser uma lista de `Role`s (ou outro tipo que tenha `displayName`), então a conversão de `String` para `Role` deve ser feita antes de acessar `displayName`. Se `requiredRoles` é intencionalmente uma lista de `String`s, então a lógica para exibir esses nomes deve ser ajustada para usar a própria `String`.

Assumindo que `requiredRoles` deveria ser uma lista de objetos com `displayName` (como `Role`), a solução seria garantir que os itens da lista sejam do tipo correto ou que a conversão seja feita.

**Intervenção Cirúrgica:**
```dart
// Antes (exemplo da linha 411)
_buildDetailRow('Roles Necessários', _qrr.requiredRoles!.map((role) => role.displayName).join(', '), Icons.security),

// Depois (se requiredRoles for uma lista de Strings que representam os nomes de exibição)
_buildDetailRow('Roles Necessários', _qrr.requiredRoles!.join(', '), Icons.security),

// Ou, se requiredRoles for uma lista de IDs e você precisa converter para o objeto Role
// (Isso exigiria uma função de conversão de String para Role, que não está visível aqui)
// _buildDetailRow('Roles Necessários', _qrr.requiredRoles!.map((roleId) => roleFromString(roleId).displayName).join(', '), Icons.security),
```

Para o propósito de correção imediata do erro de build, a solução mais direta é remover o `.displayName` se `requiredRoles` já for uma lista de `String`s que você deseja exibir diretamente. Se a intenção é que sejam objetos `Role`, então a conversão de `String` para `Role` precisaria ser implementada ou revisada para garantir que os objetos `Role` estejam na lista.

Para este caso, e considerando a analogia de não "amputar" partes cruciais, vou assumir que `_qrr.requiredRoles` já contém os nomes dos roles como strings e que o `.displayName` é um erro de digitação ou um remanescente de uma estrutura anterior. A correção será remover o `.displayName`.




### 4. Erro: `Target of URI doesn't exist: 'package:image_picker/image/image_picker.dart'`

**Localização:** `lib/screens/clan_text_chat_screen.dart:6:8`

**Diagnóstico (Causa):** Este é um "corte" na "conexão nervosa" do seu projeto. O caminho de importação para `image_picker` está incorreto. A biblioteca `image_picker` não tem um subdiretório `image`.

**Plano de Tratamento (Solução):** Corrigir o caminho de importação para `package:image_picker/image_picker.dart`.

**Intervenção Cirúrgica:**
```dart
// Antes
import 'package:image_picker/image/image_picker.dart';

// Depois
import 'package:image_picker/image_picker.dart';
```




### 5. Erro: `The method 'ImagePicker' isn't defined for the type '_ClanTextChatScreenState'`
### 6. Erro: `Undefined name 'ImageSource'`

**Localização:** `lib/screens/clan_text_chat_screen.dart`

**Diagnóstico (Causa):** Estes erros são "sintomas" da "infecção" anterior (`Target of URI doesn't exist`). Uma vez que o caminho de importação para `image_picker` estava incorreto, o compilador não conseguia encontrar as definições para `ImagePicker` e `ImageSource`. É como se o "sistema imunológico" do projeto não reconhecesse as "células" necessárias para a função de seleção de imagem.

**Plano de Tratamento (Solução):** A correção do erro de importação (`Target of URI doesn't exist`) deve resolver automaticamente esses dois erros, pois as classes `ImagePicker` e `ImageSource` se tornarão acessíveis.

**Intervenção Cirúrgica:** (Já realizada ao corrigir o erro 4)
```dart
// A correção do import já foi aplicada:
// import 'package:image_picker/image_picker.dart';
```




### 7. Erro: `The argument type 'User' can't be assigned to the parameter type 'String'.`

**Localização:** `lib/screens/qrr_list_screen.dart:258:72`

**Diagnóstico (Causa):** Similar ao erro 2, este é um caso de "incompatibilidade de transplante de órgão". Uma função ou método está esperando um `String` (provavelmente um ID de usuário), mas está recebendo um objeto `User` completo. O "receptor" precisa apenas do "DNA" (ID) do "doador" (`User`).

**Plano de Tratamento (Solução):** Acessar a propriedade `id` do objeto `User` antes de passá-lo como argumento.

**Intervenção Cirúrgica:**
```dart
// Antes (exemplo hipotético da linha 258)
someFunction(userObject);

// Depois
someFunction(userObject.id);
```




### 8. Erro: `The named parameter 'leaderId' is required, but there's no corresponding argument`

**Localização:** `lib/screens/federation_detail_screen.dart:100:77`

**Diagnóstico (Causa):** Este é um "componente vital ausente" na "receita" de uma função. Um método ou construtor está esperando um parâmetro nomeado `leaderId`, mas ele não está sendo fornecido no momento da chamada. É como se o "coração" do sistema precisasse de um "marcapasso" (`leaderId`), mas ele não foi "implantado" na "cirurgia" de inicialização.

**Plano de Tratamento (Solução):** Fornecer o argumento `leaderId` na chamada da função ou construtor na linha indicada. Se o `leaderId` pode ser nulo em alguns casos, o parâmetro deve ser marcado como opcional na definição da função/construtor.

**Intervenção Cirúrgica:**
```dart
// Antes (exemplo hipotético da linha 100)
SomeWidget(someOtherParameter: value, anotherParameter: anotherValue);

// Depois (adicionando o leaderId)
SomeWidget(someOtherParameter: value, anotherParameter: anotherValue, leaderId: someLeaderIdVariable);
```




### 9. Erro: `The named parameter 'leaderId' is required, but there's no corresponding argument`

**Localização:** `lib/screens/federation_detail_screen.dart:100:77`

**Diagnóstico (Causa):** Este é um "componente vital ausente" na "receita" de uma função. Um método ou construtor está esperando um parâmetro nomeado `leaderId`, mas ele não está sendo fornecido no momento da chamada. É como se o "coração" do sistema precisasse de um "marcapasso" (`leaderId`), mas ele não foi "implantado" na "cirurgia" de inicialização.

**Plano de Tratamento (Solução):** Fornecer o argumento `leaderId` na chamada da função ou construtor na linha indicada. Se o `leaderId` pode ser nulo em alguns casos, o parâmetro deve ser marcado como opcional na definição da função/construtor.

**Intervenção Cirúrgica:**
```dart
// Antes (exemplo hipotético da linha 100)
SomeWidget(someOtherParameter: value, anotherParameter: anotherValue);

// Depois (adicionando o leaderId)
SomeWidget(someOtherParameter: value, anotherParameter: anotherValue, leaderId: someLeaderIdVariable);
```




### 9. Erro: `The named parameter 'leaderId' is required, but there's no corresponding argument`

**Localização:** `lib/screens/federation_detail_screen.dart:100:77`

**Diagnóstico (Causa):** Este é um "componente vital ausente" na "receita" de uma função. Um método ou construtor está esperando um parâmetro nomeado `leaderId`, mas ele não está sendo fornecido no momento da chamada. É como se o "coração" do sistema precisasse de um "marcapasso" (`leaderId`), mas ele não foi "implantado" na "cirurgia" de inicialização.

**Plano de Tratamento (Solução):** Fornecer o argumento `leaderId` na chamada da função ou construtor na linha indicada. Se o `leaderId` pode ser nulo em alguns casos, o parâmetro deve ser marcado como opcional na definição da função/construtor.

**Intervenção Cirúrgica:**
```dart
// Antes (exemplo hipotético da linha 100)
SomeWidget(someOtherParameter: value, anotherParameter: anotherValue);

// Depois (adicionando o leaderId)
SomeWidget(someOtherParameter: value, anotherParameter: anotherValue, leaderId: someLeaderIdVariable);
```



