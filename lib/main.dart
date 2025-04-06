import 'package:flutter/material.dart';
// import 'dart:convert'; // 追加！
// import 'package:shared_preferences/shared_preferences.dart'; // 追加！flutter pub get

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire configure で自動生成されたやつ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

    // void _saveTodos() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final todoJson = jsonEncode(_todos);
    //   await prefs.setString('todo_list', todoJson);
    // }

    void _saveTodos() async {
      final docRef = FirebaseFirestore.instance.collection('todos').doc('user1'); // ユーザーIDは仮
      await docRef.set({'items': _todos});
    }

    // void _loadTodos() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final todoJson = prefs.getString('todo_list');
    //   if (todoJson != null) {
    //     final List<dynamic> decoded = jsonDecode(todoJson);
    //     setState(() {
    //       _todos.clear();
    //       _todos.addAll(decoded.cast<String>());
    //     });
    //   }
    // }

    void _loadTodos() async {
      final docRef = FirebaseFirestore.instance.collection('todos').doc('user1');
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        final items = data?['items'];
        if (items is List) {
          setState(() {
            _todos.clear();
            _todos.addAll(List<String>.from(items));
          });
        }
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