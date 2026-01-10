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
  State<TasksScreen > createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen > {
  final List<Map<String, String>> tasks = [
    {
      "title": "Inventory",
      "subtitle": "Manage inventory stock",
      "date": "19-12-2026",
      "user": "John Deo",
      "status": "Low",
    },
    {
      "title": "Update Prices",
      "subtitle": "Revise product pricing",
      "date": "20-12-2026",
      "user": "Ali Traders",
      "status": "Medium",
    },
    {
      "title": "Server Backup",
      "subtitle": "Weekly system backup",
      "date": "22-12-2026",
      "user": "Tech Team",
      "status": "High",
    },
    {
      "title": "UI Improvements",
      "subtitle": "Dashboard UI polishing",
      "date": "25-12-2026",
      "user": "Design Team",
      "status": "Low",
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:  CustomAppBar(title: "Tasks"),
      body: Container(
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
                  addButton("Add Task"),
                ],
              ),
              const SizedBox(height: 20),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Due Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                      SizedBox(
                        height: 10,
                      ),

                      CustomTabBar(
                        fontSize: 12,
                        height: 35,
                        width: Get.size.height/4.4,

                        borderRadius: 20,
                        selectedTextColor: Colors.black,
                        selectedColor:  AppColors.lightGrey,
                        items: ["Today","Tomorrow","This Week"], onTabChanged: (int p1) {  },),
                    ],
                  ),
                  // CustomToggleButton(items: ["Today","Tomorrow","This Week"], onSelected: (int ) {  },),

                  SizedBox(width: 20,),


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Priority",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                        SizedBox(
                          height: 10,
                        ),
                        CustomTabBar(
                          fontSize: 12,
                          height: 35,
                          // width: 220,
                          borderRadius: 20,
                          selectedTextColor: Colors.black,
                          selectedColor:  AppColors.lightGrey,
                          items:["Low","Medium","High"], onTabChanged: (int p1) {  },),
                      ],
                    ),
                  ),

                  // CustomToggleButton(items: ["Low","Medium","High"], onSelected: (int ) {  },),
                  //
                ],
              ),
              SizedBox(height: 20,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Status",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
              SizedBox(height: 10,),
              CustomTabBar(
                borderRadius: 12,
                items: ["Done","In Process","To-Do"], onTabChanged: (int ) {  },),
              SizedBox(height: 20,),
              // ---------------- List View ----------------

              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCardWidget(
                        title: task["title"]!,
                        subtitle: task["subtitle"]!,
                        date: task["date"]!,
                        userName: task["user"]!,
                        status: task["status"]!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
