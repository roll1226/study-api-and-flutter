import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

const String apiBaseUrl = 'http://127.0.0.1:3000';

http.Client createHttpClient() {
  final HttpClient httpClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  return IOClient(httpClient);
}

class ApiService {
  final http.Client client = createHttpClient();

  // Todo一覧を取得
  Future<List<Map<String, dynamic>>> fetchTodos() async {
    try {
      final response = await client.get(Uri.parse('$apiBaseUrl/todos'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to load todos: ${response.statusCode}, '
          'Body: ${response.body}',
        );
      }
    } catch (e) {
      rethrow; // 呼び出し元で例外をキャッチ
    }
  }

  // Todoを追加
  Future<Map<String, dynamic>> addTodo(String title) async {
    try {
      final response = await client.post(
        Uri.parse('$apiBaseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to add todo: ${response.statusCode}, '
          'Body: ${response.body}',
        );
      }
      // サーバーから返されたデータを返す
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Todoを削除
  Future<void> deleteTodo(int id) async {
    try {
      final response = await client.delete(Uri.parse('$apiBaseUrl/todos/$id'));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete todo: ${response.statusCode}, '
          'Body: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // リソース解放
  void dispose() {
    client.close();
  }
}
