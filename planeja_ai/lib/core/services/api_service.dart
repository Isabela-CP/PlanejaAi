import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  String get _baseUrl {
    String url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
    if (!kIsWeb && Platform.isAndroid) {
      url = url
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$_baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse('$_baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> multipartPost(String endpoint, String fileField,
      List<int> fileBytes, String filename) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: filename,
        contentType: MediaType('application', 'octet-stream'),
      ),
    );

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  dynamic decode(http.Response response) {
    try {
      return json.decode(response.body);
    } on FormatException {
      throw Exception('Resposta inválida do servidor.');
    }
  }
}
