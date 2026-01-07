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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> categories = [
    {'title': 'Manufacturing', 'icon': Icons.settings_outlined},
    {'title': 'Finance', 'icon': Icons.attach_money_outlined},
    {'title': 'Marketing', 'icon': Icons.campaign_outlined},
    {'title': 'HR', 'icon': Icons.people_alt_outlined},
    {'title': 'IT', 'icon': Icons.computer_outlined},
    {'title': 'Logistics', 'icon': Icons.local_shipping_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title:Text( "Dashboard",style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w500),),
        // leading:  const Icon(Icons.menu_open,color: Colors.black, size: 30), // Menu icon jaisa image mein hai
        trailing: Row(
          children: [
       CircleIcon(
         circleSize: 37,
         circleColor: Colors.white,
         icon: Icons.notifications,
          iconColor: Colors.black,
          size: 20,
       ),
      SizedBox(width: 10,),
      CircleAvatar(
              radius: 18,
            backgroundImage: AssetImage(AppImages.profilePlaceholder),
              backgroundColor: Colors.red
            ),

            // Positioned(
            //   // right: 8,
            //   // top: 8,
            //   child: const CircleAvatar(
            //     radius: 18,
            //     backgroundImage: NetworkImage(
            //         "https://your-image-url.com/notification_icon.png"),
            //     backgroundColor: Colors.transparent,
            //   ),
            // ),
          ],
        )
        //
        // hasNotification: true, // Dot dikhane ke liye
        // onNotificationTap: () {
        //   print("Notification clicked!");
        // },
        // onProfileTap: () {
        //   print("Profile clicked!");
        // },
      ),
      body: Column(
        children: [

          // SizedBox(
          //   height: Get.size.height/7.5
          // ),
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomSearchDropdown(
                      height: 40,
                      horizontalPadding: 12,
                      verticalPadding: 20,
                      iconSize: 25,
                      textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                      enableSearch: true,
                      hintText: "Select Business",
                      items: const ["Fixonto", "SilverSpoon", "TechNova", "GreenLeaf"],
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: WeeklyRevenueChart(),
                  ),
                  const SizedBox(height: 20),
                  // addButton(),
                  // CustomTabBar(items: ["tasks","test","test"], onTabChanged: (int ) {  },),
                  // CustomToggleButton(items: ["tasks","test","test"], onSelected: (int ) {  },),
                  //
                  // ---------------- GridView ----------------
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: GridView.builder(
                        itemCount: categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 2 columns
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1, // Width / Height ratio
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            title: category['title'],
                            icon: category['icon'],
                            onTap: () {
                              print("${category['title']} clicked");
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
