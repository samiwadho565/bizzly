import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../widgets/add_button.dart';
import '../../widgets/business_screen_widgets/status_card.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_drop_down.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/custom_toggle_button.dart';
import '../../widgets/drop_down_menu/drop_down_menu.dart';
import '../../widgets/home_widgets/bussiness_card.dart';
import '../../widgets/home_widgets/custom_app_bar.dart';
import '../../widgets/home_widgets/custom_revenue_chart.dart';
import '../../widgets/home_widgets/flow_chart.dart';
import '../../widgets/invoice_screen_widgets/invoice_card.dart';
import '../../widgets/projects_screen_widgets/project_detail_card.dart';
import '../../widgets/task_card_widget.dart';

class BusinessDetailScreen extends StatelessWidget {
  BusinessDetailScreen({super.key});

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
      appBar: CustomAppBar2(title: "Service"),
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
                    addDropdownButton(leftText: 'Quick Actions'),
                    SizedBox(height: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Business Details",
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          // 1. Total Revenue
                          StatCard(
                            title: "Total Revenue",
                            value: "\$4,250,000",
                            icon: const Icon(Icons.attach_money, color: Colors.green),
                            backgroundColor: const Color(0xFFF7FBF7), // Light Greenish white
                            contentColor: Colors.green.shade700,
                          ),
                          // 2. Active Projects
                          StatCard(
                            title: "Active Projects",
                            value: "2",
                            icon: const Icon(Icons.bar_chart_rounded, color: Colors.blue),
                            backgroundColor: const Color(0xFFF1F7FF), // Light Blue
                            contentColor: Colors.blue,
                          ),
                          // 3. Total Expenses

                        ],
                      ),
                        const SizedBox(height: 16),
                        Row(

                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                          StatCard(
                            title: "Total Expenses",
                            value: "\$1,250",
                            icon: const Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                            backgroundColor: const Color(0xFFFFF5F5), // Light Red/Pink
                            contentColor: Colors.red.shade400,
                          ),
                          // 4. Pending Tasks
                          StatCard(
                            title: "Pending Tasks",
                            value: "2",
                            icon: const Icon(Icons.assignment_outlined, color: Colors.orange),
                            backgroundColor: const Color(0xFFFFF9F0), // Light Orange/Beige
                            contentColor: Colors.orange.shade400,
                          ),
                        ],)
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text("Status",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                    //
                    // SizedBox(height: 10,),
                    CustomTabBar(
                      height: 40,
                      borderRadius: 11,
                      items: ["Overview","Invoices","Expenses","Tasks","Projects",], onTabChanged: (int ) {  },),
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
