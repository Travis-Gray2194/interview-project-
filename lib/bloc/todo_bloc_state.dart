import 'package:equatable/equatable.dart';
import 'package:interview_project/models/todo.dart';
import 'package:interview_project/models/todo_filter.dart';

/// Base class for all TodoBloc states.
///
/// All states must extend this class and implement Equatable for proper
/// state comparison and Bloc state management.
sealed class TodoBlocState extends Equatable {}

/// Initial state when the TodoBloc is first created.
///
/// This state is shown briefly before the first data load begins.
class TodoBlocInitial extends TodoBlocState {
  @override
  List<Object?> get props => [];
}

/// Loading state that can preserve existing todos during refresh operations.
///
/// This state maintains the current todos list while loading new data,
/// providing a better user experience during refresh operations.
class TodoBlocLoading extends TodoBlocState {
  final List<Todo> todos;
  final String searchQuery;
  final TodoFilter filter;

  TodoBlocLoading({
    this.todos = const [],
    this.searchQuery = '',
    this.filter = TodoFilter.all,
  });

  @override
  List<Object?> get props => [todos, searchQuery, filter];
}

/// Loaded state containing todos and pagination information.
///
/// This state represents a successful data load and contains:
/// - List of todos
/// - Current page number
/// - Whether more pages are available
/// - Loading state for pagination
/// - Current search query and filter
/// - Optional error message
class TodoBlocLoaded extends TodoBlocState {
  final List<Todo> todos;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final TodoFilter filter;
  final String? error;

  TodoBlocLoaded({
    required this.todos,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.filter = TodoFilter.all,
    this.error,
  });

  /// Creates a copy of this state with updated values.
  ///
  /// Used for immutable state updates in Bloc pattern.
  TodoBlocLoaded copyWith({
    List<Todo>? todos,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    TodoFilter? filter,
    String? error,
  }) {
    return TodoBlocLoaded(
      todos: todos ?? this.todos,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    todos,
    currentPage,
    hasMore,
    isLoadingMore,
    searchQuery,
    filter,
    error,
  ];
}

/// Error state displayed when data loading fails.
///
/// This state contains an error message and optionally preserves
/// existing todos to maintain partial functionality.
class TodoBlocError extends TodoBlocState {
  final String message;
  final List<Todo> todos;

  TodoBlocError({required this.message, this.todos = const []});

  @override
  List<Object?> get props => [message, todos];
}
