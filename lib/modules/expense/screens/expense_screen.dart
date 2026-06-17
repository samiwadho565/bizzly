// File: lib/views/expense_screen/expense_screen.dart
import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
// import 'package:bizly/components/common/circle_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/expense/controllers/expenses_list_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/common/add_button.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/modules/expense/components/expense_card_widget.dart';
import 'package:bizly/components/home/custom_app_bar.dart';
import 'package:bizly/components/common/top_border_ccontainer.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';

class ExpenseScreen extends StatelessWidget {
  final VoidCallback? openDrawer;
  final bool embedded;

  ExpenseScreen({super.key, this.openDrawer, this.embedded = false});

  final ExpensesListController controller =
      Get.isRegistered<ExpensesListController>()
          ? Get.find<ExpensesListController>()
          : Get.put(ExpensesListController());

  @override
  Widget build(BuildContext context) {
    final String title = controller.isBusinessScoped &&
            controller.scopedBusinessName.value.trim().isNotEmpty
        ? "Expenses - ${controller.scopedBusinessName.value.trim()}"
        : "Expenses";

    final Widget content = Column(
      children: [
        Expanded(
       child:  TopBorderContainer(

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchField(
                          hintText: 'Search expenses..',
                          controller: controller.searchController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      addButton("Add Expense",onTap: (){
                        if (controller.isBusinessScoped) {
                          Get.toNamed(
                            Routes.addExpenseScreen,
                            arguments: <String, dynamic>{
                              'businessId': controller.scopedBusinessId.value,
                              'businessName': controller.scopedBusinessName.value,
                              'lockBusiness': true,
                            },
                          );
                          return;
                        }
                        Get.toNamed(Routes.addExpenseScreen);
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Obx(() {
                    final List<String> categoryNames = controller.categories
                        .map((e) => e['name']?.toString() ?? '')
                        .where((e) => e.isNotEmpty)
                        .toList();
                    final List<String> paymentNames = controller.paymentMethods
                        .map((e) => e['name']?.toString() ?? '')
                        .where((e) => e.isNotEmpty)
                        .toList();
                    final bool hasFilters =
                        controller.selectedCategoryId.value != null ||
                            controller.selectedPaymentMethodId.value != null;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomSearchDropdown(
                                height: 50,
                                hintText: "Category",
                                items: categoryNames,
                                selectedItem: controller.selectedCategoryName,
                                onChanged: controller.setCategoryFilterByName,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomSearchDropdown(
                                height: 50,
                                hintText: "Payment Method",
                                items: paymentNames,
                                selectedItem:
                                    controller.selectedPaymentMethodName,
                                onChanged:
                                    controller.setPaymentMethodFilterByName,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (hasFilters) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: controller.clearFilters,
                              child: Text(
                                'Clear Filters',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),

                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: FinancePulseLoader(),
                        );
                      }
                      if (controller.error.value.isNotEmpty) {
                        return Center(
                          child: Text(controller.error.value),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 100),
                        itemCount: controller.filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final ExpenseModel e = controller.filteredExpenses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExpenseCard(
                              title: e.title ?? '',
                              category: e.categoryName ?? '',
                              amount: e.amount?.toString() ?? '',
                              date: e.expenseDate ?? '',
                              iconPath: null,
                              onTap: () {
                                Get.toNamed(
                                  Routes.expenseDetailScreen,
                                  arguments: e,
                                );
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (embedded) return content;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: title,
        leading: Image.asset(AppImages.menu, height: 40),
        onLeadingTap: () {
          openDrawer?.call();
        },
      ),
      body: content,
    );
  }
}
