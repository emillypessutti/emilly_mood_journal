import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/user_profile_dto.dart';
import '../../../services/supabase_service.dart';

/// Data Source remota para UserProfile usando Supabase
class UserProfileRemoteDataSource {
  final SupabaseClient _client = SupabaseService.client;
  static const String _tableName = 'user_profiles';

  /// Busca o perfil do usuário atual
  Future<UserProfileDto?> getUserProfile() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return null;

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfileDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar perfil do usuário do Supabase: $e');
    }
  }

  /// Salva o perfil do usuário
  Future<UserProfileDto> saveUserProfile(UserProfileDto dto) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final profileData = dto.toJson();
      profileData['user_id'] = userId;

      final response = await _client
          .from(_tableName)
          .upsert(profileData)
          .select()
          .single();

      return UserProfileDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao salvar perfil do usuário no Supabase: $e');
    }
  }

  /// Atualiza o perfil do usuário
  Future<UserProfileDto> updateUserProfile(UserProfileDto dto) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await _client
          .from(_tableName)
          .update(dto.toJson())
          .eq('user_id', userId)
          .select()
          .single();

      return UserProfileDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil do usuário no Supabase: $e');
    }
  }

  /// Deleta o perfil do usuário
  Future<void> deleteUserProfile() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _client.from(_tableName).delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Erro ao deletar perfil do usuário do Supabase: $e');
    }
  }
}
