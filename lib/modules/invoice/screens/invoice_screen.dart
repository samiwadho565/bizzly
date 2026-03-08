import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/common/add_button.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/home/custom_app_bar.dart';
import 'package:bizly/components/invoice/invoice_card.dart';
import 'package:bizly/components/common/top_border_ccontainer.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/assets/images.dart';


class InvoiceScreen extends StatelessWidget {
  final VoidCallback? openDrawer;

  InvoiceScreen({super.key, this.openDrawer});

  final InvoiceScreenController controller =
      Get.isRegistered<InvoiceScreenController>()
          ? Get.find<InvoiceScreenController>()
          : Get.put(InvoiceScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Invoices",
        leading: Image.asset(AppImages.menu, height: 40),
        onLeadingTap: () {
          openDrawer?.call();
        },
      ),
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

                    /// Invoice List
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: FinancePulseLoader());
                        }
                        if (controller.error.value.isNotEmpty) {
                          return Center(child: Text(controller.error.value));
                        }
                        if (controller.filteredInvoices.isEmpty) {
                          return const Center(
                            child: Text("No invoices found."),
                          );
                        }
                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: controller.fetchInvoices,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 20, bottom: 100),
                            itemCount: controller.filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoice = controller.filteredInvoices[index];
                              final String itemName = invoice.items.isNotEmpty
                                  ? invoice.items.first.itemName
                                  : "-";
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    Routes.invoiceDetailScreen,
                                    arguments: invoice,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InvoiceCard(
                                    clientName: invoice.customerName ?? '-',
                                    businessName: invoice.businessName ?? '-',
                                    itemName: itemName,
                                    amount: invoice.totalAmount?.toString() ?? '-',
                                    status: invoice.status ?? '-',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
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
