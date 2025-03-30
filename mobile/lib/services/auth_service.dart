import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String insertedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.insertedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      insertedAt: json['inserted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'inserted_at': insertedAt,
    };
  }
}

class ApiResponse {
  final String status;
  final dynamic data;
  final String? message;

  ApiResponse({
    required this.status,
    required this.data,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'],
      data: json['data'],
      message: json['message'],
    );
  }
}

class AuthResult {
  final User? user;
  final String? token;
  final String? error;

  AuthResult({
    this.user,
    this.token,
    this.error,
  });

  bool get isSuccess => error == null && user != null;
}

class AuthService with ChangeNotifier {
  // API URL will be set during initialization
  late final String apiUrl;
  
  // Secure storage for tokens
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Current user and authentication state
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  // Initialize the auth service
  Future<void> init() async {
    // Set the appropriate API URL based on platform
    if (kIsWeb) {
      // When running in a browser, use the current window location's hostname
      // to avoid CORS issues
      final currentHost = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
      final currentPort = '4000'; // Phoenix server port
      apiUrl = 'http://$currentHost:$currentPort/api/mobile';
      print('Web environment detected, using host: $currentHost');
    } else if (!kIsWeb && Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to reach the host machine
      apiUrl = 'http://10.0.2.2:4000/api/mobile';
    } else {
      // iOS simulator and physical devices
      apiUrl = 'http://127.0.0.1:4000/api/mobile';
    }
    
    print('Using API URL: $apiUrl'); // Debug info
    
    _token = await _storage.read(key: 'auth_token');
    final userJson = await _storage.read(key: 'user');
    
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(json.decode(userJson));
        notifyListeners();
      } catch (e) {
        await _storage.delete(key: 'user');
      }
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get device information for enhanced security
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    Map<String, dynamic> deviceData = {'platform': 'unknown'};

    try {
      if (kIsWeb) {
        // Safe approach for web platform
        deviceData = {
          'platform': 'web',
          'browser': 'browser',
        };
      } else {
        // Only use Platform detection for non-web platforms
        final deviceInfo = DeviceInfoPlugin();
        
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceData = {
            'deviceId': androidInfo.id,
            'model': androidInfo.model,
            'brand': androidInfo.brand,
            'osVersion': androidInfo.version.release,
            'platform': 'android',
          };
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceData = {
            'deviceId': iosInfo.identifierForVendor,
            'model': iosInfo.model,
            'name': iosInfo.name,
            'osVersion': iosInfo.systemVersion,
            'platform': 'ios',
          };
        } else {
          // Default for other platforms (macOS, Windows, Linux)
          deviceData = {
            'platform': Platform.operatingSystem,
          };
        }
      }
    } catch (e) {
      print('Error getting device info: $e');
      // Return basic info when there's an error
      deviceData = {
        'platform': 'unknown',
        'error': e.toString(),
      };
    }

    return deviceData;
  }

  // Helper for making authenticated API requests
  Future<http.Response> _authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    print('Making ${method.toUpperCase()} request to: $url');
    print('Headers: $headers');
    if (body != null) {
      print('Request body: ${json.encode(body)}');
    }

    late http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('Error making request: $e');
      rethrow;
    }
  }

  // Register new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String role = 'employee',
  }) async {
    _setLoading(true);

    try {
      final deviceInfo = await _getDeviceInfo();
      
      final response = await _authenticatedRequest(
        'POST',
        '/register',
        body: {
          'user': {
            'name': name,
            'email': email,
            'password': password,
            'role': role,
          },
          'device_info': deviceInfo,
        },
      );

      if (response.statusCode == 201) {
        final responseData = ApiResponse.fromJson(json.decode(response.body));
        final data = responseData.data as Map<String, dynamic>;
        
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        
        // Save to secure storage
        await _storage.write(key: 'auth_token', value: _token);
        await _storage.write(key: 'user', value: json.encode(_currentUser!.toJson()));
        
        notifyListeners();
        
        return AuthResult(
          user: _currentUser,
          token: _token,
        );
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Registration failed';
        
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          errorMessage = errors.entries
              .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
              .join('\n');
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
        
        return AuthResult(error: errorMessage);
      }
    } catch (e) {
      return AuthResult(error: 'Network error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final deviceInfo = await _getDeviceInfo();
      
      final response = await _authenticatedRequest(
        'POST',
        '/login',
        body: {
          'email': email,
          'password': password,
          'device_info': deviceInfo,
        },
      );

      if (response.statusCode == 200) {
        final responseData = ApiResponse.fromJson(json.decode(response.body));
        final data = responseData.data as Map<String, dynamic>;
        
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        
        // Save to secure storage
        await _storage.write(key: 'auth_token', value: _token);
        await _storage.write(key: 'user', value: json.encode(_currentUser!.toJson()));
        
        notifyListeners();
        
        return AuthResult(
          user: _currentUser,
          token: _token,
        );
      } else if (response.statusCode == 0) {
        // Special case for CORS errors in Flutter web
        return AuthResult(error: 'CORS error: Unable to connect to server. Please check server CORS configuration.');
      } else {
        String errorMessage = 'Invalid email or password';
        
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // JSON decode failed, use status code in error message
          errorMessage = 'Server error (${response.statusCode}): ${response.reasonPhrase ?? "Unknown error"}';
        }
        
        return AuthResult(error: errorMessage);
      }
    } catch (e) {
      print('Login error: $e');
      
      String errorMessage = 'Network error';
      if (e.toString().contains('XMLHttpRequest error')) {
        errorMessage = 'CORS error: The server rejected the request. Please check server CORS configuration.';
      } else if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Server unavailable: Please check if the server is running.';
      }
      
      return AuthResult(error: '$errorMessage\n\nDetails: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get current user information
  Future<AuthResult> getCurrentUser() async {
    if (_token == null) {
      return AuthResult(error: 'Not authenticated');
    }

    _setLoading(true);

    try {
      final response = await _authenticatedRequest('GET', '/current_user');

      if (response.statusCode == 200) {
        final responseData = ApiResponse.fromJson(json.decode(response.body));
        final userData = responseData.data['user'] as Map<String, dynamic>;
        
        _currentUser = User.fromJson(userData);
        
        // Update stored user data
        await _storage.write(key: 'user', value: json.encode(_currentUser!.toJson()));
        
        notifyListeners();
        
        return AuthResult(user: _currentUser);
      } else {
        // If we get an authentication error, clear stored data
        if (response.statusCode == 401) {
          await logout(serverSide: false);
        }
        
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to get user data';
        
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
        
        return AuthResult(error: errorMessage);
      }
    } catch (e) {
      return AuthResult(error: 'Network error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh authentication token
  Future<AuthResult> refreshToken() async {
    if (_token == null) {
      return AuthResult(error: 'Not authenticated');
    }

    _setLoading(true);

    try {
      final response = await _authenticatedRequest('POST', '/refresh_token');

      if (response.statusCode == 200) {
        final responseData = ApiResponse.fromJson(json.decode(response.body));
        final data = responseData.data as Map<String, dynamic>;
        
        _token = data['token'];
        
        // Save new token
        await _storage.write(key: 'auth_token', value: _token);
        
        notifyListeners();
        
        return AuthResult(token: _token);
      } else {
        // If we get an authentication error, clear stored data
        if (response.statusCode == 401) {
          await logout(serverSide: false);
        }
        
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to refresh token';
        
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
        
        return AuthResult(error: errorMessage);
      }
    } catch (e) {
      return AuthResult(error: 'Network error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<AuthResult> logout({bool serverSide = true}) async {
    _setLoading(true);

    try {
      // Only call API if we want server-side logout and we have a token
      if (serverSide && _token != null) {
        await _authenticatedRequest('POST', '/logout');
      }
      
      // Clear local data regardless of API response
      _token = null;
      _currentUser = null;
      
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user');
      
      notifyListeners();
      
      return AuthResult();
    } catch (e) {
      // Even if server-side logout fails, still clear local data
      _token = null;
      _currentUser = null;
      
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user');
      
      notifyListeners();
      
      return AuthResult(error: 'Error during logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
