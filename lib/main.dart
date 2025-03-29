import 'package:flutter/material.dart';
import 'dart:convert'; // 追加！
import 'package:shared_preferences/shared_preferences.dart'; // 追加！flutter pub get

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<String> _todos = [];
  final TextEditingController _controller = TextEditingController();

    void _addTodo() {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        setState(() {
          _todos.add(text);
          _controller.clear();
        });
        _saveTodos();
      }
    }

    void _saveTodos() async {
      final prefs = await SharedPreferences.getInstance();
      final todoJson = jsonEncode(_todos);
      await prefs.setString('todo_list', todoJson);
    }

    void _loadTodos() async {
      final prefs = await SharedPreferences.getInstance();
      final todoJson = prefs.getString('todo_list');
      if (todoJson != null) {
        final List<dynamic> decoded = jsonDecode(todoJson);
        setState(() {
          _todos.clear();
          _todos.addAll(decoded.cast<String>());
        });
      }
    }
    
    @override
    void initState() {
      super.initState();
      _loadTodos(); // ← アプリ起動時に読み込み
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo アプリ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'やることを入力',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_todos[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _todos.removeAt(index);
                        });
                        _saveTodos();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}