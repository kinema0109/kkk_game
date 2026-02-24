import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  static Future<Map<String, String>> _getHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> listGames() async {
    final response = await http.get(
      Uri.parse('$baseUrl/game/list'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load games: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createGame({
    String? name,
    bool isPublic = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/create'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'is_public': isPublic,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create game: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> joinGame({
    required String roomCode,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/join'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'room_code': roomCode,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to join game: ${response.body}');
    }
  }
}
