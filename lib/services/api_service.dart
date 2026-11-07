import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    // On physical Android devices with ADB reverse forwarding or local network:
    return 'http://127.0.0.1:5000/api';
  }

  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));
      return _parseResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Sunucu yanıt vermedi (Zaman aşımı). Lütfen backend sunucusunu kontrol edin.');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw Exception('Backend sunucusuna bağlanılamadı. ($baseUrl)');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 6));
      return _parseResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Sunucu yanıt vermedi (Zaman aşımı).');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw Exception('Backend sunucusuna bağlanılamadı. ($baseUrl)');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));
      return _parseResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Sunucu yanıt vermedi (Zaman aşımı).');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw Exception('Backend sunucusuna bağlanılamadı. ($baseUrl)');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 6));
      return _parseResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Sunucu yanıt vermedi (Zaman aşımı).');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw Exception('Backend sunucusuna bağlanılamadı. ($baseUrl)');
      }
      rethrow;
    }
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? 'Bir hata oluştu.';
      throw Exception(message);
    }
  }

  static Future<List<String>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // Search in Antalya region using Nominatim OpenStreetMap API
      // viewbox for Antalya approx: left=29.0, top=37.5, right=32.6, bottom=36.0
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=8&viewbox=29.0,37.5,32.6,36.0&bounded=1&countrycodes=tr');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'VersityMobileApp/1.0',
        'Accept-Language': 'tr-TR,tr;q=0.9',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final results = data.map((item) {
          final address = item['address'] ?? {};
          final name = item['name'] ?? '';
          final district = address['town'] ?? address['city_district'] ?? address['county'] ?? address['city'] ?? '';
          if (district.isNotEmpty && name != district && !name.contains(district)) {
            return '$name, $district';
          }
          return name.toString();
        }).where((name) => name.isNotEmpty).toList();

        if (results.isNotEmpty) {
          return results.toSet().toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Location search error: $e');
      }
    }

    final lowerQuery = query.toLowerCase();
    
    // Fallback Mock database for Antalya/Alanya regions if API fails
    final mockLocations = [
      'Akdeniz Üniversitesi',
      'Antalya Merkez',
      'Antalya Otogar',
      'Antalya Havalimanı',
      'Antalya Bilim Üniversitesi',
      'MarkAntalya AVM',
      'Terracity AVM',
      'Migros AVM (5M)',
      'Erasta AVM',
      'Agora AVM',
      'ÖzdilekPark Antalya',
      'Mall of Antalya',
      'Konyaaltı Kent Meydanı',
      'Konyaaltı Plajı',
      'Lara Plajı',
      'Kaleiçi',
      'Düden Şelalesi',
      'Kurşunlu Şelalesi',
      'Kepez Kent Ormanı',
      'Kepez Devlet Hastanesi',
      'Antalya Eğitim ve Araştırma Hastanesi',
      'Akdeniz Üniversitesi Hastanesi',
      'Muratpaşa',
      'Kepez',
      'Konyaaltı',
      'Döşemealtı',
      'Aksu',
      'Alanya Alaaddin Keykubat Üniversitesi',
      'Alanya Kent Meydanı',
      'Alanya Otogar',
      'Manavgat Şelalesi',
      'Manavgat Merkez',
      'Kemer Merkez',
      'Kumluca',
      'Finike',
      'Kaş',
      'Kalkan',
      'Serik',
      'Belek Turizm Merkezi'
    ];
    
    return mockLocations
        .where((loc) => loc.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
