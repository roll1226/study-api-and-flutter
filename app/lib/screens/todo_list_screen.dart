import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/todo_list_tile.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<dynamic>> _todos;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _todos = _apiService.fetchTodos();
  }

  Future<void> _refreshTodos() async {
    setState(() {
      _todos = _apiService.fetchTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTodos,
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
                  return TodoListTile(
                    todo: todo,
                    onDelete: () {
                      _apiService.deleteTodo(todo['id']);
                      _refreshTodos();
                    },
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
            await _apiService.addTodo(newTodo);
            _refreshTodos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
