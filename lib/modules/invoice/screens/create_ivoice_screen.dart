import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/invoice/controllers/create_invoice_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
// import 'package:bizly/modules/invoice/controllers/create_invoice_controller.dart';

class CreateInvoiceScreen extends StatelessWidget {
  CreateInvoiceScreen({super.key});

  final CreateInvoiceController controller =
  Get.find<CreateInvoiceController>();

  final TextStyle sectionTitleStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Create Invoice"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔹 Client & Invoice Info
                  Text("Invoice Information", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(
                    hintText: "Client Name",
                    // prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Invoice Number",
                    // prefixIcon: Icons.receipt_long,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      /// Invoice Date
                      Expanded(
                        child: Obx(
                              () => GestureDetector(

                              onTap: () async {
                                final date = await AppUtils.pickDate();
                                if (date != null) {
                                  controller.invoiceDate .value = date;
                                }

                            },
                            child: Container(
                              height: 50,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.textField,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.invoiceDate.value == null
                                        ? "Invoice Date"
                                        : "${controller.invoiceDate.value!.day}-${controller.invoiceDate.value!.month}-${controller.invoiceDate.value!.year}",
                                    style: TextStyle(
                                      color:
                                      controller.invoiceDate.value == null
                                          ? Colors.grey.shade600
                                          : Colors.black,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      /// Status
                      Expanded(
                        child: CustomSearchDropdown(
                          height: 50,
                          horizontalPadding: 12,
                          verticalPadding: 20,
                          iconSize: 25,
                          textStyle: const TextStyle(fontSize: 13, color: Colors.black),
                          // enableSearch: true,

                          hintText: "Status",
                          items: const ["Paid", "Unpaid", "Pending"],
                          onChanged: (val) {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// 🔹 Item & Amount
                  Text("Item Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(
                    hintText: "Item Name",
                    // prefixIcon: Icons.shopping_bag_outlined,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Amount",
                    // keyboardType: TextInputType.number,
                    // prefixIcon: Icons.attach_money,
                  ),

                  const SizedBox(height: 25),

                  /// 🔹 Optional Details (Card Style)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Optional Details", style: sectionTitleStyle),
                        const SizedBox(height: 12),

                        CustomTextField(
                          hintText: "Business Name",
                          // prefixIcon: Icons.business,
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          hintText: "Notes",
                          maxLine: 3,
                          // prefixIcon: Icons.note_alt_outlined,
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.grey.shade300,width: 1)
                          ),
                          child: CustomSearchDropdown(
                            height: 50,
                            horizontalPadding: 12,
                            verticalPadding: 20,
                            iconSize: 25,
                            textStyle: const TextStyle(fontSize: 13, color: Colors.black),
                            hintText: "Payment Method",
                            items: const [
                              "Cash",
                              "Bank Transfer",
                              "EasyPaisa",
                              "JazzCash"
                            ],
                            onChanged: (val) {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Action Button
                  CustomButton(
                    text: "Create Invoice",
                    onPressed: () {
                      Get.toNamed(Routes.createInvoiceScreen);
                      // TODO: Create Invoice API Call
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
