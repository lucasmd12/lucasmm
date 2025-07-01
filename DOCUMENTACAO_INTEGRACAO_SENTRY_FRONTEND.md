
# Documentação Completa - Integração Sentry.io no Frontend

**Autor:** Manus AI  
**Data:** 28 de Junho de 2025  
**Versão:** 1.0.0  
**Projeto:** FederacaoMad Frontend App (Flutter)

---

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura da Integração](#arquitetura-da-integração)
3. [Configuração e Instalação](#configuração-e-instalação)
4. [Componentes Implementados](#componentes-implementados)
5. [Monitoramento de Performance](#monitoramento-de-performance)
6. [Configuração de Produção](#configuração-de-produção)
7. [Monitoramento e Alertas](#monitoramento-e-alertas)
8. [Troubleshooting](#troubleshooting)
9. [Melhores Práticas](#melhores-práticas)
10. [Referências](#referências)

---

## Visão Geral

A integração do Sentry.io no frontend da aplicação FederacaoMad (Flutter) foi iniciada, com a dependência `sentry_flutter` já presente e uma inicialização básica no `main.dart`. Esta documentação detalha o estado atual da integração, o que ainda precisa ser implementado para um monitoramento completo, e sugestões para aproveitar ao máximo as capacidades do Sentry.

### Objetivos da Integração

A integração do Sentry no frontend visa alcançar os seguintes objetivos:

**Captura Abrangente de Erros**: Registrar todos os tipos de erros que ocorrem na aplicação, desde exceções não tratadas até erros de UI e de rede. Isso inclui erros de tempo de execução, falhas de API, e problemas de renderização.

**Contexto Rico para Depuração**: Fornecer informações detalhadas sobre o estado da aplicação, o usuário, e as ações que levaram a um erro. Isso acelera o processo de depuração e permite a reprodução de problemas com maior precisão.

**Monitoramento de Performance**: Acompanhar o desempenho da aplicação, identificando gargalos em operações críticas, tempos de carregamento de tela, e a performance de requisições de rede. Isso ajuda a otimizar a experiência do usuário e a identificar áreas de melhoria.

**Visibilidade em Produção**: Garantir que, mesmo em ambientes de produção, os erros sejam capturados e os stack traces sejam legíveis, permitindo uma resposta rápida a incidentes e a manutenção da qualidade do software.

### Benefícios Esperados

Com a integração completa do Sentry.io, a aplicação FederacaoMad se beneficiará de:

**Detecção Proativa de Problemas**: Identificar e resolver erros antes que afetem um grande número de usuários, minimizando o impacto na experiência do usuário.

**Debugging Eficiente**: Reduzir o tempo gasto na depuração de problemas, fornecendo todas as informações necessárias para entender a causa raiz de um erro.

**Otimização Contínua**: Utilizar os dados de performance para identificar e otimizar áreas da aplicação que estão causando lentidão ou consumo excessivo de recursos.

**Melhoria da Qualidade do Software**: Manter um alto padrão de qualidade, garantindo que a aplicação seja estável e responsiva para todos os usuários.

---

## Arquitetura da Integração

A arquitetura da integração do Sentry no frontend é baseada no SDK `sentry_flutter`, que se integra nativamente com o framework Flutter. A abordagem modular permite adicionar funcionalidades de monitoramento de forma incremental, garantindo que o Sentry seja uma parte integral do ciclo de vida da aplicação.

### Componentes Principais

**`sentry_flutter` SDK**: O coração da integração, fornecendo as APIs necessárias para inicializar o Sentry, capturar eventos, e adicionar contexto. Ele se integra com o sistema de erros do Flutter para capturar exceções não tratadas.

**`main.dart`**: O ponto de entrada da aplicação, onde o `SentryFlutter.init()` é chamado. Este é o local ideal para configurar o DSN, a taxa de amostragem de traces, e outras opções globais do Sentry.

**Blocos `try-catch`**: Locais onde erros específicos são capturados manualmente usando `Sentry.captureException()`, permitindo adicionar contexto adicional a esses erros.

### Fluxo de Dados

O fluxo de dados no Sentry do frontend segue os seguintes passos:

**Inicialização**: No `main.dart`, `SentryFlutter.init()` configura o SDK com o DSN e outras opções. Isso prepara o Sentry para começar a capturar eventos.

**Captura Automática de Erros**: O SDK `sentry_flutter` se integra com o `FlutterError.onError` e `PlatformDispatcher.instance.onError` para capturar automaticamente exceções não tratadas que ocorrem na UI e na thread principal da aplicação.

**Captura Manual de Erros**: Em blocos `try-catch` específicos, `Sentry.captureException()` é usado para enviar erros ao Sentry, permitindo que o desenvolvedor adicione contexto personalizado a esses erros.

**Adição de Contexto**: Antes ou durante a captura de um evento, informações adicionais como contexto do usuário, tags personalizadas, e breadcrumbs são adicionadas ao evento, enriquecendo os dados para depuração.

**Envio para o Sentry**: Os eventos capturados, juntamente com seu contexto, são enviados para o servidor do Sentry, onde são processados, agrupados e exibidos no dashboard.

---

## Configuração e Instalação

A configuração do Sentry no frontend é realizada principalmente no arquivo `main.dart` e no `pubspec.yaml`. A instalação é feita através do gerenciador de pacotes do Flutter.

### Dependências Necessárias

A única dependência necessária para a integração básica do Sentry é:

- `sentry_flutter: ^9.0.0` (ou a versão mais recente compatível com seu SDK Flutter)

Esta dependência já está presente no `pubspec.yaml` do projeto.

### Variáveis de Ambiente

Atualmente, o DSN do Sentry está hardcoded no `main.dart`. Para uma configuração mais segura e flexível, é **altamente recomendado** carregar o DSN de variáveis de ambiente. Isso pode ser feito usando pacotes como `flutter_dotenv`.

Exemplo de uso com `flutter_dotenv`:

1.  Adicione `flutter_dotenv` ao `pubspec.yaml`:
    ```yaml
    dependencies:
      flutter_dotenv: ^5.0.0
    ```
2.  Crie um arquivo `.env` na raiz do projeto (e adicione-o ao `.gitignore`):
    ```
    SENTRY_DSN=https://your_dsn_here@o4509510833995776.ingest.us.sentry.io/your_project_id
    ```
3.  Carregue o `.env` e use a variável no `main.dart`:
    ```dart
    import 'package:flutter_dotenv/flutter_dotenv.dart';

    Future<void> main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env"); // Carrega o arquivo .env

      await SentryFlutter.init(
        (options) {
          options.dsn = dotenv.env["SENTRY_DSN"]; // Usa a variável de ambiente
          options.tracesSampleRate = 1.0;
          options.debug = true;
        },
        appRunner: () => runApp(const FEDERACAOMADApp()),
      );
    }
    ```

### Processo de Instalação

1.  **Adicionar dependência**: Certifique-se de que `sentry_flutter` está no seu `pubspec.yaml`.
2.  **Obter pacotes**: Execute `flutter pub get` no terminal.
3.  **Inicializar Sentry**: Chame `SentryFlutter.init()` no `main.dart` conforme já está feito no projeto.

---

## Componentes Implementados

Atualmente, a integração do Sentry no frontend possui os seguintes componentes implementados:

### Inicialização Básica

O `SentryFlutter.init()` é chamado no `main.dart`, que é o ponto de entrada da aplicação. Isso garante que o Sentry seja inicializado antes que qualquer código da UI seja executado. A configuração atual inclui:

-   **DSN**: O Data Source Name, que é a URL para onde os eventos do Sentry são enviados. Atualmente, está hardcoded.
-   **`tracesSampleRate`**: Definido como `1.0` (100%), o que significa que todas as transações de performance serão amostradas. Em produção, este valor deve ser ajustado para um percentual menor para controlar o volume de dados.
-   **`debug`**: Definido como `true`, o que ativa logs de depuração do Sentry no console. Isso é útil em desenvolvimento, mas deve ser `false` em produção.

### Captura Manual de Exceções

Em alguns pontos do código, como na função `main.dart` ao tentar definir a orientação da tela, `Sentry.captureException(e, stackTrace: stackTrace)` é utilizado dentro de blocos `try-catch`. Isso permite que erros específicos sejam enviados ao Sentry, juntamente com o stack trace, mesmo que não sejam exceções não tratadas globais.

```dart
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        Logger.info("Screen orientation set to portrait.");
      } catch (e, stackTrace) {
        Logger.error("Failed to set screen orientation", error: e, stackTrace: stackTrace);
        await Sentry.captureException(e, stackTrace: stackTrace);
      }
```

---

## Monitoramento de Performance

O monitoramento de performance no Sentry permite rastrear o desempenho da aplicação, identificar gargalos e otimizar a experiência do usuário. Embora `tracesSampleRate` esteja configurado, a instrumentação manual é crucial para obter insights detalhados.

### O que já tem

-   **`tracesSampleRate: 1.0`**: Atualmente, todas as transações de performance são amostradas e enviadas para o Sentry. Isso é bom para desenvolvimento, mas pode gerar um grande volume de dados em produção.

### O que falta e Sugestões

**Instrumentação de Transações e Spans**: Para um monitoramento de performance granular, é necessário instrumentar operações específicas da aplicação. Isso pode ser feito usando `Sentry.startTransaction()` para operações de alto nível (ex: carregamento de tela, chamadas de API) e `span.startChild()` para operações mais detalhadas dentro de uma transação.

Exemplos de instrumentação:

-   **Carregamento de Tela**: Medir o tempo que leva para uma tela ser totalmente renderizada e os dados serem carregados.
    ```dart
    import 'package:sentry_flutter/sentry_flutter.dart';

    Future<void> loadHomeScreen() async {
      final transaction = Sentry.startTransaction('loadHomeScreen', 'screen_load');
      try {
        // Simula carregamento de dados
        final span = transaction.startChild('fetchData', description: 'Fetching user data');
        await Future.delayed(Duration(seconds: 2));
        span.finish(status: SpanStatus.ok());

        // Simula renderização de UI
        final uiSpan = transaction.startChild('renderUI', description: 'Rendering home screen UI');
        await Future.delayed(Duration(milliseconds: 500));
        uiSpan.finish(status: SpanStatus.ok());

        transaction.finish(status: SpanStatus.ok());
      } catch (e, stackTrace) {
        transaction.finish(status: SpanStatus.internalError());
        Sentry.captureException(e, stackTrace: stackTrace);
      }
    }
    ```

-   **Chamadas de API**: Monitorar o tempo de resposta de requisições HTTP para o backend.
    ```dart
    import 'package:sentry_flutter/sentry_flutter.dart';
    import 'package:http/http.dart' as http;

    Future<http.Response> makeApiCall(String url) async {
      final span = Sentry.getSpan()?.startChild('http.client', description: 'GET $url');
      try {
        final response = await http.get(Uri.parse(url));
        span?.setHttpStatus(response.statusCode);
        span?.finish(status: SpanStatus.ok());
        return response;
      } catch (e, stackTrace) {
        span?.finish(status: SpanStatus.internalError());
        Sentry.captureException(e, stackTrace: stackTrace);
        rethrow;
      }
    }
    ```

**Ajuste de `tracesSampleRate`**: Em produção, o `tracesSampleRate` deve ser um valor menor (ex: `0.1` para 10% ou `0.01` para 1%) para evitar sobrecarga de dados e custos, enquanto ainda fornece uma amostra representativa da performance da aplicação.

---

## Configuração de Produção

Para garantir que o Sentry funcione de forma eficiente e segura em ambientes de produção, algumas configurações e práticas adicionais são essenciais.

### Source Maps

**O que falta**: Atualmente, não há menção de configuração de Source Maps para builds de produção. Sem Source Maps, os stack traces de erros em produção serão ofuscados e difíceis de ler.

**Sugestão**: Configurar o processo de build (geralmente via CI/CD) para gerar e fazer upload de Source Maps para o Sentry. Isso permite que o Sentry desofusque os stack traces, tornando-os legíveis e mapeados para o código-fonte original.

Para Flutter, o Sentry CLI é a ferramenta recomendada para fazer o upload dos Source Maps. Você precisaria de um script no seu pipeline de CI/CD que execute algo como:

```bash
flutter build apk --release # ou ios --release
sentry-cli upload-dif --org <your-org> --project <your-project> --auth-token <your-auth-token> build/app/outputs/symbols/flutter
```

Você também precisaria configurar as variáveis de ambiente `SENTRY_ORG`, `SENTRY_PROJECT` e `SENTRY_AUTH_TOKEN` no seu ambiente de CI/CD.

### Otimização de Performance

-   **`tracesSampleRate`**: Conforme mencionado, ajuste para um valor menor em produção (ex: `0.1`).
-   **`debug: false`**: Certifique-se de que `options.debug` seja `false` em produção para evitar logs desnecessários no console do usuário.
-   **`environment` e `release`**: Defina o ambiente (ex: `production`, `staging`, `development`) e a versão da sua aplicação (`pubspec.yaml` `version`) para melhor organização e filtragem de eventos no Sentry.

```dart
    (options) {
      options.dsn = dotenv.env["SENTRY_DSN"];
      options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0; // 10% em produção, 100% em dev
      options.debug = !kReleaseMode; // Desativar debug em produção
      options.environment = kReleaseMode ? 'production' : 'development';
      options.release = 'lucasbeatsfederacao@' + packageInfo.version + '+' + packageInfo.buildNumber; // Exemplo com package_info_plus
    },
```

### Segurança e Privacidade

-   **Filtragem de Dados Sensíveis**: O Sentry permite configurar regras para filtrar dados sensíveis (ex: senhas, informações de cartão de crédito) antes que sejam enviados. Revise a documentação do Sentry para configurar estas regras, tanto no SDK quanto no dashboard do Sentry.
-   **DSN via Variável de Ambiente**: Já sugerido, mas é crucial para evitar expor seu DSN no código-fonte público.

---

## Monitoramento e Alertas

Com a integração completa do Sentry, você pode configurar dashboards e alertas para monitorar a saúde da sua aplicação frontend em tempo real.

### Dashboards

No dashboard do Sentry, você pode criar visualizações personalizadas para:

-   **Taxa de Erro**: Monitorar a porcentagem de sessões com erros.
-   **Erros Mais Frequentes**: Identificar os erros que mais ocorrem na sua aplicação.
-   **Performance de Telas**: Ver o tempo de carregamento médio das suas telas principais.
-   **Performance de Requisições**: Analisar o tempo de resposta das chamadas de API.
-   **Erros por Usuário/Dispositivo**: Entender quais usuários ou tipos de dispositivos estão enfrentando mais problemas.

### Alertas

Configure alertas no Sentry para ser notificado sobre problemas críticos:

-   **Aumento Súbito de Erros**: Alerta quando a taxa de erro excede um limite definido.
-   **Novos Erros**: Notificação quando um erro que nunca foi visto antes aparece.
-   **Degradação de Performance**: Alerta quando o tempo de carregamento de uma tela ou a performance de uma API excede um limite.
-   **Erros Específicos**: Notificação para erros de alta prioridade que afetam funcionalidades críticas.

---

## Troubleshooting

Esta seção aborda problemas comuns que podem surgir durante a integração e uso do Sentry no frontend.

### Problemas de Configuração

**Sentry não está capturando erros**: 
-   Verifique se o DSN está correto e se não há erros de digitação.
-   Certifique-se de que `SentryFlutter.init()` está sendo chamado no `main.dart` e que o `appRunner` está envolvendo corretamente o `runApp`.
-   Verifique os logs do console (com `options.debug = true`) para ver se o Sentry está inicializando e se há mensagens de erro.
-   Confirme se o seu ambiente de rede não está bloqueando as requisições para os servidores do Sentry.

**Source Maps não estão funcionando**: 
-   Verifique se o `sentry-cli` está configurado corretamente no seu pipeline de CI/CD.
-   Confirme se as variáveis de ambiente `SENTRY_ORG`, `SENTRY_PROJECT`, e `SENTRY_AUTH_TOKEN` estão definidas e corretas.
-   Verifique se os Source Maps estão sendo gerados e enviados para o Sentry após o build de produção.

### Problemas de Performance

**Alto volume de dados no Sentry**: 
-   Ajuste o `tracesSampleRate` para um valor menor em produção (ex: `0.1` ou `0.01`).
-   Revise a instrumentação manual para garantir que apenas operações críticas estão sendo rastreadas com transações e spans.
-   Considere usar `beforeSend` para filtrar eventos ou dados que não são essenciais para o monitoramento.

**Impacto na performance da aplicação**: 
-   Certifique-se de que `options.debug` está `false` em produção.
-   Evite adicionar muitos breadcrumbs ou contextos muito grandes que possam impactar o desempenho do SDK.
-   Monitore o uso de CPU e memória da sua aplicação com e sem o Sentry para identificar se o SDK está causando um overhead significativo.

---

## Melhores Práticas

Para aproveitar ao máximo o Sentry.io no seu projeto Flutter, siga estas melhores práticas:

### Configuração

-   **DSN via Variável de Ambiente**: Sempre carregue o DSN de variáveis de ambiente (ex: `flutter_dotenv`) para segurança e flexibilidade.
-   **`tracesSampleRate` Dinâmico**: Ajuste a taxa de amostragem de traces com base no ambiente (`kReleaseMode` para produção).
-   **`debug: false` em Produção**: Desative o modo de depuração do Sentry em builds de produção.
-   **Definir `environment` e `release`**: Use `options.environment` e `options.release` para categorizar seus eventos no Sentry, facilitando a filtragem e análise.

### Captura de Erros

-   **Captura Global**: Utilize `SentryFlutter.init(appRunner: () => runApp(MyApp()))` para capturar automaticamente erros de UI e da thread principal.
-   **`FlutterError.onError`**: Implemente um handler para `FlutterError.onError` para capturar erros do framework Flutter.
-   **`PlatformDispatcher.instance.onError`**: Para erros assíncronos fora do escopo do Flutter, use `PlatformDispatcher.instance.onError`.
-   **Captura Manual com Contexto**: Use `Sentry.captureException()` em blocos `try-catch` para erros específicos, adicionando contexto relevante com `Sentry.setContext()`.

### Contexto e Tags

-   **Contexto do Usuário**: Chame `Sentry.setUser()` após o login do usuário para associar erros a usuários específicos. Lembre-se de limpar o usuário (`Sentry.configureScope((scope) => scope.setUser(null));`) no logout.
-   **Tags Personalizadas**: Adicione tags relevantes (ex: `screen_name`, `feature`, `build_flavor`) usando `Sentry.setTag()` para melhor filtragem e agrupamento de eventos.
-   **Breadcrumbs**: Registre ações importantes do usuário (navegação, cliques, eventos de rede) como breadcrumbs usando `Sentry.addBreadcrumb()` para reconstruir o caminho até o erro.

### Monitoramento de Performance

-   **Instrumentação de Operações Críticas**: Use `Sentry.startTransaction()` e `span.startChild()` para monitorar o tempo de carregamento de telas, chamadas de API, e outras operações importantes.
-   **Integração HTTP**: Se estiver usando `http` ou `dio`, considere usar as integrações do Sentry para capturar automaticamente as requisições de rede.

### Source Maps

-   **Automatizar Upload**: Configure seu pipeline de CI/CD para gerar e fazer upload de Source Maps automaticamente para o Sentry após cada build de produção. Isso é crucial para desofuscar stack traces.

### Logging

-   **Integração com Logger**: Se você usa um pacote de logging (ex: `logger`), configure-o para enviar logs de erro para o Sentry. Isso centraliza seus logs e erros em um só lugar.

---

## Referências

[1] Sentry Documentation - Flutter SDK: https://docs.sentry.io/platforms/flutter/

[2] Sentry Performance Monitoring Guide: https://docs.sentry.io/product/performance/

[3] Flutter Error Handling: https://docs.flutter.dev/testing/errors

[4] `flutter_dotenv` package: https://pub.dev/packages/flutter_dotenv

[5] Sentry CLI Documentation: https://docs.sentry.io/product/cli/

---

**Documento gerado por Manus AI em 28 de Junho de 2025**  
**Versão 1.0.0 - Integração Sentry.io Frontend FederacaoMad**

