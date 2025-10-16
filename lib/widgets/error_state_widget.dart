import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_project/bloc/todo_bloc.dart';
import 'package:interview_project/bloc/todo_bloc_event.dart';

/// A reusable widget that displays an error state with retry functionality.
///
/// This widget is shown when:
/// - Initial data loading fails
/// - Network errors occur
/// - Repository operations fail
///
/// Features:
/// - Error icon and message display
/// - Retry button with Bloc integration
/// - User-friendly error messaging
class ErrorStateWidget extends StatelessWidget {
  final String message;

  const ErrorStateWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          // Error title
          Text(
            'Failed to load todos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          // Error message details
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Retry button
          ElevatedButton(
            onPressed: () {
              // Trigger a new load attempt
              context.read<TodoBloc>().add(LoadTodosEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
