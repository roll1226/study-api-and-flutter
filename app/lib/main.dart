import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

// HttpClient をセットアップして IOClient を作成
http.Client createHttpClient() {
  final HttpClient httpClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  return IOClient(httpClient);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter REST API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<dynamic>> _todos;
  final client = createHttpClient();

  Future<List<dynamic>> fetchUsers() async {
    try {
      final response =
          await client.get(Uri.parse('http://127.0.0.1:3000/todos'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final response = await client.post(
        Uri.parse('http://127.0.0.1:3000/todos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );
      if (response.statusCode == 201) {
        setState(() {
          _todos = fetchUsers();
        });
      } else {
        throw Exception('Failed to add todo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('http://127.0.0.1:3000/todos/$id'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _todos = fetchUsers();
        });
      } else {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _todos = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _todos = fetchUsers();
          });
        },
        child: FutureBuilder<List<dynamic>>(
          future: _todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var todo = snapshot.data![index];
                  return ListTile(
                    title: Text(todo['title']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        deleteTodo(todo['id']);
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTodo = await showDialog<String>(
            context: context,
            builder: (context) {
              String input = '';
              return AlertDialog(
                title: const Text('Add Todo'),
                content: TextField(
                  onChanged: (value) => input = value,
                  decoration: const InputDecoration(hintText: 'Enter a task'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, input),
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
          if (newTodo != null && newTodo.isNotEmpty) {
            addTodo(newTodo);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
