import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/components/common/custom_drop_down.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _status = "Active";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDense,
      appBar: const CustomAppBar2(
        title: "Create Employee Account",
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 18,),
                  /// 🔹 Mandatory Fields
                  CustomTextField(
                    hintText: "Full Name",
                    controller: _nameController,
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: "Email (mandatory)",
                    controller: _emailController,
                    verticalPadding: 15,
                    // keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: "Phone Number",
                    controller: _phoneController,
                    verticalPadding: 15,
                    // keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: "Address",
                    controller: _addressController,
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: "Role / Designation",
                    controller: _roleController,
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: "Salary",
                    controller: _salaryController,
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),
                      
                  /// 🔹 Status Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomSearchDropdown(
                      height: 50,
                      horizontalPadding: 12,
                      verticalPadding: 15,
                      iconSize: 25,
                      hintText: "Select Status",
                      items: const ["Active", "Inactive"],
                      onChanged: (value) {
                        setState(() {
                          _status = value ?? "Active";
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                      
                  /// 🔹 Optional Notes
                  CustomTextField(
                    hintText: "Notes (optional)",
                    controller: _notesController,
                    verticalPadding: 15,
                    maxLine: 3,
                  ),
                  const SizedBox(height: 25),
                      
                  /// 🔹 Create Employee Button
                  CustomButton(
                    text: "Create Employee",
                    onPressed: () {
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty) {
                        Get.snackbar("Error", "Name and Email are mandatory",
                            backgroundColor: Colors.red.shade200,
                            colorText: Colors.black);
                        return;
                      }
                      
                      /// TODO: Call API / Save employee data locally
                      Map<String, dynamic> newEmployee = {
                        "name": _nameController.text,
                        "email": _emailController.text,
                        "phone": _phoneController.text,
                        "address": _addressController.text,
                        "role": _roleController.text,
                        "salary": _salaryController.text,
                        "status": _status,
                        "notes": _notesController.text,
                      };
                      
                      print("New Employee Data: $newEmployee");
                      Get.back(); // Close screen after creation
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
