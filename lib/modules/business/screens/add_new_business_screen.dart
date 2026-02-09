import 'dart:io';

import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/business/controllers/create_business_controller.dart';

class AddNewBusinessScreen extends GetView<CreateBusinessController> {
  AddNewBusinessScreen({super.key});

  // ✅ Common TextStyles
  final TextStyle requiredLabelStyle =
  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black);


  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: controller.isEdit ? "Update Business" : "Add New Business",
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ----------------- Image Previews -----------------
                      Obx(
                        () => _coverAndLogoPreview(
                          coverFile: controller.businessCoverImageFile.value,
                          logoFile: controller.businessImageFile.value,
                          coverUrl:
                              controller.editingBusiness.value?.businessCoverImageUrl,
                          logoUrl:
                              controller.editingBusiness.value?.businessImageUrl,
                          onPickCover: controller.pickBusinessCoverImage,
                          onPickLogo: controller.pickBusinessImage,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ----------------- Required Fields -----------------
                      Text("Required Information", style: sectionTitleStyle),
                      const SizedBox(height: 15),

                      Text("Business Name", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "Fixonto",
                        verticalPadding: 13,
                        controller: controller.businessNameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Business Address", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "123 Street, City",
                        verticalPadding: 13,
                        controller: controller.businessAddressController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Phone Number", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "+92 300 1234567",
                        verticalPadding: 13,
                        controller: controller.phoneNumberController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Currency", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "PKR",
                        verticalPadding: 13,
                        controller: controller.currencyController,
                        textInputAction: TextInputAction.next,
                      ),

                    const SizedBox(height: 25),

                      // ----------------- Optional Fields -----------------
                      Text("Optional Information", style: sectionTitleStyle),
                      const SizedBox(height: 15),

                      Text("Email Address", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "example@mail.com",
                        verticalPadding: 13,
                        controller: controller.businessEmailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Tax / NTN Number", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "1234567",
                        verticalPadding: 13,
                        controller: controller.taxNtnController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Website", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "www.example.com",
                        verticalPadding: 13,
                        controller: controller.websiteController,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Social Media Link", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "https://facebook.com/example",
                        verticalPadding: 13,
                        controller: controller.socialMediaController,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Business Description", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "Short description about business",
                        verticalPadding: 13,
                        controller: controller.businessDescriptionController,
                        maxLine: 3,
                      ),
                      const SizedBox(height: 15),

                      Text("Operating Hours", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "9 AM - 6 PM",
                        verticalPadding: 13,
                        controller: controller.operatingHoursController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Secondary Contact", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "+92 300 7654321",
                        verticalPadding: 13,
                        controller: controller.secondaryContactController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),


                      const SizedBox(height: 30),

                      // Create Button
                      Obx(
                        () => CustomButton(
                          text: controller.isEdit
                              ? "Update Business"
                              : "Create Business",
                          isLoading: controller.isLoading.value,
                          onPressed: controller.createBusiness,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePickerTile({
    required String label,
    required VoidCallback onTap,
    String? filePath,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textField,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.image_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filePath ?? label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filePath == null ? Colors.grey.shade700 : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Select",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverAndLogoPreview({
    required File? coverFile,
    required File? logoFile,
    required String? coverUrl,
    required String? logoUrl,
    required VoidCallback onPickCover,
    required VoidCallback onPickLogo,
  }) {
    final bool hasCoverUrl = coverUrl != null && coverUrl.isNotEmpty;
    final bool hasLogoUrl = logoUrl != null && logoUrl.isNotEmpty;

    final ImageProvider<Object>? logoProvider = logoFile != null
        ? FileImage(logoFile)
        : (hasLogoUrl ? NetworkImage(logoUrl!) : null);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onPickCover,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.textField,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  image: coverFile != null
                      ? DecorationImage(
                          image: FileImage(coverFile),
                          fit: BoxFit.cover,
                        )
                      : (hasCoverUrl
                          ? DecorationImage(
                              image: NetworkImage(coverUrl!),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child: coverFile == null && !hasCoverUrl
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.photo_library_outlined,
                              color: AppColors.primary, size: 28),
                          SizedBox(height: 6),
                          Text(
                            "Select cover image (optional)",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            Positioned(
              left: 20,
              bottom: -35,
              child: GestureDetector(
                onTap: onPickLogo,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.textField,
                    backgroundImage: logoProvider,
                    child: logoProvider == null
                        ? const Icon(Icons.storefront_outlined,
                            color: AppColors.primary, size: 30)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Tap the circle to select business image (required)",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
