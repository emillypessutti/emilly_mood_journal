import 'package:connectivity_plus/connectivity_plus.dart';

/// Service para verificar conectividade de rede
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Verifica se há conexão com a internet
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Stream de mudanças de conectividade
  Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// Verifica se está offline
  Future<bool> isOffline() async {
    return !(await hasInternetConnection());
  }
}
