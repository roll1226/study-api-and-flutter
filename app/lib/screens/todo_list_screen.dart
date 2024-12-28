import 'package:flutter/material.dart';

import '../services/api_service.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> _todos = []; // ローカルデータ保持用
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  // サーバーからデータを取得
  Future<void> _fetchTodos() async {
    try {
      final todos = await _apiService.fetchTodos();
      setState(() {
        _todos = todos;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ローカルで削除反映
  void _deleteTodoLocally(int id) {
    setState(() {
      _todos.removeWhere((todo) => todo['id'] == id);
    });
  }

  // エラー表示
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }

  // 削除処理
  Future<void> _deleteTodo(int id) async {
    // ローカルで即削除
    _deleteTodoLocally(id);

    // サーバーに削除リクエスト
    try {
      await _apiService.deleteTodo(id);
    } catch (e) {
      _showError('Failed to delete todo');
      // ロールバック（削除前に戻す）
      _fetchTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            title: Text(todo['title']),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _deleteTodo(todo['id']);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTodoTitle = await _showAddTodoDialog();
          if (newTodoTitle != null) {
            await _addTodo(newTodoTitle);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Todo追加ダイアログ
  Future<String?> _showAddTodoDialog() {
    String input = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
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
  }

  // Todo追加
  Future<void> _addTodo(String title) async {
    try {
      final newTodo = await _apiService.addTodo(title);
      setState(() {
        _todos.add(newTodo);
      });
    } catch (e) {
      _showError('Failed to add todo');
    }
  }
}
