# Configuração do Supabase

Este documento explica como configurar o Supabase para sincronização de dados do app.

## 1. Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Crie uma conta ou faça login
3. Clique em "New Project"
4. Preencha os dados:
   - **Name**: emilly-mood-journal (ou outro nome)
   - **Database Password**: Crie uma senha forte e guarde
   - **Region**: Escolha a mais próxima (ex: South America (São Paulo))
5. Clique em "Create new project" e aguarde ~2 minutos

## 2. Obter Credenciais

1. No dashboard do projeto, vá em **Settings** → **API**
2. Copie as seguintes informações:
   - **Project URL**: `https://seu-projeto.supabase.co`
   - **anon public key**: Uma chave longa começando com `eyJ...`

## 3. Configurar o Arquivo .env

1. Abra o arquivo `.env` na raiz do projeto
2. Cole as credenciais:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DEBUG_MODE=false
```

3. Salve o arquivo
4. **IMPORTANTE**: Nunca faça commit do `.env` no Git (já está no `.gitignore`)

## 4. Criar Tabelas no Banco de Dados

No Supabase, vá em **SQL Editor** e execute os seguintes comandos:

### 4.1. Tabela de Perfis de Usuário

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  photo_url TEXT,
  preferences JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id)
);

-- Índice para busca rápida por user_id
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security) - Usuários só veem seus próprios dados
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);
```

### 4.2. Tabela de Registros de Humor

```sql
CREATE TABLE mood_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  mood_level INTEGER NOT NULL CHECK (mood_level >= 1 AND mood_level <= 5),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  activities TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Índices para busca rápida
CREATE INDEX idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX idx_mood_entries_date ON mood_entries(date DESC);
CREATE INDEX idx_mood_entries_updated_at ON mood_entries(updated_at DESC);

-- Trigger para updated_at
CREATE TRIGGER update_mood_entries_updated_at BEFORE UPDATE ON mood_entries
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE mood_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own mood entries"
  ON mood_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mood entries"
  ON mood_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own mood entries"
  ON mood_entries FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own mood entries"
  ON mood_entries FOR DELETE
  USING (auth.uid() = user_id);
```

### 4.3. Tabela de Metas Diárias

```sql
CREATE TABLE daily_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  goal_type TEXT NOT NULL,
  target_value INTEGER NOT NULL DEFAULT 1,
  current_value INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Índices
CREATE INDEX idx_daily_goals_user_id ON daily_goals(user_id);
CREATE INDEX idx_daily_goals_is_active ON daily_goals(is_active);
CREATE INDEX idx_daily_goals_updated_at ON daily_goals(updated_at DESC);

-- Trigger para updated_at
CREATE TRIGGER update_daily_goals_updated_at BEFORE UPDATE ON daily_goals
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE daily_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own daily goals"
  ON daily_goals FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily goals"
  ON daily_goals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily goals"
  ON daily_goals FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own daily goals"
  ON daily_goals FOR DELETE
  USING (auth.uid() = user_id);
```

## 5. Testar a Conexão

Execute o app e verifique no console:
- ✅ Se aparecer "⚠️ Supabase não configurado": Configure o .env corretamente
- ✅ Se não aparecer erro: Supabase conectado com sucesso!

## 6. Funcionamento Offline-First

O app funciona assim:

### Modo Offline
- ✅ Todos os dados são salvos em `SharedPreferences` (cache local)
- ✅ App continua funcionando normalmente
- ✅ Mudanças ficam na fila de sincronização

### Modo Online
- 🔄 Sincroniza automaticamente quando há conexão
- 🔄 Envia mudanças locais para o Supabase
- 🔄 Baixa mudanças do Supabase para o cache local
- ✅ Dados ficam consistentes entre dispositivos

### Estratégia Cache-First
1. **Leitura**: Sempre do cache local (rápido)
2. **Escrita**: Salva local primeiro (sempre funciona)
3. **Sincronização**: Em background quando online

## 7. Resolução de Conflitos

Quando há conflitos (mesma entidade modificada em 2 dispositivos):
- 🕒 **Last-Write-Wins**: Timestamp mais recente vence
- ✅ Campo `updated_at` determina a versão mais atual

## 8. Segurança

### Row Level Security (RLS)
- ✅ Cada usuário só acessa seus próprios dados
- ✅ Políticas SQL garantem isolamento
- ✅ Impossível ver/modificar dados de outros usuários

### Chaves
- 🔑 **ANON_KEY**: Chave pública, pode ir no app
- 🔒 **SERVICE_ROLE_KEY**: NUNCA usar no app, apenas backend

## 9. Monitoramento

No dashboard do Supabase você pode ver:
- 📊 **Database**: Número de registros, espaço usado
- 📈 **Auth**: Usuários cadastrados (se implementar login)
- 🔍 **Logs**: Queries executadas, erros
- ⚡ **API**: Requisições por segundo

## 10. Custo

### Plano Free (atual)
- ✅ 500MB de banco de dados
- ✅ 1GB de armazenamento de arquivos
- ✅ 2GB de largura de banda
- ✅ 50.000 usuários ativos mensais
- ✅ 500.000 requisições Edge Functions

**Suficiente para uso pessoal e testes!**

## 11. Próximos Passos (Opcional)

### Autenticação
- Implementar login/signup
- Sincronização entre dispositivos do mesmo usuário

### Storage
- Upload de fotos de perfil para Supabase Storage
- Backup de imagens em nuvem

### Realtime
- Atualização automática quando dados mudam no Supabase
- Sincronização instantânea entre dispositivos

---

**Dúvidas?** Consulte a [documentação oficial do Supabase](https://supabase.com/docs).
