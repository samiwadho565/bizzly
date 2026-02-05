import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/circle_icon_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/common/add_button.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/custom_tab_bar.dart';
import 'package:bizly/components/home/custom_app_bar.dart';
import 'package:bizly/components/invoice/invoice_card.dart';
import 'package:bizly/components/common/top_border_ccontainer.dart';


class InvoiceScreen extends StatelessWidget {
  InvoiceScreen({super.key});

  final InvoiceScreenController controller =
  Get.find<InvoiceScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Invoices"),
      body: Column(
        children: [
          Expanded(
            child:  TopBorderContainer(
              // padding: const EdgeInsets.symmetric(horizontal: 20),
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    /// 🔍 Search + Button
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchField(
                            hintText: 'Search invoice..',
                            controller: controller.searchController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        addButton("Create Invoice",onTap: (){

                            Get.toNamed(Routes.createInvoiceScreen);
                        }),
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
                          return GestureDetector(
                            onTap: (){
                              Get.toNamed(Routes.invoiceDetailScreen);
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.only(bottom: 12),
                              child: InvoiceCard(
                                clientName: invoice["client"]!,
                                businessName: invoice["business"]!,
                                itemName: invoice["item"]!,
                                amount: invoice["amount"]!,
                                status: invoice["status"]!,
                              ),
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
