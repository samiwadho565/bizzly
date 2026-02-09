class CustomerModel {
  CustomerModel({
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    this.email,
    this.secondaryPhoneNumber,
    this.companyName,
    this.taxNtn,
    this.website,
    this.socialLink,
    this.notes,
    this.profileImage,
    this.id,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String customerName;
  final String phoneNumber;
  final String address;
  final String? email;
  final String? secondaryPhoneNumber;
  final String? companyName;
  final String? taxNtn;
  final String? website;
  final String? socialLink;
  final String? notes;
  final String? profileImage;
  final String? createdAt;
  final String? updatedAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      customerName: json['customer_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString() ?? '',
      secondaryPhoneNumber: json['secondary_phone_number']?.toString(),
      companyName: json['company_name']?.toString(),
      taxNtn: json['tax_ntn']?.toString(),
      website: json['website']?.toString(),
      socialLink: json['social_link']?.toString(),
      notes: json['notes']?.toString(),
      profileImage: json['profile_image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'secondary_phone_number': secondaryPhoneNumber,
      'company_name': companyName,
      'tax_ntn': taxNtn,
      'website': website,
      'social_link': socialLink,
      'notes': notes,
      'profile_image': profileImage,
    };
  }
}
