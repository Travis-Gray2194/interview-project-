import 'package:flutter/material.dart';
import 'package:interview_project/models/todo_filter.dart';

/// A reusable widget that provides search and filter functionality for todos.
///
/// Features:
/// - Search input field with Material Design styling
/// - Filter chips for All/Active/Inactive todos
/// - Horizontal scrollable filter chips
/// - Callback functions for handling user interactions
class SearchFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final TodoFilter selectedFilter;
  final Function(String) onSearchChanged;
  final Function(TodoFilter) onFilterChanged;

  const SearchFilterSection({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search input field
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search todos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          const SizedBox(height: 16),
          // Filter chips row
          Row(
            children: [
              Text(
                'Filter: ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TodoFilter.values.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(_getFilterLabel(filter)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              onFilterChanged(filter);
                            }
                          },
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          checkmarkColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Converts TodoFilter enum values to user-friendly display labels.
  String _getFilterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.inactive:
        return 'Inactive';
    }
  }
}
