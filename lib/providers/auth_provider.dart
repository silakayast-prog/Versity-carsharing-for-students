import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String _activeRole = 'yolcu';

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String get activeRole => _activeRole;
  bool get isAuthenticated => _user != null && _token != null;

  Future<void> login(String okulEmail, String sifre) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.post('/auth/login', {
        'okul_email': okulEmail,
        'sifre': sifre,
      });

      final data = res['data'];
      _token = data['accessToken'];
      ApiService.setAuthToken(_token);

      _user = UserModel.fromJson(data['user']);
      if (_user?.aktifRol == 'sofor' || _user?.aktifRol == 'yolcu') {
        _activeRole = _user!.aktifRol;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String adSoyad, String okulEmail, String sifre) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.post('/auth/register', {
        'ad_soyad': adSoyad,
        'okul_email': okulEmail,
        'sifre': sifre,
        'yas_onay': true,
        'kvkk_onay': true,
      });

      final data = res['data'];
      _token = data['accessToken'];
      ApiService.setAuthToken(_token);
      _user = UserModel.fromJson(data['user']);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchRole(String newRole) async {
    if (_token == null) return;
    try {
      await ApiService.patch('/users/role', {'aktif_rol': newRole});
      _activeRole = newRole;
      notifyListeners();
    } catch (e) {
      debugPrint('Role switch failed: $e');
    }
  }

  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      final res = await ApiService.get('/users/me');
      _user = UserModel.fromJson(res['data']);
      notifyListeners();
    } catch (e) {
      debugPrint('Refresh profile failed: $e');
    }
  }

  void logout() {
    _user = null;
    _token = null;
    ApiService.setAuthToken(null);
    notifyListeners();
  }
}
