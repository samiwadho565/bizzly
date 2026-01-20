import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_dialouge.dart';
import '../../utils/app_utils.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Add Asset"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset Name
              CustomTextField(
                hintText: "Asset Name",
                controller: _nameController,
                verticalPadding: 15,
              ),
              const SizedBox(height: 12),

              // Asset Type
              CustomTextField(
                hintText: "Asset Type",
                controller: _typeController,
                verticalPadding: 15,
              ),
              const SizedBox(height: 12),

              // Assigned To
              CustomTextField(
                hintText: "Assigned To",
                controller: _assignedToController,
                verticalPadding: 15,
              ),
              const SizedBox(height: 12),

              // Value
              CustomTextField(
                hintText: "Value (PKR)",
                controller: _valueController,
                // keyboardType: TextInputType.number,
                verticalPadding: 15,
              ),
              const SizedBox(height: 12),

              // Purchase Date
              GestureDetector(
                onTap: () async {
                  final date = await AppUtils.pickDate();
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                      _purchaseDateController.text =
                      "${date.day}-${date.month}-${date.year}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: CustomTextField(
                    hintText: "Purchase Date",
                    controller: _purchaseDateController,
                    verticalPadding: 15,
                    // suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Add Asset Button
              CustomButton(
                text: "Add Asset",
                onPressed: () {

                  if (_nameController.text.isEmpty ||
                      _typeController.text.isEmpty ||
                      _assignedToController.text.isEmpty ||
                      _valueController.text.isEmpty ||
                      selectedDate == null) {
                    AppDialogs.showAlert(
                        title: "Incomplete Data",
                        message: "Please fill all fields before adding an asset.");
                    return;
                  }


                  AppDialogs.showAlert(
                      title: "Success", message: "Asset added successfully!");

                  // Clear fields
                  _nameController.clear();
                  _typeController.clear();
                  _assignedToController.clear();
                  _valueController.clear();
                  _purchaseDateController.clear();
                  setState(() {
                    selectedDate = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
