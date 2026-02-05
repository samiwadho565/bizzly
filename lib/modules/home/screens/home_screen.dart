import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/circle_icon_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/common/add_button.dart';
import 'package:bizly/components/business/status_card.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/custom_tab_bar.dart';
import 'package:bizly/components/common/custom_toggle_button.dart';
import 'package:bizly/components/common/drop_down_menu/drop_down_menu.dart';
import 'package:bizly/components/home/bussiness_card.dart';
import 'package:bizly/components/home/custom_app_bar.dart';
import 'package:bizly/components/home/custom_revenue_chart.dart';
import 'package:bizly/components/home/expense_chart.dart';
import 'package:bizly/components/home/flow_chart.dart';
import 'package:bizly/components/home/side_bar.dart';
import 'package:bizly/components/common/top_border_ccontainer.dart';

class HomeScreen extends GetView<HomeScreenController> {
  final VoidCallback? openDrawer; // Callback add karein
   HomeScreen({super.key, this.openDrawer});

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> categories = [
    {'title': 'Manufacturing', 'icon': 'assets/temp/manufacturing.jpg'},
    {'title': 'Finance', 'icon': 'assets/temp/finance.jpg'},
    {'title': 'Marketing', 'icon': 'assets/temp/markeeting.jpg'},
    {'title': 'HR', 'icon': 'assets/temp/hr.jpg'},
    {'title': 'IT', 'icon':  'assets/temp/it.jpg'},
    {'title': 'Logistics', 'icon': 'assets/temp/logistics.jpg'},
    {'title': 'Manufacturing', 'icon': 'assets/temp/manufacturing.jpg'},
    {'title': 'Finance', 'icon': 'assets/temp/finance.jpg'},
    {'title': 'Marketing', 'icon': 'assets/temp/markeeting.jpg'},
    {'title': 'HR', 'icon': 'assets/temp/hr.jpg'},
    {'title': 'IT', 'icon':  'assets/temp/it.jpg'},
    {'title': 'Logistics', 'icon': 'assets/temp/logistics.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColors.background,
      extendBody: true,
      drawer: const CustomSideBar(),
      appBar: CustomAppBar(
        title: "Dashboard",
        leading: Image.asset(AppImages.menu, height: 40),
        onLeadingTap: () {
          controller.scaffoldKey.currentState?.openDrawer();
        },
      ),

    body: Column(
        children: [

          // SizedBox(
          //   height: Get.size.height/7.5
          // ),
          Expanded(
            child:  TopBorderContainer(
              // padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Quick Action",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Container(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                         // child: addDropdownButton(leftText: 'Quick Actions',title: "Add")
                          child: CupertinoButton(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            onPressed: (){
                              Get.toNamed(Routes.addNewBusiness);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  "Add New Business",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                       fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 10),
                  // SizedBox(height: 20,),
                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  //     child: SizedBox(
                  //       width: Get.width/1.5,
                  //       child: CustomSearchDropdown(
                  //         height: 40,
                  //         horizontalPadding: 12,
                  //         verticalPadding: 20,
                  //         iconSize: 25,
                  //         textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                  //         enableSearch: true,
                  //         hintText: "Select Business",
                  //         items: const ["Fixonto", "SilverSpoon", "TechNova", "GreenLeaf"],
                  //         onChanged: (value) {},
                  //       ),
                  //     ),
                  //   ),
                  // ),
               Expanded(
                 child: SingleChildScrollView(
                   child: Column(
                     children: [
                     // Padding(
                     //       padding: const EdgeInsets.symmetric(horizontal: 20),
                     //       child: Column(
                     //         children: [
                     //
                     //           Row(
                     //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     //             children: const [
                     //               StatCard(
                     //                 title: "Total Revenue",
                     //                 value: "4,250,000",
                     //                 icon: Icon(Icons.attach_money, color: Colors.green),
                     //                 backgroundColor: Color(0xFFF7FBF7),
                     //                 contentColor: Colors.green,
                     //               ),
                     //               StatCard(
                     //                 title: "Team Members",
                     //                 value: "2",
                     //                 icon: Icon(
                     //                   Icons.groups,
                     //                   color: Colors.blue,
                     //                 ),
                     //                 backgroundColor: Color(0xFFF1F7FF),
                     //                 contentColor: Colors.blue,
                     //               ),
                     //             ],
                     //           ),
                     //           SizedBox(height: 20,),
                     //           Row(
                     //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     //             children: [
                     //               StatCard(
                     //                 title: "Total Expenses",
                     //                 value: "1,250",
                     //                 icon: const Icon(
                     //                   Icons.arrow_upward,
                     //                   color: Colors.red,
                     //                 ),
                     //                 backgroundColor: const Color(0xFFFFF5F5),
                     //                 contentColor: Colors.red.shade400,
                     //               ),
                     //
                     //               StatCard(
                     //                 title: "Pending Tasks",
                     //                 value: "2",
                     //                 icon: const Icon(
                     //                   Icons.assignment_outlined,
                     //                   color: Colors.orange,
                     //                 ),
                     //                 backgroundColor: const Color(0xFFFFF9F0),
                     //                 contentColor: Colors.orange.shade400,
                     //               ),
                     //             ],
                     //           ),
                     //           const SizedBox(height: 16),
                     //         ],
                     //       ),
                     //     ),

                       const SizedBox(height: 20),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20.0),
                         child: WeeklyRevenueChart(),
                       ),
                       const SizedBox(height: 20),
                       // Padding(
                       //   padding: const EdgeInsets.symmetric(horizontal: 20),
                       //   child: BusinessTeamSection(),
                       // ),
                       // Padding(
                       //   padding: const EdgeInsets.symmetric(horizontal: 20),
                       //   child: _buildRecentInvoices(),
                       // ),
                       //const SizedBox(height: 100),
                       // addButton(),
                       // CustomTabBar(items: ["tasks","test","test"], onTabChanged: (int ) {  },),
                       // CustomToggleButton(items: ["tasks","test","test"], onSelected: (int ) {  },),

                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text("All Businesses",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),

                             // TextButton(onPressed: (){
                             //   Get.toNamed(Routes.allBusinessScreen);
                             // }, child: Text("View All",style: TextStyle(color: AppColors.primary),),)
                           ],
                         ),
                       ),
                       SizedBox(height: 15,),
                       // ---------------- GridView ----------------
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         child: GridView.builder(
                           padding: EdgeInsets.only(bottom: 120),
                           physics: const NeverScrollableScrollPhysics(), // Scroll disable
                           shrinkWrap: true,
                           itemCount: categories.length,
                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                               crossAxisCount: 3, // 2 columns
                               // crossAxisSpacing: 3,
                               mainAxisSpacing: 0,
                               childAspectRatio: 1 // Width / Height ratio
                           ),
                           itemBuilder: (context, index) {
                             final category = categories[index];
                             return CategoryCard(
                               title: category['title'],
                               image: category['icon'],
                               onTap: () {
                                 print("tapped::${category['title']} clicked");
                                 Get.toNamed(Routes.businessDetailScreen,);

                               },
                             );
                           },
                         ),
                       ),
                     ],
                   ),
                 ),
               )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildRecentInvoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Invoices",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {}, // Navigate to Invoices Screen
              child: const Text("See All", style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Invoice Cards
        _invoiceItem("Lisa Smith", "PKR 50,000", "Paid", Colors.green),
        _invoiceItem("John Doe", "PKR 12,000", "Pending", Colors.orange),
        _invoiceItem("Alex Miller", "PKR 8,500", "Overdue", Colors.red),
      ],
    );
  }

  Widget _invoiceItem(String name, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(amount, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
