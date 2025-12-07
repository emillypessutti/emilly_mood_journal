# Prompt: Construção da Entidade UserProfileEntity

## Contexto

A entidade `UserProfileEntity` representa o perfil do usuário no aplicativo MoodJournal. Armazena informações pessoais como nome, email, foto de perfil e datas de criação/atualização. Inclui um Value Object `Email` para garantir a validação do email.

## Localização

- **Entity**: `lib/domain/entities/user_profile_entity.dart`
- **DTO**: `lib/data/dtos/user_profile_dto.dart`
- **Mapper**: `lib/data/mappers/user_profile_mapper.dart`
- **Repository Interface**: `lib/domain/repositories/user_profile_repository.dart` *(a implementar)*
- **Repository Implementation**: `lib/data/repositories/user_profile_repository_impl.dart` *(a implementar)*
- **Data Source**: `lib/data/datasources/user_profile_local_datasource.dart` *(a implementar)*
- **Use Cases**: `lib/domain/usecases/user_profile/`
  - `get_user_profile.dart`
  - `create_user_profile.dart`
  - `update_user_profile.dart`
  - `update_profile_photo.dart`
  - `delete_user_profile.dart`

## Estrutura da Entidade

### Campos Obrigatórios

- `id` (String): Identificador único do perfil (não pode ser vazio)
- `name` (String): Nome do usuário (2-100 caracteres, não pode ser vazio)
- `email` (Email): Email do usuário (Value Object com validação)
- `createdAt` (DateTime): Data de criação do perfil

### Campos Opcionais

- `photoUrl` (String?): URL ou caminho da foto de perfil (padrão: null)
- `lastUpdated` (DateTime?): Data da última atualização (padrão: null)

### Métodos e Getters

- `copyWith()`: Cria uma cópia da entidade com campos modificados
- `hasValidName` (getter): Verifica se o nome tem pelo menos 2 letras
- `hasPhoto` (getter): Verifica se tem foto de perfil
- `initials` (getter): Retorna iniciais do nome (até 2 caracteres)
- `isComplete` (getter): Verifica se perfil está completo (nome válido + email válido)

### Value Object Email

- `value` (String): Valor do email validado
- `isValid` (getter): Verifica se email é válido
- `domain` (getter): Retorna o domínio do email
- Validação via regex no construtor

## Regras de Construção

### 1. Entity (Domain Layer)

```dart
// lib/domain/entities/user_profile_entity.dart
class UserProfileEntity {
  final String id;
  final String name;
  final Email email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.lastUpdated,
  })  : assert(id.isNotEmpty, 'ID não pode ser vazio'),
        assert(name.isNotEmpty, 'Nome não pode ser vazio'),
        assert(name.length >= 2, 'Nome deve ter no mínimo 2 caracteres'),
        assert(name.length <= 100, 'Nome não pode exceder 100 caracteres');

  // Getters computados
  bool get hasValidName => name.trim().length >= 2;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  bool get isComplete => hasValidName && email.isValid;

  UserProfileEntity copyWith({
    String? id,
    String? name,
    Email? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Value Object para Email com validação
class Email {
  final String value;

  Email(this.value) : assert(_isValidEmail(value), 'Email inválido: $value');

  static bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  bool get isValid => _isValidEmail(value);

  String get domain => value.split('@').last;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Email && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
```

**Regras:**
- ✅ NÃO deve ter dependências do Flutter (apenas Dart puro)
- ✅ Todos os campos devem ser `final`
- ✅ Email como Value Object com validação no construtor
- ✅ Validações via `assert` (id, nome 2-100 chars)
- ✅ Getters computados para facilitar uso na UI

### 2. DTO (Data Layer)

```dart
// lib/data/dtos/user_profile_dto.dart
class UserProfileDto {
  final String id;
  final String name;
  final String email; // Email serializado como string
  final String? photoUrl;
  final String createdAt; // DateTime serializado como ISO8601
  final String? lastUpdated; // DateTime? serializado como ISO8601?

  UserProfileDto({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.lastUpdated,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] as String,
      lastUpdated: json['lastUpdated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };
  }
}
```

**Regras:**
- ✅ Email como string simples no DTO
- ✅ Datas devem ser serializadas como strings ISO8601
- ✅ Campos opcionais devem aceitar null

### 3. Mapper (Data Layer)

```dart
// lib/data/mappers/user_profile_mapper.dart
import 'package:mood_journal/domain/entities/user_profile_entity.dart';
import 'package:mood_journal/data/dtos/user_profile_dto.dart';

class UserProfileMapper {
  static UserProfileEntity toEntity(UserProfileDto dto) {
    return UserProfileEntity(
      id: dto.id,
      name: dto.name,
      email: Email(dto.email),
      photoUrl: dto.photoUrl,
      createdAt: DateTime.parse(dto.createdAt),
      lastUpdated: dto.lastUpdated != null 
          ? DateTime.parse(dto.lastUpdated!)
          : null,
    );
  }

  static UserProfileDto toDto(UserProfileEntity entity) {
    return UserProfileDto(
      id: entity.id,
      name: entity.name,
      email: entity.email.value,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt.toIso8601String(),
      lastUpdated: entity.lastUpdated?.toIso8601String(),
    );
  }
}
```

**Regras:**
- ✅ Converter string para Email no toEntity
- ✅ Converter Email para string no toDto
- ✅ Tratar DateTime? opcional corretamente

### 4. Repository Interface (Domain Layer)

```dart
// lib/domain/repositories/user_profile_repository.dart
import 'package:mood_journal/domain/entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity?> getUserProfile(String id);
  Future<UserProfileEntity?> getCurrentUserProfile();
  Future<void> createUserProfile(UserProfileEntity entity);
  Future<void> updateUserProfile(UserProfileEntity entity);
  Future<void> updateProfilePhoto(String userId, String photoUrl);
  Future<void> deleteUserProfile(String id);
}
```

### 5. Use Case Example

```dart
// lib/domain/usecases/user_profile/update_user_profile.dart
import 'package:mood_journal/domain/entities/user_profile_entity.dart';
import 'package:mood_journal/domain/repositories/user_profile_repository.dart';

class UpdateUserProfile {
  final UserProfileRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> call(UserProfileEntity profile) async {
    // Validar perfil antes de atualizar
    if (!profile.isComplete) {
      throw ArgumentError('Perfil incompleto: nome ou email inválido');
    }

    // Atualizar com timestamp
    final updatedProfile = profile.copyWith(
      lastUpdated: DateTime.now(),
    );

    return repository.updateUserProfile(updatedProfile);
  }
}

// lib/domain/usecases/user_profile/update_profile_photo.dart
import 'package:mood_journal/domain/repositories/user_profile_repository.dart';

class UpdateProfilePhoto {
  final UserProfileRepository repository;

  UpdateProfilePhoto(this.repository);

  Future<void> call(String userId, String photoUrl) {
    return repository.updateProfilePhoto(userId, photoUrl);
  }
}
```

## Exemplo de Uso Completo

```dart
// Criar um novo perfil
final profile = UserProfileEntity(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'Maria Silva',
  email: Email('maria.silva@example.com'),
  createdAt: DateTime.now(),
);

// Verificar propriedades
print(profile.initials); // 'MS'
print(profile.hasPhoto); // false
print(profile.isComplete); // true
print(profile.email.domain); // 'example.com'

// Atualizar usando copyWith
final updatedProfile = profile.copyWith(
  name: 'Maria Silva Santos',
  photoUrl: '/storage/photos/maria.jpg',
  lastUpdated: DateTime.now(),
);

print(updatedProfile.initials); // 'MS'
print(updatedProfile.hasPhoto); // true

// Validação de email
try {
  final invalidEmail = Email('email-invalido');
} catch (e) {
  print(e); // AssertionError: Email inválido
}

// Usar no repositório
final repository = UserProfileRepositoryImpl(dataSource);
await repository.createUserProfile(profile);

final currentProfile = await repository.getCurrentUserProfile();
```

## Checklist de Implementação

- [x] Entity está em `lib/domain/entities/` sem dependências do Flutter
- [x] DTO está em `lib/data/dtos/` com serialização JSON
- [x] Mapper está em `lib/data/mappers/` com métodos `toEntity` e `toDto`
- [ ] Repository interface está em `lib/domain/repositories/`
- [ ] Repository implementation está em `lib/data/repositories/`
- [ ] Data source está em `lib/data/datasources/`
- [ ] Use cases estão em `lib/domain/usecases/user_profile/`
- [x] Todos os campos são `final`
- [x] Email implementado como Value Object com validação
- [x] Entity implementa `copyWith()`
- [x] DTO tem `fromJson` e `toJson`
- [x] Mapper trata conversões de Email e DateTime/DateTime?
- [x] Validações via `assert` (id, nome 2-100 chars, email regex)
- [ ] Imports não incluem `/lib` no caminho do pacote

## Referências

- Arquitetura: Clean Architecture
- Padrão: Repository Pattern + Value Object (Email)
- Serialização: JSON com ISO8601 para datas
- Imutabilidade: Todas as entidades são imutáveis
