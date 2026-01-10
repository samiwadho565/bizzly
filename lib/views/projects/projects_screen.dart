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
import '../../widgets/projects_screen_widgets/project_detail_card.dart';
import '../../widgets/task_card_widget.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen ({super.key});

  @override
  State<ProjectsScreen > createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final List<Map<String, String>> projects = [
    {
      "title": "Inventory Management",
      "owner": "John Deo",
      "status": "Low",
      "date": "10-02-2025 - 10-02-2026",
    },
    {
      "title": "Crypto Trading App",
      "owner": "Ali Traders",
      "status": "Active",
      "date": "26-11-2025 - 02-12-2025",
    },
    {
      "title": "E-Commerce Website",
      "owner": "Fixonto",
      "status": "Completed",
      "date": "01-01-2025 - 01-06-2025",
    },
    {
      "title": "HR Management System",
      "owner": "TechNova",
      "status": "High",
      "date": "15-03-2025 - 15-09-2025",
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:  CustomAppBar(title: "Projects"),
      body:     Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status",style: TextStyle(fontSize:21,color: Colors.black,fontWeight: FontWeight.w600),),
                  addButton("Add Project"),
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
                items: ["Active","Completed",], onTabChanged: (int ) {  },),

              // ---------------- GridView ----------------
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 20,bottom: 70),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProjectDetailCard(
                        title: project["title"]!,
                        ownerName: project["owner"]!,
                        status: project["status"]!,
                        dateRange: project["date"]!,
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
