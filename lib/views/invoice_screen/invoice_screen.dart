import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../controllers/invoice_screen_controller.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_search_field.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/home_widgets/custom_app_bar.dart';
import '../../widgets/invoice_screen_widgets/invoice_card.dart';


class InvoiceScreen extends StatelessWidget {
  InvoiceScreen({super.key});

  final InvoiceScreenController controller =
  Get.put(InvoiceScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Invoices"),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// 🔍 Search + Button
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchField(
                            hintText: 'Search..',
                            controller: controller.searchController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        addButton("Create Invoice"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Status Tabs
                    Obx(() => CustomTabBar(
                      options: const ["Paid", "UnPaid"],
                      selectedOption:
                      controller.selectedStatus.value,
                      onSelect: controller.setStatus,
                    )),

                    // const SizedBox(height: 20),

                    /// Invoice List
                    Expanded(
                      child: Obx(() => ListView.builder(
                        padding: EdgeInsets.only(top: 20,bottom: 100),
                        itemCount: controller.invoices.length,
                        itemBuilder: (context, index) {
                          final invoice =
                          controller.invoices[index];
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 12),
                            child: InvoiceCard(
                              clientName: invoice["client"]!,
                              businessName: invoice["business"]!,
                              itemName: invoice["item"]!,
                              amount: invoice["amount"]!,
                              status: invoice["status"]!,
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
