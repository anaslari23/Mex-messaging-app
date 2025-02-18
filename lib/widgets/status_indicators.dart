import 'package:flutter/material.dart';

class StatusIndicators extends StatelessWidget {
  final bool isDelivered;
  final bool isRead;
  final bool isOnline;

  const StatusIndicators({
    required this.isDelivered,
    required this.isRead,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isRead) const Icon(Icons.done_all, size: 16, color: Colors.blue),
        if (isDelivered && !isRead)
          const Icon(Icons.done_all, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        )
      ],
    );
  }
}
