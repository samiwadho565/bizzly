import 'package:flutter/material.dart';

class BusinessTeamSection extends StatelessWidget {
  const BusinessTeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final team = [
      {
        "name": "Ahmed Ali",
        "role": "Manager",
      },
      {
        "name": "Sara Khan",
        "role": "Accountant",
      },
      {
        "name": "Usman Shah",
        "role": "Sales Executive",
      },
      {
        "name": "Ayesha Noor",
        "role": "HR Officer",
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Business Team",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("View All"),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 Team List
          Column(
            children: team.map((member) {
              return _TeamTile(
                name: member["name"]!,
                role: member["role"]!,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final String name;
  final String role;

  const _TeamTile({
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          /// 👤 Avatar (Initials)
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              name[0],
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// 📛 Name + Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          /// ➡️ Arrow
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
