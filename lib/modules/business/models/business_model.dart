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
    this.invoiceLogo,
    this.businessCoverImageUrl,
    this.businessImageUrl,
    this.invoiceLogoUrl,
    this.invoiceTaxPercentage,
    this.invoiceShowEmail,
    this.invoiceShowPhone,
    this.invoiceCurrencyDecimalPosition,
    this.invoiceDueDateDays,
    this.invoiceLateFee,
    this.invoiceOrderNotes,
    this.invoiceAdditionalNotes,
    this.invoiceThankYouMessage,
    this.invoiceShowThankYouMessage,
    this.invoicePrefix,
    this.invoiceNumberingStartingFrom,
    this.invoiceTermsText,
    this.invoiceBusinessName,
    this.invoiceBusinessAddress,
    this.invoiceBusinessPhone,
    this.invoiceBusinessEmail,
    this.invoiceTaxNtn,
    this.invoiceTaxName,
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
  final File? invoiceLogo;
  final String? businessImageUrl;
  final String? businessCoverImageUrl;
  final String? invoiceLogoUrl;
  final num? invoiceTaxPercentage;
  final bool? invoiceShowEmail;
  final bool? invoiceShowPhone;
  final int? invoiceCurrencyDecimalPosition;
  final int? invoiceDueDateDays;
  final num? invoiceLateFee;
  final String? invoiceOrderNotes;
  final String? invoiceAdditionalNotes;
  final String? invoiceThankYouMessage;
  final bool? invoiceShowThankYouMessage;
  final String? invoicePrefix;
  final int? invoiceNumberingStartingFrom;
  final String? invoiceTermsText;
  final String? invoiceBusinessName;
  final String? invoiceBusinessAddress;
  final String? invoiceBusinessPhone;
  final String? invoiceBusinessEmail;
  final String? invoiceTaxNtn;
  final String? invoiceTaxName;
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
      if (invoiceTaxPercentage != null)
        'invoice_tax_percentage': invoiceTaxPercentage,
      if (invoiceShowEmail != null) 'invoice_show_email': invoiceShowEmail,
      if (invoiceShowPhone != null) 'invoice_show_phone': invoiceShowPhone,
      if (invoiceCurrencyDecimalPosition != null)
        'invoice_currency_decimal_position': invoiceCurrencyDecimalPosition,
      if (invoiceDueDateDays != null)
        'invoice_due_date_days': invoiceDueDateDays,
      if (invoiceLateFee != null) 'invoice_late_fee': invoiceLateFee,
      if (invoiceOrderNotes != null) 'invoice_order_notes': invoiceOrderNotes,
      if (invoiceAdditionalNotes != null)
        'invoice_additional_notes': invoiceAdditionalNotes,
      if (invoiceThankYouMessage != null)
        'invoice_thank_you_message': invoiceThankYouMessage,
      if (invoiceShowThankYouMessage != null)
        'invoice_show_thank_you_message': invoiceShowThankYouMessage,
      if (invoicePrefix != null) 'invoice_prefix': invoicePrefix,
      if (invoiceNumberingStartingFrom != null)
        'invoice_numbering_starting_from': invoiceNumberingStartingFrom,
      if (invoiceTermsText != null) 'invoice_terms_text': invoiceTermsText,
      if (invoiceBusinessName != null)
        'invoice_business_name': invoiceBusinessName,
      if (invoiceBusinessAddress != null)
        'invoice_business_address': invoiceBusinessAddress,
      if (invoiceBusinessPhone != null)
        'invoice_business_phone': invoiceBusinessPhone,
      if (invoiceBusinessEmail != null)
        'invoice_business_email': invoiceBusinessEmail,
      if (invoiceTaxNtn != null) 'invoice_tax_ntn': invoiceTaxNtn,
      if (invoiceTaxName != null) 'invoice_tax_name': invoiceTaxName,
      if (businessImage != null) 'business_image': businessImage,
      if (businessCoverImage != null) 'business_cover_image': businessCoverImage,
      if (invoiceLogo != null) 'invoice_logo': invoiceLogo,
    };
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return BusinessModel(
      id: _toInt(payload['id']),
      userId: _toInt(payload['user_id']),
      businessName: payload['business_name']?.toString() ?? '',
      businessAddress: payload['business_address']?.toString() ?? '',
      phoneNumber: payload['phone_number']?.toString() ?? '',
      currency: payload['currency']?.toString() ?? '',
      businessEmail: payload['business_email']?.toString(),
      taxNtnNumber: payload['tax_ntn_number']?.toString(),
      website: payload['website']?.toString(),
      socialMediaLink: payload['social_media_link']?.toString(),
      businessDescription: payload['business_description']?.toString(),
      operatingHours: payload['operating_hours']?.toString(),
      secondaryContact: payload['secondary_contact']?.toString(),
      businessImage: null,
      businessCoverImage: null,
      invoiceLogo: null,
      businessImageUrl: payload['business_image']?.toString(),
      businessCoverImageUrl: payload['business_cover_image']?.toString(),
      invoiceLogoUrl: payload['invoice_logo']?.toString(),
      invoiceTaxPercentage: _toNum(payload['invoice_tax_percentage']),
      invoiceShowEmail: _toBool(payload['invoice_show_email']),
      invoiceShowPhone: _toBool(payload['invoice_show_phone']),
      invoiceCurrencyDecimalPosition:
          _toInt(payload['invoice_currency_decimal_position']),
      invoiceDueDateDays: _toInt(payload['invoice_due_date_days']),
      invoiceLateFee: _toNum(payload['invoice_late_fee']),
      invoiceOrderNotes: payload['invoice_order_notes']?.toString(),
      invoiceAdditionalNotes: payload['invoice_additional_notes']?.toString(),
      invoiceThankYouMessage: payload['invoice_thank_you_message']?.toString(),
      invoiceShowThankYouMessage:
          _toBool(payload['invoice_show_thank_you_message']),
      invoicePrefix: payload['invoice_prefix']?.toString(),
      invoiceNumberingStartingFrom:
          _toInt(payload['invoice_numbering_starting_from']),
      invoiceTermsText: payload['invoice_terms_text']?.toString(),
      invoiceBusinessName: payload['invoice_business_name']?.toString(),
      invoiceBusinessAddress: payload['invoice_business_address']?.toString(),
      invoiceBusinessPhone: payload['invoice_business_phone']?.toString(),
      invoiceBusinessEmail: payload['invoice_business_email']?.toString(),
      invoiceTaxNtn: payload['invoice_tax_ntn']?.toString(),
      invoiceTaxName: payload['invoice_tax_name']?.toString(),
      createdAt: payload['created_at']?.toString(),
      updatedAt: payload['updated_at']?.toString(),
    );
  }

  BusinessModel copyWith({
    int? id,
    int? userId,
    String? businessName,
    String? businessAddress,
    String? phoneNumber,
    String? currency,
    String? businessEmail,
    String? taxNtnNumber,
    String? website,
    String? socialMediaLink,
    String? businessDescription,
    String? operatingHours,
    String? secondaryContact,
    File? businessImage,
    File? businessCoverImage,
    File? invoiceLogo,
    String? businessImageUrl,
    String? businessCoverImageUrl,
    String? invoiceLogoUrl,
    num? invoiceTaxPercentage,
    bool? invoiceShowEmail,
    bool? invoiceShowPhone,
    int? invoiceCurrencyDecimalPosition,
    int? invoiceDueDateDays,
    num? invoiceLateFee,
    String? invoiceOrderNotes,
    String? invoiceAdditionalNotes,
    String? invoiceThankYouMessage,
    bool? invoiceShowThankYouMessage,
    String? invoicePrefix,
    int? invoiceNumberingStartingFrom,
    String? invoiceTermsText,
    String? invoiceBusinessName,
    String? invoiceBusinessAddress,
    String? invoiceBusinessPhone,
    String? invoiceBusinessEmail,
    String? invoiceTaxNtn,
    String? invoiceTaxName,
    String? createdAt,
    String? updatedAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currency: currency ?? this.currency,
      businessEmail: businessEmail ?? this.businessEmail,
      taxNtnNumber: taxNtnNumber ?? this.taxNtnNumber,
      website: website ?? this.website,
      socialMediaLink: socialMediaLink ?? this.socialMediaLink,
      businessDescription: businessDescription ?? this.businessDescription,
      operatingHours: operatingHours ?? this.operatingHours,
      secondaryContact: secondaryContact ?? this.secondaryContact,
      businessImage: businessImage ?? this.businessImage,
      businessCoverImage: businessCoverImage ?? this.businessCoverImage,
      invoiceLogo: invoiceLogo ?? this.invoiceLogo,
      businessImageUrl: businessImageUrl ?? this.businessImageUrl,
      businessCoverImageUrl: businessCoverImageUrl ?? this.businessCoverImageUrl,
      invoiceLogoUrl: invoiceLogoUrl ?? this.invoiceLogoUrl,
      invoiceTaxPercentage: invoiceTaxPercentage ?? this.invoiceTaxPercentage,
      invoiceShowEmail: invoiceShowEmail ?? this.invoiceShowEmail,
      invoiceShowPhone: invoiceShowPhone ?? this.invoiceShowPhone,
      invoiceCurrencyDecimalPosition:
          invoiceCurrencyDecimalPosition ?? this.invoiceCurrencyDecimalPosition,
      invoiceDueDateDays: invoiceDueDateDays ?? this.invoiceDueDateDays,
      invoiceLateFee: invoiceLateFee ?? this.invoiceLateFee,
      invoiceOrderNotes: invoiceOrderNotes ?? this.invoiceOrderNotes,
      invoiceAdditionalNotes:
          invoiceAdditionalNotes ?? this.invoiceAdditionalNotes,
      invoiceThankYouMessage:
          invoiceThankYouMessage ?? this.invoiceThankYouMessage,
      invoiceShowThankYouMessage:
          invoiceShowThankYouMessage ?? this.invoiceShowThankYouMessage,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      invoiceNumberingStartingFrom:
          invoiceNumberingStartingFrom ?? this.invoiceNumberingStartingFrom,
      invoiceTermsText: invoiceTermsText ?? this.invoiceTermsText,
      invoiceBusinessName: invoiceBusinessName ?? this.invoiceBusinessName,
      invoiceBusinessAddress:
          invoiceBusinessAddress ?? this.invoiceBusinessAddress,
      invoiceBusinessPhone: invoiceBusinessPhone ?? this.invoiceBusinessPhone,
      invoiceBusinessEmail: invoiceBusinessEmail ?? this.invoiceBusinessEmail,
      invoiceTaxNtn: invoiceTaxNtn ?? this.invoiceTaxNtn,
      invoiceTaxName: invoiceTaxName ?? this.invoiceTaxName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String v = value.toLowerCase().trim();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return null;
  }
}
