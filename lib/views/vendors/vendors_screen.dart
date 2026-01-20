import 'package:bizly/views/vendors/vendor_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/vendor_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_search_field.dart';
import '../../widgets/custom_app_bar_2.dart';
import 'create_vendor_screen.dart';
// import 'vendor_detail_screen.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<VendorModel> allVendors = [];
  List<VendorModel> filteredVendors = [];

  @override
  void initState() {
    super.initState();

    /// 🔹 Dummy Vendors
    allVendors = [
      VendorModel(
        name: "Ali Traders",
        email: "ali@traders.com",
        phone: "+92 300 1112233",
        address: "Karachi",
        secondaryPhone: "+92 300 9988776",
        companyName: "Ali Traders Pvt Ltd",
        taxNumber: "VTX-12345",
        website: "www.alitraders.com",
        notes: "Main supplier",
        city: "Karachi",
        country: "Pakistan",
      ),
      VendorModel(
        name: "Global Supplies",
        email: "contact@globalsupplies.com",
        phone: "+92 301 4455667",
        address: "Lahore",
        secondaryPhone: "+92 301 2233445",
        companyName: "Global Supplies Co",
        taxNumber: "VTX-77889",
        website: "www.globalsupplies.com",
        notes: "Monthly payments",
        city: "Lahore",
        country: "Pakistan",
      ),
      VendorModel(
        name: "Tech Parts",
        email: "sales@techparts.com",
        phone: "+92 302 6677889",
        address: "Islamabad",
        secondaryPhone: "+92 302 1122334",
        companyName: "Tech Parts Ltd",
        taxNumber: "VTX-45678",
        website: "www.techparts.com",
        notes: "Hardware supplier",
        city: "Islamabad",
        country: "Pakistan",
      ),
    ];

    filteredVendors = allVendors;
  }

  void _filterVendors(String query) {
    if (query.isEmpty) {
      setState(() => filteredVendors = allVendors);
    } else {
      setState(() {
        filteredVendors = allVendors
            .where((v) =>
        v.name.toLowerCase().contains(query.toLowerCase()) ||
            v.email.toLowerCase().contains(query.toLowerCase()) ||
            v.phone.contains(query))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          /// 🔹 Header + Search
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryDense,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const CustomAppBar2(
                  title: "Vendors",
                  backgroundColor: AppColors.primaryDense,
                  textColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomSearchField(
                    hintText: "Search Vendors...",
                    controller: _searchController,
                    onChanged: _filterVendors,
                    onClear: () => _filterVendors(""),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 Vendors List
          Expanded(
            child: filteredVendors.isEmpty
                ? const Center(child: Text("No vendors found"))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: filteredVendors.length,
              itemBuilder: (context, index) {
                final vendor = filteredVendors[index];
                return InkWell(
                  onTap: () {
                    Get.to(() => VendorDetailScreen(vendor: vendor));
                  },
                  child: _vendorCard(vendor),
                );
              },
            ),
          ),
        ],
      ),

      /// ➕ Add Vendor
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.to(() => CreateVendorScreen());

          // TODO: Navigate to AddVendorScreen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🔹 Vendor Card
  Widget _vendorCard(VendorModel vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              vendor.name[0],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vendor.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  vendor.phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
