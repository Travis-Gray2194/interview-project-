import 'package:flutter/material.dart';

/// A reusable widget that displays an empty state when no todos are found.
///
/// This widget is shown when:
/// - Search returns no results
/// - Filter returns no results
/// - No todos exist in the system
///
/// Features:
/// - Large checklist icon
/// - Clear messaging about empty state
/// - Helpful suggestion text
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large empty state icon
          Icon(Icons.checklist_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          // Main empty state message
          Text(
            'No todos found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          // Helpful suggestion text
          Text(
            'Try adjusting your search or filter',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
