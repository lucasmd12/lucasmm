## TABELA SENTRY.IO FRONTEND

| Item | O que já tem? | O que falta? | Sugestão para aproveitar o máximo da ferramenta Sentry.io no Frontend |
|---|---|---|---|
| **Configuração Básica** | `sentry_flutter` adicionado como dependência em `pubspec.yaml`. `SentryFlutter.init()` chamado em `main.dart` com `dsn` e `tracesSampleRate: 1.0`. | O DSN está hardcoded no código. | Carregar o DSN de variáveis de ambiente (ex: `dotenv` ou `flutter_dotenv`) para maior segurança e flexibilidade entre ambientes. Reduzir `tracesSampleRate` em produção (ex: `0.1` ou `0.01`) para controlar o volume de dados. |
| **Captura de Erros** | `Sentry.captureException(e, stackTrace: stackTrace)` é usado em alguns blocos `try-catch` (ex: `main.dart` ao definir orientação da tela). | Captura automática de erros não tratados em todo o aplicativo. | Utilizar `SentryFlutter.runApp()` para envolver o `runApp` e capturar automaticamente erros de UI e de thread principal. Implementar `FlutterError.onError` para capturar erros do framework. |
| **Contexto do Usuário** | Não há configuração explícita para adicionar contexto do usuário. | Identificação do usuário que causou o erro. | Após o login do usuário, usar `Sentry.setUser({ id: user.id, email: user.email, username: user.username })` para associar erros a usuários específicos. |
| **Tags Personalizadas** | Não há configuração explícita para tags personalizadas. | Filtragem e agrupamento de eventos por tags relevantes. | Adicionar tags personalizadas (ex: `environment`, `release`, `user_role`, `screen_name`) usando `Sentry.setTag("key", "value")` para melhor organização e análise dos eventos. |
| **Breadcrumbs** | Não há registro explícito de breadcrumbs. | Rastreamento de ações do usuário antes de um erro. | Registrar ações importantes do usuário (navegação, cliques em botões, eventos de rede) como breadcrumbs usando `Sentry.addBreadcrumb()`. |
| **Monitoramento de Performance** | `tracesSampleRate: 1.0` está ativado, mas não há instrumentação manual de transações/spans. | Monitoramento granular de operações específicas (ex: chamadas de API, inicialização de módulos). | Utilizar `Sentry.startTransaction()` e `span.startChild()` para instrumentar operações críticas e obter insights detalhados sobre gargalos de performance. |
| **Source Maps** | Não há menção de configuração de Source Maps para builds de produção. | Tradução de stack traces ofuscados para o código-fonte original. | Configurar o processo de build (ex: CI/CD) para gerar e fazer upload de Source Maps para o Sentry, garantindo que os stack traces sejam legíveis em produção. |
| **Níveis de Log** | Não há integração direta com um logger para enviar logs para o Sentry. | Envio de logs de diferentes níveis (info, warn, error) para o Sentry. | Integrar com um pacote de logging (ex: `logger` ou `logging`) e configurar um transporte Sentry para enviar logs de diferentes níveis. |
| **Captura de Eventos de Rede** | Não há captura explícita de requisições de rede. | Visibilidade sobre falhas e performance de requisições HTTP. | Utilizar a integração HTTP do Sentry (se disponível para `http` ou `dio`) ou instrumentar manualmente as chamadas de API para capturar informações sobre requisições e respostas. |
| **Contexto Adicional** | Contexto limitado, apenas erros capturados explicitamente. | Adicionar contexto relevante a todos os eventos. | Usar `Sentry.setContext("key", { data: value })` para adicionar informações adicionais que podem ser úteis para depuração, como estado da aplicação, configurações, etc. |

**Resumo:**

O projeto frontend já possui a dependência `sentry_flutter` e uma inicialização básica do Sentry.io. No entanto, para um **aproveitamento máximo da ferramenta**, é crucial:

1.  **Melhorar a configuração inicial** (DSN via ambiente, `tracesSampleRate` dinâmico).
2.  **Garantir a captura abrangente de erros** (erros de UI, framework, e não tratados).
3.  **Enriquecer o contexto dos eventos** com informações do usuário, tags e breadcrumbs.
4.  **Implementar monitoramento de performance** para operações críticas.
5.  **Configurar Source Maps** para depuração eficaz em produção.
6.  **Integrar com o sistema de logging** para centralizar os logs no Sentry.
7.  **Capturar eventos de rede** para visibilidade completa das interações com o backend.

