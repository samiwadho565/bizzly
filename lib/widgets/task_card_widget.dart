import 'package:flutter/material.dart';

class TaskCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String userName;
  final String status;
  final String userImageUrl;

  const TaskCardWidget ({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.userName,
    required this.status,
    this.userImageUrl = 'https://i.pravatar.cc/150?u=a042581f4e29026704d', // Dummy image
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light grey background jaisa image mein hai
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title aur Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Tag (e.g., Low)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Row
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(fontSize: 15, color:Colors.black,fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User/Assignee Row
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(userImageUrl),
              ),
              const SizedBox(width: 8),
              Text(
                userName,
                style: const TextStyle(fontSize: 15,  color:Colors.black,fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}