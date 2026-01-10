import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../../widgets/business_screen_widgets/status_card.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/drop_down_menu/drop_down_menu.dart';
import '../../widgets/invoice_screen_widgets/invoice_card.dart';
import '../../widgets/task_card_widget.dart';


class BusinessDetailScreen extends StatelessWidget {
  BusinessDetailScreen({super.key});
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
      "client": "John Doe",
      "business": "TechNova",
      "item": "Website Design",
      "amount": "\$500",
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
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(40),
              topLeft: Radius.circular(40)),
        ),
        child: CustomScrollView( // 1. SingleChildScrollView ki jagah ye use karein
          slivers: [
            // --- Top Content (Quick Actions aur Cards) ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    addDropdownButton(leftText: 'Quick Actions'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatCard(title: "Total Revenue", value: "\$4,250,000", icon: const Icon(Icons.attach_money, color: Colors.green), backgroundColor: const Color(0xFFF7FBF7), contentColor: Colors.green.shade700),
                        StatCard(title: "Active Projects", value: "2", icon: const Icon(Icons.bar_chart_rounded, color: Colors.blue), backgroundColor: const Color(0xFFF1F7FF), contentColor: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatCard(title: "Total Expenses", value: "\$1,250", icon: const Icon(Icons.arrow_upward, color: Colors.red), backgroundColor: const Color(0xFFFFF5F5), contentColor: Colors.red.shade400),
                        StatCard(title: "Pending Tasks", value: "2", icon: const Icon(Icons.assignment_outlined, color: Colors.orange), backgroundColor: const Color(0xFFFFF9F0), contentColor: Colors.orange.shade400),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // --- 2. Sticky TabBar ---
            SliverPersistentHeader(
              pinned: true, // Ye line isay top par stuck rakhegi
              delegate: _StickyTabBarDelegate(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTabBar(
                    height: 40,
                    borderRadius: 11,
                    items: ["Overview", "Invoices", "Expenses", "Tasks", "Projects"],
                    onTabChanged: (int index) {},
                  ),
                ),
              ),
            ),

            // --- 3. ListView Content ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    // final invoice = invoices[index];
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
                      // child: InvoiceCard(
                      //   clientName: invoice["client"]!,
                      //   businessName: invoice["business"]!,
                      //   itemName: invoice["item"]!,
                      //   amount: invoice["amount"]!,
                      //   status: invoice["status"]!,
                      // ),
                    );
                  },
                  childCount: invoices.length,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60.0; // TabBar ki height + padding
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Sticky hone par background color
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}