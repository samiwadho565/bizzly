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
import '../../widgets/task_card_widget.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen ({super.key});

  @override
  State<TasksScreen > createState() => _HomeScreenState();
}

class _HomeScreenState extends State<TasksScreen > {
  // final List<Map<String, dynamic>> categories = [
  //   {'title': 'Manufacturing', 'icon': Icons.settings_outlined},
  //   {'title': 'Finance', 'icon': Icons.attach_money_outlined},
  //   {'title': 'Marketing', 'icon': Icons.campaign_outlined},
  //   {'title': 'HR', 'icon': Icons.people_alt_outlined},
  //   {'title': 'IT', 'icon': Icons.computer_outlined},
  //   {'title': 'Logistics', 'icon': Icons.local_shipping_outlined},
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
          title:Text( "Tasks",style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w500),),
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


            ],
          )

      ),
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
                        Text("Tasks",style: TextStyle(fontSize:21,color: Colors.black,fontWeight: FontWeight.w600),),
                        addButton(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(

                        child: CustomToggleButton(items: ["Today","Tomorrow","This Week"], onSelected: (int ) {  },)),


                    Row(
                      children: [
                       CustomToggleButton(items: ["Today","Tomorrow","This Week"], onSelected: (int ) {  },),

                       CustomToggleButton(items: ["Low","Medium","High"], onSelected: (int ) {  },),
                      ],
                    ),
                   CustomTabBar(items: ["Low","Medium","High"], onTabChanged: (int ) {  },),

                    // ---------------- GridView ----------------
                    // Expanded(
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 30),
                    //     child: GridView.builder(
                    //       itemCount: categories.length,
                    //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //         crossAxisCount: 3, // 2 columns
                    //         crossAxisSpacing: 16,
                    //         mainAxisSpacing: 16,
                    //         childAspectRatio: 1, // Width / Height ratio
                    //       ),
                    //       itemBuilder: (context, index) {
                    //         final category = categories[index];
                    //         return CategoryCard(
                    //           title: category['title'],
                    //           icon: category['icon'],
                    //           onTap: () {
                    //             print("${category['title']} clicked");
                    //           },
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                    TaskCardWidget(title: 'inventory', subtitle: 'manage inventory stock', date: '19-12-2026',userName: 'Jhon Deo', status: 'Low',)
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
