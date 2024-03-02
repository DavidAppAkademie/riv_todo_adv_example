import 'package:flutter/material.dart';
import 'package:riv_todo_adv_example/todo/presentation/todo_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoScreen(),
    );
  }
}
