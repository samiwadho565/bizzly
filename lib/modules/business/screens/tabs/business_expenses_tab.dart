import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/business/controllers/business_activity_controller.dart';
import 'package:bizly/modules/expense/components/expense_card_widget.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';
import 'package:bizly/routes/routes.dart';
class BusinessExpensesTab extends StatelessWidget {
  const BusinessExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessActivityController>();
    return Obx(() {
      if (controller.isExpensesLoading.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: FinancePulseLoader()),
          ),
        );
      }

      if (controller.expensesError.value.isNotEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(child: Text(controller.expensesError.value)),
          ),
        );
      }

      if (controller.expenses.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text("No expenses available")),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final ExpenseModel expense = controller.expenses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpenseCard(
              title: expense.title ?? '',
              category: expense.categoryName ?? '',
              amount: _amount(expense.amount),
              date: expense.expenseDate ?? '',
              iconPath: null,
              onTap: () {
                Get.toNamed(
                  Routes.expenseDetailScreen,
                  arguments: expense,
                );
              },
            ),
          );
        }, childCount: controller.expenses.length),
      );
    });
  }

  String _amount(dynamic raw) {
    if (raw is num) return 'Rs. ${raw.toStringAsFixed(raw % 1 == 0 ? 0 : 2)}';
    final String normalized = raw?.toString().trim() ?? '';
    if (normalized.isEmpty) return 'Rs. 0';
    return 'Rs. $normalized';
  }
}
