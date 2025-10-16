import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_project/bloc/todo_bloc_event.dart';
import 'package:interview_project/bloc/todo_bloc_state.dart';
import 'package:interview_project/models/todo.dart';
import 'package:interview_project/models/todo_filter.dart';
import 'package:interview_project/repositories/todo_repository.dart';

/// Business logic component for managing todo list state and operations.
///
/// This Bloc handles:
/// - Loading todos with pagination
/// - Search functionality with debouncing
/// - Filtering by todo status
/// - Infinite scroll pagination
/// - Error handling and state management
///
/// Key features:
/// - 500ms debounced search to prevent excessive API calls
/// - State preservation during refresh operations
/// - Proper error handling with retry capabilities
/// - Immutable state updates following Bloc pattern
class TodoBloc extends Bloc<TodoBlocEvent, TodoBlocState> {
  final TodoRepository todoRepository;

  /// Number of todos to load per page for pagination
  static const int pageSize = 20;

  /// Timer for debouncing search input to prevent excessive API calls
  Timer? _debounceTimer;

  TodoBloc({required this.todoRepository}) : super(TodoBlocInitial()) {
    // Register event handlers
    on<InitializeTodoBlocEvent>(_onInitialize);
    on<LoadTodosEvent>(_onLoadTodos);
    on<LoadMoreTodosEvent>(_onLoadMoreTodos);
    on<SearchTodosEvent>(_onSearchTodos);
    on<FilterTodosEvent>(_onFilterTodos);
  }

  @override
  Future<void> close() {
    // Clean up debounce timer to prevent memory leaks
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Handles initialization event by setting up loading state and triggering initial data load.
  void _onInitialize(
    InitializeTodoBlocEvent event,
    Emitter<TodoBlocState> emit,
  ) {
    emit(TodoBlocLoading());
    add(LoadTodosEvent());
  }

  /// Handles loading todos with optional refresh functionality.
  ///
  /// This method:
  /// - Preserves existing state during refresh operations
  /// - Loads first page of todos with current search/filter
  /// - Handles errors gracefully with proper error states
  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoBlocState> emit,
  ) async {
    try {
      final currentState = state;
      String searchQuery = '';
      TodoFilter filter = TodoFilter.all;
      List<Todo> existingTodos = [];

      // Preserve current state if not refreshing
      if (currentState is TodoBlocLoaded && !event.isRefresh) {
        searchQuery = currentState.searchQuery;
        filter = currentState.filter;
        existingTodos = currentState.todos;
      }

      // Emit loading state with preserved data
      emit(
        TodoBlocLoading(
          todos: existingTodos,
          searchQuery: searchQuery,
          filter: filter,
        ),
      );

      // Fetch todos from repository
      final response = await todoRepository.getTodos(
        page: 1,
        pageSize: pageSize,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
        filter: filter,
      );

      // Emit loaded state with new data
      emit(
        TodoBlocLoaded(
          todos: response.items,
          currentPage: 2, // Next page to load
          hasMore: response.hasMore,
          searchQuery: searchQuery,
          filter: filter,
        ),
      );
    } catch (e) {
      emit(TodoBlocError(message: 'Failed to load todos: ${e.toString()}'));
    }
  }

  /// Handles loading more todos for infinite scroll pagination.
  ///
  /// This method:
  /// - Checks if more todos are available and not already loading
  /// - Appends new todos to existing list
  /// - Updates pagination state
  /// - Handles errors without losing existing data
  Future<void> _onLoadMoreTodos(
    LoadMoreTodosEvent event,
    Emitter<TodoBlocState> emit,
  ) async {
    final currentState = state;

    // Validate state and prevent duplicate requests
    if (currentState is! TodoBlocLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    // Set loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      // Fetch next page of todos
      final response = await todoRepository.getTodos(
        page: currentState.currentPage,
        pageSize: pageSize,
        searchQuery: currentState.searchQuery.isEmpty
            ? null
            : currentState.searchQuery,
        filter: currentState.filter,
      );

      // Append new todos to existing list
      final updatedTodos = [...currentState.todos, ...response.items];

      // Update state with new todos and pagination info
      emit(
        currentState.copyWith(
          todos: updatedTodos,
          currentPage: currentState.currentPage + 1,
          hasMore: response.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Handle error without losing existing data
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          error: 'Failed to load more todos: ${e.toString()}',
        ),
      );
    }
  }

  /// Handles search input with debouncing to prevent excessive API calls.
  ///
  /// This method:
  /// - Cancels previous debounce timer
  /// - Sets up new 500ms debounce timer
  /// - Updates search query in state
  /// - Triggers data reload after debounce period
  void _onSearchTodos(SearchTodosEvent event, Emitter<TodoBlocState> emit) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Set up new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(LoadTodosEvent());
    });

    final currentState = state;

    // Update search query in current state
    if (currentState is TodoBlocLoaded) {
      emit(currentState.copyWith(searchQuery: event.searchQuery));
    } else if (currentState is TodoBlocLoading) {
      emit(
        TodoBlocLoading(
          todos: currentState.todos,
          searchQuery: event.searchQuery,
          filter: currentState.filter,
        ),
      );
    }
  }

  /// Handles filter changes and triggers data reload with new filter.
  ///
  /// This method:
  /// - Updates filter in current state
  /// - Triggers immediate data reload with new filter
  /// - Maintains current search query
  void _onFilterTodos(FilterTodosEvent event, Emitter<TodoBlocState> emit) {
    final currentState = state;

    if (currentState is TodoBlocLoaded) {
      emit(currentState.copyWith(filter: event.filter));
      add(LoadTodosEvent());
    } else if (currentState is TodoBlocLoading) {
      emit(
        TodoBlocLoading(
          todos: currentState.todos,
          searchQuery: currentState.searchQuery,
          filter: event.filter,
        ),
      );
      add(LoadTodosEvent());
    }
  }
}
