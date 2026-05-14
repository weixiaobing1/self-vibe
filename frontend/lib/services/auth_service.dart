import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<LoginResult> login(String username, String password) async {
    final resp = await _api.dio.post('/api/user/login', data: {
      'username': username,
      'password': password,
    });
    final data = resp.data['data'];
    final result = LoginResult.fromJson(data);
    await _api.saveToken(result.accessToken, result.refreshToken);
    return result;
  }

  Future<void> register(String username, String password, String nickname) async {
    await _api.dio.post('/api/user/register', data: {
      'username': username,
      'password': password,
      'nickname': nickname,
    });
  }

  Future<User> getUserInfo() async {
    final resp = await _api.dio.get('/api/user/info');
    return User.fromJson(resp.data['data']);
  }

  Future<void> logout() async {
    await _api.clearToken();
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _api.dio.put('/api/user/change-password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    await _api.dio.put('/api/user/update', data: fields);
  }
}