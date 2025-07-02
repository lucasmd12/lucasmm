import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para ChangeNotifier
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart'; // Importa o modelo User
import 'package:lucasbeatsfederacao/services/api_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _token;
  User? _currentUser; // Alterado de User para User
  String? _lastErrorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get currentUser => _currentUser; // Alterado de User para User
  String? get errorMessage => _lastErrorMessage;

  ApiService get apiService => _apiService;

  AuthService() {
    _checkInitialAuthStatus();
  }

  Future<void> _checkInitialAuthStatus() async {
    Logger.info("Checking initial authentication status...");
    final storedToken = await _secureStorage.read(key: "jwt_token");
    if (storedToken != null) {
      Logger.info("Token found, attempting to fetch profile...");
      _token = storedToken;
      try {
        await fetchUserProfile();
        if (_currentUser != null) {
          _isAuthenticated = true;
          Logger.info("User authenticated from stored token.");
          _setSentryUser(); // Set Sentry user on initial auth
        } else {
          await logout(); // Clear invalid token/state
        }
      } catch (e) {
        Logger.error("Failed to fetch profile with stored token: ${e.toString()}");
        _lastErrorMessage = e.toString();
        await logout(); // Clear invalid token/state
      }
    } else {
      Logger.info("No stored token found.");
      _isAuthenticated = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) {
      Logger.warning("Cannot fetch profile without a token.");
      _lastErrorMessage = "Not authenticated";
      throw Exception(_lastErrorMessage);
    }
    try {
      final response = await _apiService.get("/api/auth/profile", requireAuth: true);
      if (response != null && response is Map<String, dynamic>) {
        _currentUser = User.fromJson(response); // Alterado de User para User
        Logger.info("User profile fetched successfully: ${_currentUser?.username}");
        _lastErrorMessage = null;
        _setSentryUser(); // Set Sentry user after fetching profile
        notifyListeners();
      } else {
        Logger.warning("Failed to parse user profile from response.");
        _currentUser = null;
        _lastErrorMessage = "Failed to get user profile";
        throw Exception(_lastErrorMessage);
      }
    } catch (e) {
      Logger.error("Error fetching user profile: ${e.toString()}");
      _lastErrorMessage = e.toString();
      _currentUser = null;
      rethrow;
    }
  }

  Future<bool> login(String username, String password) async {
    setLoading(true);
    _lastErrorMessage = null;
    try {
      final response = await _apiService.post(
        "/api/auth/login",
        {"username": username, "password": password},
        requireAuth: false,
      );

      if (response != null && response.body.isNotEmpty) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey("token")) {
          final newToken = decodedResponse["token"] as String?;
          if (newToken != null) {
            await _secureStorage.write(key: "jwt_token", value: newToken);
            _token = newToken;
            await fetchUserProfile();
            if (_currentUser != null) {
               setAuthenticated(true);
               Logger.info("Login successful for user: ${_currentUser?.username}");
               _setSentryUser(); // Set Sentry user on successful login
               return true;
            } else {
              _lastErrorMessage = "Profile fetch failed after login";
              await _clearAuthData();
              setAuthenticated(false);
              return false;
            }
          } else {
             _lastErrorMessage = "Token not found in login response";
             throw Exception(_lastErrorMessage);
          }
        } else {
           _lastErrorMessage = decodedResponse?["msg"] ?? "Invalid login response format";
           throw Exception(_lastErrorMessage);
        }
      } else {
         _lastErrorMessage = "Empty or invalid login response";
         throw Exception(_lastErrorMessage);
      }
    } catch (e) {
      Logger.error("Login error: ${e.toString()}");
      _lastErrorMessage = e.toString().replaceFirst("Exception: ", "");
      await _clearAuthData();
      setAuthenticated(false);
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register(String username, String password) async {
    setLoading(true);
    _lastErrorMessage = null;
    try {
      final response = await _apiService.post(
        "/api/auth/register",
        {"username": username, "password": password},
        requireAuth: false,
      );

      if (response != null) {
          Logger.info("Registration request successful for user: $username. Attempting to log in automatically...");
          // Tenta logar o usuário automaticamente após o registro bem-sucedido
          return await login(username, password);
      } else {
          Logger.info("Registration request successful (no content) for user: $username. Attempting to log in automatically...");
          return await login(username, password);
      }

    } catch (e) {
      Logger.error("Registration error: ${e.toString()}");
      _lastErrorMessage = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    Logger.info("Logging out user...");
    setLoading(true);
    await _clearAuthData();
    setAuthenticated(false);
    _clearSentryUser(); // Clear Sentry user on logout
    Logger.info("Logout successful");
    setLoading(false);
  }

  Future<void> _clearAuthData() async {
     _currentUser = null;
     _token = null;
     await _secureStorage.delete(key: "jwt_token");
  }

  void _setSentryUser() {
    if (_currentUser != null) {
      Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(
            id: _currentUser!.id,
            username: _currentUser!.username,
            data: {
              'role': _currentUser!.role,
              'clan': _currentUser!.clan,
              'federation': _currentUser!.federation,
            },
          ),
        );
        // CORREÇÃO AQUI: Adicionado .toString() para garantir que o valor seja String
        scope.setTag('user_role', (_currentUser!.role ?? 'unknown').toString());
        if (_currentUser!.clan != null) {
          scope.setTag('user_clan', _currentUser!.clan!);
        }
        if (_currentUser!.federation != null) {
          scope.setTag('user_federation', _currentUser!.federation!);
        }
      });
    } else {
      _clearSentryUser();
    }
  }

  void _clearSentryUser() {
    Sentry.configureScope((scope) {
      scope.setUser(null);
      scope.removeTag('user_role');
      scope.removeTag('user_clan');
      scope.removeTag('user_federation');
    });
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setAuthenticated(bool authenticated) {
    if (_isAuthenticated != authenticated) {
        _isAuthenticated = authenticated;
        notifyListeners();
    }
  }

  @override
  void dispose() {
    Logger.info("Disposing AuthService.");
    super.dispose();
  }
}
