// File: lib/views/expense_screen/expense_screen.dart
import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
// import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/expense_screen_controller.dart';
import '../../routes/routes.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_search_field.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/expense_widgets/expense_card_widget.dart';
import '../../widgets/home_widgets/custom_app_bar.dart';
import '../../widgets/top_border_ccontainer.dart';

class ExpenseScreen extends StatelessWidget {
  ExpenseScreen({super.key});

  final ExpenseScreenController controller = Get.put(ExpenseScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Expenses"),
      body: Column(
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
                          Get.toNamed(Routes.addExpenseScreen);
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Obx(() => CustomTabBar(
                    //   options: const ["All", "Business", "Personal"],
                    //   selectedOption: controller.selectedCategory.value,
                    //   onSelect: controller.setCategory,
                    // )),



                    Expanded(
                      child: Obx(() => ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 100),
                        itemCount: controller.filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final e = controller.filteredExpenses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child:  ExpenseCard(

                              title: e["title"] ?? '',
                              category: e["category"] ?? '',
                              amount: e["amount"] ?? '',
                              date: e["date"] ?? '',
                              iconPath: e["icon"],
                              onTap: () {
                                Get.toNamed(Routes.expenseDetailScreen);
                                // placeholder for tap action
                              },
                            ),
                          );
                        },
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
