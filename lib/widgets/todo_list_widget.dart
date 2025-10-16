import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_project/bloc/todo_bloc.dart';
import 'package:interview_project/bloc/todo_bloc_event.dart';
import 'package:interview_project/bloc/todo_bloc_state.dart';
import 'package:interview_project/models/todo_filter.dart';
import 'package:interview_project/widgets/empty_state_widget.dart';
import 'package:interview_project/widgets/error_state_widget.dart';
import 'package:interview_project/widgets/search_filter_section.dart';
import 'package:interview_project/widgets/todo_item_widget.dart';

/// Main widget that displays a list of todos with search, filter, and infinite scroll functionality.
///
/// This widget manages the overall state and coordinates between different UI components:
/// - SearchFilterSection: Handles search input and filter selection
/// - TodoItemWidget: Displays individual todo items
/// - EmptyStateWidget: Shows when no todos are found
/// - ErrorStateWidget: Displays error states with retry functionality
class TodoListWidget extends StatefulWidget {
  const TodoListWidget({super.key});

  @override
  State<TodoListWidget> createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {
  // Controllers for managing user input
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Current filter selection state
  TodoFilter _selectedFilter = TodoFilter.all;

  @override
  void initState() {
    super.initState();
    // Set up scroll listener for infinite scroll functionality
    _scrollController.addListener(_onScroll);
    // Initialize the bloc to load initial todos
    context.read<TodoBloc>().add(InitializeTodoBlocEvent());
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events to trigger infinite scroll when user approaches bottom
  void _onScroll() {
    // Trigger load more when user is within 200 pixels of the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TodoBloc>().add(LoadMoreTodosEvent());
    }
  }

  /// Handles search input changes and triggers search event
  void _onSearchChanged(String query) {
    context.read<TodoBloc>().add(SearchTodosEvent(query));
  }

  /// Handles filter selection changes and triggers filter event
  void _onFilterChanged(TodoFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
    context.read<TodoBloc>().add(FilterTodosEvent(filter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search and filter controls section
          SearchFilterSection(
            searchController: _searchController,
            selectedFilter: _selectedFilter,
            onSearchChanged: _onSearchChanged,
            onFilterChanged: _onFilterChanged,
          ),
          // Main content area with todo list
          Expanded(
            child: BlocConsumer<TodoBloc, TodoBlocState>(
              // Listen for error states to show snackbar notifications
              listener: (context, state) {
                if (state is TodoBlocError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              // Build appropriate UI based on current state
              builder: (context, state) {
                // Initial loading state
                if (state is TodoBlocInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Loading state with no existing todos
                else if (state is TodoBlocLoading && state.todos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Error state with no todos to display
                else if (state is TodoBlocError && state.todos.isEmpty) {
                  return ErrorStateWidget(message: state.message);
                }
                // Loaded or loading state with todos
                else if (state is TodoBlocLoaded || state is TodoBlocLoading) {
                  final todos = state is TodoBlocLoaded
                      ? state.todos
                      : (state as TodoBlocLoading).todos;
                  final isLoadingMore = state is TodoBlocLoaded
                      ? state.isLoadingMore
                      : false;

                  // Show empty state if no todos found after search/filter
                  if (todos.isEmpty && state is TodoBlocLoaded) {
                    return const EmptyStateWidget();
                  }

                  // Main todo list with pull-to-refresh and infinite scroll
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TodoBloc>().add(
                        LoadTodosEvent(isRefresh: true),
                      );
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      // Add extra item for loading indicator at bottom
                      itemCount: todos.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the bottom when loading more
                        if (index == todos.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        // Display individual todo item
                        final todo = todos[index];
                        return TodoItemWidget(todo: todo);
                      },
                    ),
                  );
                }

                // Fallback loading state
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
