import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.priority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const StatusBadge(
          label: 'High',
          color: Colors.red,
          icon: Icons.flag,
        );
      case 'medium':
        return const StatusBadge(
          label: 'Medium',
          color: Colors.orange,
          icon: Icons.flag,
        );
      default:
        return const StatusBadge(
          label: 'Low',
          color: Colors.green,
          icon: Icons.flag,
        );
    }
  }

  factory StatusBadge.rsvp(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const StatusBadge(
          label: 'Confirmed',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case 'declined':
        return const StatusBadge(
          label: 'Declined',
          color: Colors.red,
          icon: Icons.cancel,
        );
      default:
        return const StatusBadge(
          label: 'Pending',
          color: Colors.orange,
          icon: Icons.schedule,
        );
    }
  }

  factory StatusBadge.booking(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'accepted':
        return const StatusBadge(
          label: 'Confirmed',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case 'completed':
        return const StatusBadge(
          label: 'Completed',
          color: Colors.blue,
          icon: Icons.done_all,
        );
      case 'cancelled':
      case 'declined':
        return const StatusBadge(
          label: 'Cancelled',
          color: Colors.red,
          icon: Icons.cancel,
        );
      default:
        return const StatusBadge(
          label: 'Pending',
          color: Colors.orange,
          icon: Icons.schedule,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
