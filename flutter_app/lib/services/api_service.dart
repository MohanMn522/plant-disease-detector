import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/prediction_result.dart';

class ApiService {
  final String baseUrl;

  /// Constructor: resolves a non-null baseUrl.
  /// If baseUrl argument is null or empty, a sensible default is chosen:
  /// - Android (real device) -> http://10.39.80.185:8000  <-- your PC LAN IP (confirmed working)
  /// - If you need emulator (AVD) mapping instead, pass 'http://10.0.2.2:8000' explicitly.
  /// - Others -> http://127.0.0.1:8000
  ApiService({String? baseUrl})
      : baseUrl = _resolveBaseUrl(baseUrl) {
    print('🌐 ApiService resolved baseUrl = $baseUrl');
    print('🔎 Platform.isAndroid=${Platform.isAndroid}, os=${Platform.operatingSystem}');
    if (Platform.isAndroid && (baseUrl == null || baseUrl.trim().isEmpty)) {
      print('ℹ️ Default chosen is the PC LAN IP for Android devices.');
      print('If you are using an emulator, pass baseUrl: "http://10.0.2.2:8000" when creating ApiService.');
    }
  }

  /// Factory for real device usage: ApiService.forDevice('192.168.1.42')
  factory ApiService.forDevice(String hostIp, {int port = 8000}) {
    final resolved = 'http://$hostIp:$port';
    return ApiService(baseUrl: resolved);
  }

  static String _resolveBaseUrl(String? provided) {
    if (provided != null && provided.trim().isNotEmpty) return provided.trim();
    // Default fallback: use your confirmed PC LAN IP for Android devices (real device)
    if (Platform.isAndroid) {
      return 'http://10.39.80.185/predictions/predict';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Upload image and get prediction
  Future<PredictionResult> uploadAndPredict(File imageFile, {String? userId}) async {
    try {
      final uri = Uri.parse('$baseUrl/predictions/predict');
      print('\n🚀 [UPLOAD] Sending request to: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Log file info
      print('🖼️  Image Path: ${imageFile.path}');
      print('🧩 Image Type: ${_getImageType(imageFile.path)}');
      print('👤 User ID: ${userId ?? "N/A"}');

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', _getImageType(imageFile.path)),
      ));

      if (userId != null) request.fields['userId'] = userId;

      print('📦 Request Fields: ${request.fields}');
      print('📦 Request Files: ${request.files.map((f) => f.filename).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 [UPLOAD RESPONSE] Status: ${response.statusCode}');
      print('📡 [UPLOAD RESPONSE] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Prediction Response Parsed: $data');
        return PredictionResult.fromJson(data);
      } else {
        print('❌ Backend Error: ${response.statusCode} - ${response.body}');
        throw Exception('Backend error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔥 [UPLOAD ERROR] Failed to get prediction: $e');
      throw Exception('Failed to get prediction: $e');
    }
  }

  /// Get prediction history
  Future<List<PredictionResult>> getPredictionHistory({String? userId}) async {
    try {
      final uri = Uri.parse('$baseUrl/predictions/history${userId != null ? "/$userId" : ""}');
      print('\n📜 [HISTORY] Fetching prediction history from: $uri');

      final response = await http.get(uri);

      print('📡 [HISTORY RESPONSE] Status: ${response.statusCode}');
      print('📡 [HISTORY RESPONSE] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> historyData = data['history'] ?? [];
        print('📊 Parsed History Length: ${historyData.length}');
        return historyData.map((e) => PredictionResult.fromJson(e)).toList();
      } else {
        print('❌ Backend Error: ${response.statusCode} - ${response.body}');
        throw Exception('Backend error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔥 [HISTORY ERROR] Failed to get prediction history: $e');
      throw Exception('Failed to get prediction history: $e');
    }
  }

  String _getImageType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpeg';
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }

  Future<bool> healthCheck() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      print('\n❤️ [HEALTH CHECK] Checking server at: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      print('📡 [HEALTH CHECK RESPONSE] Status: ${response.statusCode}');
      print('📡 [HEALTH CHECK RESPONSE] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('🔥 [HEALTH CHECK ERROR] $e');
      return false;
    }
  }
}
