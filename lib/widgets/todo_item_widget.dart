import 'package:flutter/material.dart';
import 'package:interview_project/models/todo.dart';

/// A reusable widget that displays a single todo item in a card format.
///
/// Features:
/// - Visual status indicator (green/grey dot)
/// - Title with strikethrough for inactive todos
/// - Description with text overflow handling
/// - Relative date formatting (Today, Yesterday, etc.)
/// - Active/Inactive status badge
class TodoItemWidget extends StatelessWidget {
  final Todo todo;

  const TodoItemWidget({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        // Status indicator dot
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: todo.isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        // Todo title with conditional strikethrough
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: todo.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        // Description and metadata section
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description (only show if not empty)
            if (todo.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                todo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Date and status row
            Row(
              children: [
                // Date icon and text
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(todo.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: todo.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todo.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: todo.isActive
                          ? Colors.green[700]
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  /// Formats a DateTime into a user-friendly relative date string.
  ///
  /// Examples:
  /// - Same day: "Today"
  /// - Previous day: "Yesterday"
  /// - Within a week: "X days ago"
  /// - Older: "DD/MM/YYYY"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
