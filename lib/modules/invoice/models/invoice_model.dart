import 'package:bizly/modules/invoice/models/invoice_item_model.dart';
import 'package:bizly/modules/invoice/models/invoice_payment_model.dart';

class InvoiceModel {
  InvoiceModel({
    this.id,
    this.userId,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.businessId,
    this.businessName,
    this.paymentMethodId,
    this.paymentMethodName,
    this.invoiceNumber,
    this.invoiceDate,
    this.status,
    this.notes,
    this.taxEnabled,
    this.subtotalAmount,
    this.taxAmount,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.paymentStatus,
    this.items = const [],
    this.payments = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final int? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final int? businessId;
  final String? businessName;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? status;
  final String? notes;
  final bool? taxEnabled;
  final dynamic subtotalAmount;
  final dynamic taxAmount;
  final dynamic totalAmount;
  final dynamic paidAmount;
  final dynamic remainingAmount;
  final String? paymentStatus;
  final List<InvoiceItemModel> items;
  final List<InvoicePaymentModel> payments;
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
    final List<InvoicePaymentModel> payments = (payload['payments'] is List)
        ? (payload['payments'] as List)
            .whereType<Map<String, dynamic>>()
            .map(InvoicePaymentModel.fromJson)
            .toList()
        : <InvoicePaymentModel>[];
    return InvoiceModel(
      id: _toInt(payload['id']),
      userId: _toInt(payload['user_id']),
      customerId: _toInt(customer?['id'] ?? payload['customer_id']),
      customerName: _firstNonEmpty(
        <dynamic>[
          customer?['customer_name'],
          customer?['name'],
          payload['customer_name'],
          payload['client_name'],
        ],
      ),
      customerEmail: _firstNonEmpty(
        <dynamic>[
          customer?['email'],
          payload['customer_email'],
          payload['client_email'],
          payload['email'],
        ],
      ),
      customerPhone: _firstNonEmpty(
        <dynamic>[
          customer?['phone_number'],
          customer?['phone'],
          payload['customer_phone'],
          payload['client_phone'],
          payload['phone_number'],
        ],
      ),
      businessId: _toInt(business?['id'] ?? payload['business_id']),
      businessName: business?['business_name']?.toString(),
      paymentMethodId: _toInt(payment?['id'] ?? payload['payment_method_id']),
      paymentMethodName: payment?['name']?.toString(),
      invoiceNumber: payload['invoice_number']?.toString(),
      invoiceDate: payload['invoice_date']?.toString(),
      status: payload['status']?.toString(),
      notes: payload['notes']?.toString(),
      taxEnabled: _toBool(payload['tax_enabled']),
      subtotalAmount: payload['subtotal_amount'],
      taxAmount: payload['tax_amount'],
      totalAmount: payload['total_amount'],
      paidAmount: payload['paid_amount'],
      remainingAmount: payload['remaining_amount'],
      paymentStatus: payload['payment_status']?.toString(),
      items: items,
      payments: payments,
      createdAt: payload['created_at']?.toString(),
      updatedAt: payload['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId?.toString(),
      if (invoiceNumber?.trim().isNotEmpty == true) 'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'status': status,
      'tax_enabled': taxEnabled ?? false,
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

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final dynamic value in values) {
      final String normalized = value?.toString().trim() ?? '';
      if (normalized.isNotEmpty) return normalized;
    }
    return null;
  }
}
