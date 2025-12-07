# Guia de Configuração Supabase - MoodJournal

## ✅ O que foi implementado

### 1. Entidades e Arquitetura
- **UserProfileEntity**: perfil com nome, email, foto
- **MoodEntryEntity**: registros de humor (nível 1-5, notas, tags)
- **DailyGoalEntity**: metas diárias por tipo
- **MoodStatisticsEntity**: estatísticas agregadas

### 2. Camadas Clean Architecture
- **Domain**: entidades puras + interfaces de repositórios
- **Data**: 
  - DataSources locais (SharedPreferences)
  - DataSources remotos (Supabase)
  - Repositórios concretos (merge local+remoto)
- **Providers**: Riverpod StateNotifiers para UI

### 3. Autenticação
- Tela de login/cadastro (`lib/screens/auth_screen.dart`)
- Integração com Supabase Auth (email+senha+nome)
- Auto-criação de perfil via trigger SQL
- Navegação condicional no splash (redireciona para `/auth` se não autenticado)

### 4. Sync Incremental
- `loadFromCache()`: render instantâneo da UI
- `syncFromServer()`: atualiza apenas dados novos/modificados desde lastSync
- Merge inteligente por ID para evitar duplicatas

## 📋 Setup Passo a Passo

### Passo 1: Criar projeto no Supabase
1. Acesse [https://supabase.com](https://supabase.com)
2. Crie uma conta e um novo projeto
3. Anote a **URL** e **anon/public key** em Settings → API

### Passo 2: Executar script SQL
1. No Supabase Dashboard, vá em **SQL Editor**
2. Cole todo o conteúdo de `supabase_setup.sql` (na raiz do projeto)
3. Execute (Run)
4. Verifique se as tabelas foram criadas em **Table Editor**

### Passo 3: Configurar .env local
Crie ou atualize o arquivo `.env` na raiz do projeto:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-aqui
DEBUG_MODE=true
```

⚠️ **Importante**: nunca comite o `.env` com chaves reais no Git!

### Passo 4: Instalar dependências
```powershell
flutter pub get
```

### Passo 5: Rodar o app
```powershell
flutter run -d chrome
```

## 🧪 Testar Funcionalidades

### 1. Cadastro
- Na tela inicial, clique em "Cadastrar"
- Preencha: nome, email, senha (min 6 caracteres)
- Após cadastro, será redirecionado para `/home`
- Verifique no Supabase → Table Editor → `user_profiles` se o registro foi criado

### 2. Login
- Use email e senha cadastrados
- Deve redirecionar para `/home`

### 3. Criar Mood Entry (exemplo manual)
Use o provider no código:
```dart
final notifier = ref.read(moodEntriesNotifierProvider.notifier);
await notifier.addEntry(MoodEntryEntity(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  level: MoodLevel.happy,
  timestamp: DateTime.now(),
  note: 'Teste',
));
```

### 4. Verificar Sync
- Dados ficam no cache local (SharedPreferences)
- Ao chamar `syncFromServer()`, busca mudanças do Supabase
- Em outro dispositivo/navegador, faça login → dados sincronizam automaticamente

## 🗂️ Estrutura de Arquivos Criados

```
lib/
├── features/
│   ├── mood_entries/domain/repositories/mood_entry_repository.dart
│   ├── daily_goals/domain/repositories/daily_goal_repository.dart
│   ├── user_profiles/domain/repositories/user_profile_repository.dart
│   └── mood_statistics/domain/repositories/mood_statistics_repository.dart
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── mood_entry_local_datasource.dart
│   │   │   └── daily_goal_local_datasource.dart
│   │   ├── remote/
│   │   │   ├── mood_entry_remote_datasource.dart
│   │   │   ├── daily_goal_remote_datasource.dart
│   │   │   └── user_profile_datasource.dart (Supabase)
│   │   └── supabase/ (datasources alternativos)
│   └── repositories/
│       ├── mood_entry_repository_impl.dart
│       └── daily_goal_repository_impl.dart
├── providers/
│   ├── mood_entry_provider.dart
│   └── daily_goal_provider.dart
├── screens/
│   └── auth_screen.dart
└── domain/entities/
    └── mood_statistics_entity.dart (novo)

supabase_setup.sql (raiz do projeto)
```

## 🔧 Debugging

### Problema: "Supabase não configurado"
- Verifique se `.env` existe e tem SUPABASE_URL + SUPABASE_ANON_KEY
- Rode `flutter clean` e `flutter pub get`

### Problema: "RLS policy violation"
- Certifique-se de estar autenticado (`SupabaseService.isAuthenticated`)
- Verifique se o `user_id` enviado corresponde ao `auth.uid()` atual

### Problema: "Dados não aparecem"
- Adicione prints/logs nos repositórios (já incluídos com `kDebugMode`)
- Verifique console do Flutter para mensagens `[MoodEntryRepo]`
- Inspecione `Table Editor` no Supabase para confirmar inserções

### Problema: Lint warnings
- Imports "não usados" podem ser falsos positivos do analyzer
- Se o código compila, ignore (ou execute `dart fix --apply`)

## 🚀 Próximos Passos

1. **Integrar telas existentes**: atualizar `HomeScreen` para usar `moodEntriesNotifierProvider`
2. **Adicionar offline-first completo**: queue de mudanças pendentes quando offline
3. **Implementar UserProfile e MoodStatistics** da mesma forma (repos + providers)
4. **Testes**: criar `FakeMoodEntryRepository` para testes unitários
5. **Melhorar UX**: loading states, erro handling, retry automático

## 📚 Referências

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Riverpod Docs](https://riverpod.dev)
- Prompts no projeto: `prompts/14_providers_repository_prompt.md`

---

**Resumo**: Agora você tem auth completo, sync bidirecional (local+Supabase), e base para adicionar as telas de UI. Rode o SQL no Supabase, configure o `.env`, e teste!
