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

  Future<List<dynamic>> fetchTodos() async {
    final response = await client.get(Uri.parse('$apiBaseUrl/todos'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load todos: ${response.statusCode}');
    }
  }

  Future<void> addTodo(String title) async {
    final response = await client.post(
      Uri.parse('$apiBaseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add todo: ${response.statusCode}');
    }
  }

  Future<void> deleteTodo(int id) async {
    final response = await client.delete(Uri.parse('$apiBaseUrl/todos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo: ${response.statusCode}');
    }
  }
}
