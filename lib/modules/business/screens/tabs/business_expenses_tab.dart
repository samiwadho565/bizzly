import 'package:flutter/material.dart';

class BusinessExpensesTab extends StatelessWidget {
  const BusinessExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: Text("No expenses available")),
      ),
    );
  }
}
