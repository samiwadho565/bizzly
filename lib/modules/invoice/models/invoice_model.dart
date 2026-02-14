import 'package:bizly/modules/invoice/models/invoice_item_model.dart';

class InvoiceModel {
  InvoiceModel({
    this.id,
    this.userId,
    this.customerId,
    this.customerName,
    this.businessId,
    this.businessName,
    this.paymentMethodId,
    this.paymentMethodName,
    this.invoiceNumber,
    this.invoiceDate,
    this.status,
    this.notes,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.paymentStatus,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final int? customerId;
  final String? customerName;
  final int? businessId;
  final String? businessName;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? status;
  final String? notes;
  final dynamic totalAmount;
  final dynamic paidAmount;
  final dynamic remainingAmount;
  final String? paymentStatus;
  final List<InvoiceItemModel> items;
  final String? createdAt;
  final String? updatedAt;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? customer =
        json['customer'] is Map ? Map<String, dynamic>.from(json['customer']) : null;
    final Map<String, dynamic>? business =
        json['business'] is Map ? Map<String, dynamic>.from(json['business']) : null;
    final Map<String, dynamic>? payment =
        json['payment_method'] is Map ? Map<String, dynamic>.from(json['payment_method']) : null;

    final List<InvoiceItemModel> items = (json['items'] is List)
        ? (json['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(InvoiceItemModel.fromJson)
            .toList()
        : <InvoiceItemModel>[];

    return InvoiceModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      customerId: _toInt(customer?['id'] ?? json['customer_id']),
      customerName: customer?['customer_name']?.toString(),
      businessId: _toInt(business?['id'] ?? json['business_id']),
      businessName: business?['business_name']?.toString(),
      paymentMethodId: _toInt(payment?['id'] ?? json['payment_method_id']),
      paymentMethodName: payment?['name']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      invoiceDate: json['invoice_date']?.toString(),
      status: json['status']?.toString(),
      notes: json['notes']?.toString(),
      totalAmount: json['total_amount'],
      paidAmount: json['paid_amount'],
      remainingAmount: json['remaining_amount'],
      paymentStatus: json['payment_status']?.toString(),
      items: items,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'business_id': businessId,
      'payment_method_id': paymentMethodId,
      'notes': notes?.trim().isNotEmpty == true ? notes : null,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
