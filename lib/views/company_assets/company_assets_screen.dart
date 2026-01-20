import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/assets_model.dart';
import '../../routes/routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dialouge.dart';
import '../../widgets/custom_search_field.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_button.dart';


class CompanyAssetsScreen extends StatefulWidget {
  const CompanyAssetsScreen({super.key});

  @override
  State<CompanyAssetsScreen> createState() => _CompanyAssetsScreenState();
}

class _CompanyAssetsScreenState extends State<CompanyAssetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AssetModel> allAssets = [];
  List<AssetModel> filteredAssets = [];

  @override
  void initState() {
    super.initState();

    // Dummy assets
    allAssets = [
      AssetModel(
        name: "Dell Laptop",
        type: "Electronics",
        assignedTo: "John Doe",
        purchaseDate: "2024-01-05",
        value: "150,000",
        status: "Active",
      ),
      AssetModel(
        name: "Office Chair",
        type: "Furniture",
        assignedTo: "Jane Smith",
        purchaseDate: "2023-11-12",
        value: "12,000",
        status: "Active",
      ),
      AssetModel(
        name: "Projector",
        type: "Electronics",
        assignedTo: "Ali Khan",
        purchaseDate: "2023-06-20",
        value: "90,000",
        status: "Inactive",
      ),
    ];

    filteredAssets = allAssets;
  }

  void _filterAssets(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredAssets = allAssets;
      });
    } else {
      setState(() {
        filteredAssets = allAssets
            .where((a) =>
        a.name.toLowerCase().contains(query.toLowerCase()) ||
            a.type.toLowerCase().contains(query.toLowerCase()) ||
            a.assignedTo.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: const CustomAppBar2(
      //   title: "Company Assets",
      //   backgroundColor: AppColors.primaryDense,
      //   textColor: Colors.white,
      // ),
      body: Column(
        children: [
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
                  title: "Company Assets",
                  backgroundColor: AppColors.primaryDense,
                  textColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomSearchField(
                    hintText: "Search Assets...",
                    controller: _searchController,
                    onChanged: _filterAssets,
                    onClear: () => _filterAssets(""),
                  ),
                ),
              ],
            ),
          ),





          // 🔹 Assets List
          Expanded(
            child: filteredAssets.isEmpty
                ? const Center(
              child: Text("No assets found"),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 10),
              itemCount: filteredAssets.length,
              itemBuilder: (context, index) {
                final asset = filteredAssets[index];
                return _assetCard(asset);
              },
            ),
          ),
        ],
      ),

      // 🔹 Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.toNamed(Routes.addCompanyAssetScreen);
          // TODO: Navigate to AddAssetScreen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🔹 Asset Card
  /// 🔹 Asset Card with Edit/Delete
  Widget _assetCard(AssetModel asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // More rounded corners for modern look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Header: Icon + Name & Price + Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset Icon (Modern look)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryDense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.inventory_2_outlined, color: AppColors.primaryDense, size: 24),
              ),
              const SizedBox(width: 12),

              // Name and Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      asset.type,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Popup Menu
              _buildPopupMenu(asset),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),

          /// 🔹 Body: Price & Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Value", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(height: 2),
                  Text(
                    "PKR ${asset.value}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDense
                    ),
                  ),
                ],
              ),

              // Date and Assignee Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _iconDetailRow(Icons.calendar_today, asset.purchaseDate),
                  const SizedBox(height: 6),
                  _iconDetailRow(Icons.person_outline, asset.assignedTo),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper for Icon + Text Row
  Widget _iconDetailRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 14, color: Colors.grey.shade400),
      ],
    );
  }

  /// Extracted Popup Menu for Cleanliness
  Widget _buildPopupMenu(AssetModel asset) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_horiz, color: Colors.grey), // Horizontal dots look cleaner
      onSelected: (value) { /* Your logic */ },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text("Edit")])),
        const PopupMenuItem(value: 'Delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
      ],
    );
  }



}
