import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_project/bloc/todo_bloc.dart';
import 'package:interview_project/widgets/todo_list_widget.dart';

import 'repositories/mock_todo_repository.dart';
import 'repositories/todo_repository.dart';

/// Entry point of the Todo List Interview Project application.
///
/// This Flutter app demonstrates:
/// - Infinite scroll/pagination
/// - Search and filtering functionality
/// - State management with Bloc pattern
/// - Repository pattern with mock data
/// - Modern Material Design 3 UI
void main() {
  // Initialize the mock repository with 1000 random todos
  final TodoRepository todoRepository = MockTodoRepository(count: 1000);

  runApp(MyApp(todoRepository: todoRepository));
}

/// Root application widget that sets up the Material Design theme and Bloc provider.
///
/// The app uses:
/// - Material Design 3 with blue color scheme
/// - BlocProvider for state management
/// - TodoListWidget as the main screen
class MyApp extends StatelessWidget {
  final TodoRepository todoRepository;

  const MyApp({super.key, required this.todoRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Interview Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => TodoBloc(todoRepository: todoRepository),
        child: const TodoListWidget(),
      ),
    );
  }
}
