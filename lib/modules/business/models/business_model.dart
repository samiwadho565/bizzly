import 'dart:io';

class BusinessModel {
  BusinessModel({
    required this.businessName,
    required this.businessAddress,
    required this.phoneNumber,
    required this.currency,
    this.businessImage,
    this.id,
    this.userId,
    this.businessEmail,
    this.taxNtnNumber,
    this.website,
    this.socialMediaLink,
    this.businessDescription,
    this.operatingHours,
    this.secondaryContact,
    this.businessCoverImage,
    this.businessCoverImageUrl,
    this.businessImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String businessName;
  final String businessAddress;
  final String phoneNumber;
  final String currency;
  final String? businessEmail;
  final String? taxNtnNumber;
  final String? website;
  final String? socialMediaLink;
  final String? businessDescription;
  final String? operatingHours;
  final String? secondaryContact;
  final File? businessImage;
  final File? businessCoverImage;
  final String? businessImageUrl;
  final String? businessCoverImageUrl;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'business_address': businessAddress,
      'phone_number': phoneNumber,
      'currency': currency,
      'business_email': businessEmail,
      'tax_ntn_number': taxNtnNumber,
      'website': website,
      'social_media_link': socialMediaLink,
      'business_description': businessDescription,
      'operating_hours': operatingHours,
      'secondary_contact': secondaryContact,
      if (businessImage != null) 'business_image': businessImage,
      if (businessCoverImage != null) 'business_cover_image': businessCoverImage,
    };
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      businessName: json['business_name']?.toString() ?? '',
      businessAddress: json['business_address']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      businessEmail: json['business_email']?.toString(),
      taxNtnNumber: json['tax_ntn_number']?.toString(),
      website: json['website']?.toString(),
      socialMediaLink: json['social_media_link']?.toString(),
      businessDescription: json['business_description']?.toString(),
      operatingHours: json['operating_hours']?.toString(),
      secondaryContact: json['secondary_contact']?.toString(),
      businessImage: null,
      businessCoverImage: null,
      businessImageUrl: json['business_image']?.toString(),
      businessCoverImageUrl: json['business_cover_image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
