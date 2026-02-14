import 'dart:io';

class ExpenseModel {
  ExpenseModel({
    this.id,
    this.userId,
    this.businessId,
    this.categoryId,
    this.paymentMethodId,
    this.customerId,
    this.vendorId,
    this.title,
    this.amount,
    this.expenseDate,
    this.referenceNumber,
    this.taxAmount,
    this.projectName,
    this.notes,
    this.receiptUrl,
    this.receiptFile,
    this.receiptCleared,
    this.isRecurringMonthly,
    this.expenseType,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.paymentMethodName,
    this.customerName,
    this.vendorName,
    this.businessName,
  });

  final int? id;
  final int? userId;
  final int? businessId;
  final int? categoryId;
  final int? paymentMethodId;
  final int? customerId;
  final int? vendorId;
  final String? title;
  final dynamic amount;
  final String? expenseDate;
  final String? referenceNumber;
  final dynamic taxAmount;
  final String? projectName;
  final String? notes;
   String? receiptUrl;
  final File? receiptFile;
  final bool? receiptCleared;
  final bool? isRecurringMonthly;
  final String? expenseType;
  final String? createdAt;
  final String? updatedAt;
  final String? categoryName;
  final String? paymentMethodName;
  final String? customerName;
  final String? vendorName;
  final String? businessName;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? category =
        json['category'] is Map ? Map<String, dynamic>.from(json['category']) : null;
    final Map<String, dynamic>? payment =
        json['payment_method'] is Map ? Map<String, dynamic>.from(json['payment_method']) : null;
    final Map<String, dynamic>? customer =
        json['customer'] is Map ? Map<String, dynamic>.from(json['customer']) : null;
    final Map<String, dynamic>? vendor =
        json['vendor'] is Map ? Map<String, dynamic>.from(json['vendor']) : null;
    final Map<String, dynamic>? business =
        json['business'] is Map ? Map<String, dynamic>.from(json['business']) : null;

    return ExpenseModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      businessId: _toInt(json['business_id']),
      categoryId: _toInt(category?['id'] ?? json['category_id']),
      paymentMethodId: _toInt(payment?['id'] ?? json['payment_method_id']),
      customerId: _toInt(customer?['id'] ?? json['customer_id']),
      vendorId: _toInt(vendor?['id'] ?? json['vendor_id']),
      title: json['title']?.toString(),
      amount: json['amount'],
      expenseDate: json['expense_date']?.toString(),
      referenceNumber: json['reference_number']?.toString(),
      taxAmount: json['tax_amount'],
      projectName: json['project_name']?.toString(),
      notes: json['notes']?.toString(),
      receiptUrl: json['receipt']?.toString(),
      isRecurringMonthly: json['is_recurring_monthly'] == true,
      expenseType: json['expense_type']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      categoryName: category?['name']?.toString(),
      paymentMethodName: payment?['name']?.toString(),
      customerName: customer?['customer_name']?.toString(),
      vendorName: vendor?['vendor_name']?.toString(),
      businessName: business?['business_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'expense_date': expenseDate,
      'payment_method_id': paymentMethodId,
      'expense_type': expenseType,
      'is_recurring_monthly': isRecurringMonthly,
      'reference_number': referenceNumber?.trim().isNotEmpty == true
          ? referenceNumber
          : null,
      'tax_amount': taxAmount?.toString().trim().isNotEmpty == true
          ? taxAmount
          : null,
      'project_name': projectName?.trim().isNotEmpty == true ? projectName : null,
      'customer_id': customerId,
      'vendor_id': vendorId,
      'notes': notes?.trim().isNotEmpty == true ? notes : null,
      'business_id': businessId,
      if (receiptFile != null) 'receipt': receiptFile,
      if (receiptFile == null && receiptCleared == true) 'receipt': null,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
