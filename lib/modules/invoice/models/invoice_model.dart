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

    final Map<String, dynamic> payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final Map<String, dynamic>? customer =
        payload['customer'] is Map ? Map<String, dynamic>.from(payload['customer']) : null;
    final Map<String, dynamic>? business =
        payload['business'] is Map ? Map<String, dynamic>.from(payload['business']) : null;
    final Map<String, dynamic>? payment =
        payload['payment_method'] is Map ? Map<String, dynamic>.from(payload['payment_method']) : null;

    final List<InvoiceItemModel> items = (payload['items'] is List)
        ? (payload['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(InvoiceItemModel.fromJson)
            .toList()
        : <InvoiceItemModel>[];
    print(" _toInt(payload['id']), :${ _toInt(payload['id'])}");
    return InvoiceModel(
      id: _toInt(payload['id']),
      userId: _toInt(payload['user_id']),
      customerId: _toInt(customer?['id'] ?? payload['customer_id']),
      customerName: customer?['customer_name']?.toString(),
      businessId: _toInt(business?['id'] ?? payload['business_id']),
      businessName: business?['business_name']?.toString(),
      paymentMethodId: _toInt(payment?['id'] ?? payload['payment_method_id']),
      paymentMethodName: payment?['name']?.toString(),
      invoiceNumber: payload['invoice_number']?.toString(),
      invoiceDate: payload['invoice_date']?.toString(),
      status: payload['status']?.toString(),
      notes: payload['notes']?.toString(),
      totalAmount: payload['total_amount'],
      paidAmount: payload['paid_amount'],
      remainingAmount: payload['remaining_amount'],
      paymentStatus: payload['payment_status']?.toString(),
      items: items,
      createdAt: payload['created_at']?.toString(),
      updatedAt: payload['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId?.toString(),
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'business_id': businessId?.toString(),
      'payment_method_id': paymentMethodId?.toString(),
      'notes': notes?.trim().isNotEmpty == true ? notes : null,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
