class CustomerModel {
  // ------------------- Required Fields -------------------
  final String name;
  final String email;
  final String phone;
  final String address;

  // ------------------- Optional Fields -------------------
  final String? companyName;
  final String? taxNumber;
  final String? website;
  final String? socialLink;
  final String? notes;
  final String? secondaryPhone;
  final String? city;
  final String? country;

  CustomerModel({
    // Required
    required this.name,
    required this.email,
    required this.phone,
    required this.address,

    // Optional
    this.companyName,
    this.taxNumber,
    this.website,
    this.socialLink,
    this.notes,
    this.secondaryPhone,
    this.city,
    this.country,
  });
}
