import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../widgets/add_button.dart';
import '../../widgets/custom_drop_down.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/custom_toggle_button.dart';
import '../../widgets/home_widgets/bussiness_card.dart';
import '../../widgets/home_widgets/custom_app_bar.dart';
import '../../widgets/home_widgets/custom_revenue_chart.dart';
import '../../widgets/home_widgets/flow_chart.dart';
import '../../widgets/invoice_screen_widgets/invoice_card.dart';
import '../../widgets/projects_screen_widgets/project_detail_card.dart';
import '../../widgets/task_card_widget.dart';

class InvoiceScreen extends StatelessWidget {
 InvoiceScreen({super.key});
  final List<Map<String, String>> invoices = [
    {
      "client": "John Doe",
      "business": "TechNova",
      "item": "Website Design",
      "amount": "\$500",
      "status": "Paid",
    },
    {
      "client": "Robert De Niro",
      "business": "Crypto Trading",
      "item": "Mobile App",
      "amount": "\$1200",
      "status": "Paid",
    },
    {
      "client": "Jack Smith",
      "business": "Fixonto",
      "item": "Backend Setup",
      "amount": "\$800",
      "status": "Paid",
    },
  ];

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
                    topLeft: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Status",style: TextStyle(fontSize:21,color: Colors.black,fontWeight: FontWeight.w600),),
                        addButton("Create Invoice"),
                      ],
                    ),
                    SizedBox(height: 10,),
                    // Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text("Status",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                    //
                    SizedBox(height: 10,),
                    CustomTabBar(
                      borderRadius: 12,
                      items: ["Paid","UnPaid",], onTabChanged: (int ) {  },),
                    SizedBox(height: 20,),
                    // ---------------- GridView ----------------
                    Expanded(
                        child: ListView.builder(
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InvoiceCard(
                                clientName: invoice["client"]!,
                                businessName: invoice["business"]!,
                                itemName: invoice["item"]!,
                                amount: invoice["amount"]!,
                                status: invoice["status"]!,
                              ),
                            );
                          },
                        )

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
