import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service para gerenciar conexão com Supabase
class SupabaseService {
  static SupabaseClient? _client;

  /// Inicializa o Supabase
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL não configurada no .env');
    }

    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY não configurada no .env');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: dotenv.env['DEBUG_MODE'] == 'true',
    );

    _client = Supabase.instance.client;
  }

  /// Retorna a instância do cliente Supabase
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase não foi inicializado. Chame initialize() primeiro.');
    }
    return _client!;
  }

  /// Verifica se o Supabase está inicializado
  static bool get isInitialized => _client != null;

  /// Retorna o usuário autenticado (se houver)
  static User? get currentUser => _client?.auth.currentUser;

  /// Verifica se há um usuário autenticado
  static bool get isAuthenticated => currentUser != null;
}
