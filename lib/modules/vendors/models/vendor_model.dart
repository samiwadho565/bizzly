class VendorModel {
  VendorModel({
    required this.vendorName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.companyName,
    this.taxNumber,
    this.notes,
    this.id,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String vendorName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? companyName;
  final String? taxNumber;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      vendorName: json['vendor_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      companyName: json['company_name']?.toString(),
      taxNumber: json['tax_number']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_name': vendorName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'company_name': companyName,
      'tax_number': taxNumber,
      'notes': notes,
    };
  }
}
