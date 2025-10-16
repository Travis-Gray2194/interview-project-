import 'package:equatable/equatable.dart';
import 'package:interview_project/models/todo_filter.dart';

/// Base class for all TodoBloc events.
///
/// All events must extend this class and implement Equatable for proper
/// state comparison and Bloc event handling.
sealed class TodoBlocEvent extends Equatable {}

/// Event to initialize the TodoBloc and load initial data.
///
/// This event is typically triggered when the widget is first created
/// to set up the initial state and load the first page of todos.
class InitializeTodoBlocEvent extends TodoBlocEvent {
  @override
  List<Object?> get props => [];
}

/// Event to load todos with optional refresh flag.
///
/// Parameters:
/// - [isRefresh]: If true, clears existing todos and loads from page 1
///                If false, maintains current state while loading
class LoadTodosEvent extends TodoBlocEvent {
  final bool isRefresh;

  LoadTodosEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Event to load more todos for infinite scroll functionality.
///
/// This event appends new todos to the existing list without clearing
/// the current state. Used for pagination.
class LoadMoreTodosEvent extends TodoBlocEvent {
  @override
  List<Object?> get props => [];
}

/// Event to search todos with a query string.
///
/// The search is debounced (500ms) to prevent excessive API calls.
/// Searches both title and description fields.
class SearchTodosEvent extends TodoBlocEvent {
  final String searchQuery;

  SearchTodosEvent(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

/// Event to filter todos by status (All/Active/Inactive).
///
/// This event triggers a new data load with the specified filter applied.
class FilterTodosEvent extends TodoBlocEvent {
  final TodoFilter filter;

  FilterTodosEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}
