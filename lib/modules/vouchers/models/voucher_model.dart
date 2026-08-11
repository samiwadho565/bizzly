class VoucherUser {
  final int id;
  final String name;
  final String email;

  VoucherUser({required this.id, required this.name, required this.email});

  factory VoucherUser.fromJson(Map<String, dynamic> j) => VoucherUser(
        id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
        name: j['name']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
      );
}

class VoucherBusiness {
  final int id;
  final String businessName;
  final String currency;

  VoucherBusiness({required this.id, required this.businessName, required this.currency});

  factory VoucherBusiness.fromJson(Map<String, dynamic> j) => VoucherBusiness(
        id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
        businessName: j['business_name']?.toString() ?? '',
        currency: j['currency']?.toString() ?? 'PKR',
      );
}

class VoucherCustomer {
  final int id;
  final String customerName;
  final String? companyName;

  VoucherCustomer({required this.id, required this.customerName, this.companyName});

  factory VoucherCustomer.fromJson(Map<String, dynamic> j) => VoucherCustomer(
        id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
        customerName: j['customer_name']?.toString() ?? '',
        companyName: j['company_name']?.toString(),
      );
}

class VoucherVendor {
  final int id;
  final String vendorName;
  final String? companyName;

  VoucherVendor({required this.id, required this.vendorName, this.companyName});

  factory VoucherVendor.fromJson(Map<String, dynamic> j) => VoucherVendor(
        id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
        vendorName: j['vendor_name']?.toString() ?? '',
        companyName: j['company_name']?.toString(),
      );
}

class VoucherLineAccount {
  final int id;
  final String accountCode;
  final String accountName;
  final String nature;

  VoucherLineAccount({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.nature,
  });

  factory VoucherLineAccount.fromJson(Map<String, dynamic> j) => VoucherLineAccount(
        id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
        accountCode: j['account_code']?.toString() ?? '',
        accountName: j['account_name']?.toString() ?? '',
        nature: j['nature']?.toString() ?? '',
      );
}

class VoucherLine {
  final int id;
  final int chartOfAccountId;
  final String lineType; // debit | credit
  final double amount;
  final String? narration;
  final int sortOrder;
  final VoucherLineAccount? account;

  VoucherLine({
    required this.id,
    required this.chartOfAccountId,
    required this.lineType,
    required this.amount,
    this.narration,
    required this.sortOrder,
    this.account,
  });

  factory VoucherLine.fromJson(Map<String, dynamic> j) => VoucherLine(
        id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
        chartOfAccountId: j['chart_of_account_id'] is int
            ? j['chart_of_account_id']
            : int.tryParse(j['chart_of_account_id'].toString()) ?? 0,
        lineType: j['line_type']?.toString() ?? 'debit',
        amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
        narration: j['narration']?.toString(),
        sortOrder: j['sort_order'] is int ? j['sort_order'] : int.tryParse(j['sort_order'].toString()) ?? 0,
        account: j['account'] is Map
            ? VoucherLineAccount.fromJson(Map<String, dynamic>.from(j['account'] as Map))
            : null,
      );

  bool get isDebit => lineType == 'debit';
}

class VoucherModel {
  final int id;
  final String voucherType;   // receipt | payment | journal | contra | adjustment
  final String voucherNumber;
  final DateTime voucherDate;
  final String narration;
  final String? referenceNumber;
  final String status;        // draft | submitted | posted | rejected
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;
  final bool isEditable;
  final int? businessId;
  final int? customerId;
  final int? vendorId;
  final int? accountingPeriodId;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? postedAt;
  final DateTime createdAt;

  final VoucherUser? owner;
  final VoucherUser? creator;
  final VoucherUser? approver;
  final VoucherUser? rejector;
  final VoucherBusiness? business;
  final VoucherCustomer? customer;
  final VoucherVendor? vendor;
  final List<VoucherLine> lines;

  VoucherModel({
    required this.id,
    required this.voucherType,
    required this.voucherNumber,
    required this.voucherDate,
    required this.narration,
    this.referenceNumber,
    required this.status,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
    required this.isEditable,
    this.businessId,
    this.customerId,
    this.vendorId,
    this.accountingPeriodId,
    this.rejectionReason,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.postedAt,
    required this.createdAt,
    this.owner,
    this.creator,
    this.approver,
    this.rejector,
    this.business,
    this.customer,
    this.vendor,
    this.lines = const [],
  });

  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';
  bool get isPosted => status == 'posted';
  bool get isRejected => status == 'rejected';

  factory VoucherModel.fromJson(Map<String, dynamic> j) {
    _toInt(dynamic v) => v is int ? v : (v != null ? int.tryParse(v.toString()) : null);
    _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
    _toDate(dynamic v) => v != null ? DateTime.tryParse(v.toString()) : null;

    return VoucherModel(
      id: _toInt(j['id']) ?? 0,
      voucherType: j['voucher_type']?.toString() ?? '',
      voucherNumber: j['voucher_number']?.toString() ?? '',
      voucherDate: DateTime.tryParse(j['voucher_date']?.toString() ?? '') ?? DateTime.now(),
      narration: j['narration']?.toString() ?? '',
      referenceNumber: j['reference_number']?.toString(),
      status: j['status']?.toString() ?? 'draft',
      totalDebit: _toDouble(j['total_debit']),
      totalCredit: _toDouble(j['total_credit']),
      isBalanced: j['is_balanced'] == true,
      isEditable: j['is_editable'] == true,
      businessId: _toInt(j['business_id']),
      customerId: _toInt(j['customer_id']),
      vendorId: _toInt(j['vendor_id']),
      accountingPeriodId: _toInt(j['accounting_period_id']),
      rejectionReason: j['rejection_reason']?.toString(),
      submittedAt: _toDate(j['submitted_at']),
      approvedAt: _toDate(j['approved_at']),
      rejectedAt: _toDate(j['rejected_at']),
      postedAt: _toDate(j['posted_at']),
      createdAt: _toDate(j['created_at']) ?? DateTime.now(),
      owner: j['owner'] is Map
          ? VoucherUser.fromJson(Map<String, dynamic>.from(j['owner'] as Map))
          : null,
      creator: j['creator'] is Map
          ? VoucherUser.fromJson(Map<String, dynamic>.from(j['creator'] as Map))
          : null,
      approver: j['approver'] is Map
          ? VoucherUser.fromJson(Map<String, dynamic>.from(j['approver'] as Map))
          : null,
      rejector: j['rejector'] is Map
          ? VoucherUser.fromJson(Map<String, dynamic>.from(j['rejector'] as Map))
          : null,
      business: j['business'] is Map
          ? VoucherBusiness.fromJson(Map<String, dynamic>.from(j['business'] as Map))
          : null,
      customer: j['customer'] is Map
          ? VoucherCustomer.fromJson(Map<String, dynamic>.from(j['customer'] as Map))
          : null,
      vendor: j['vendor'] is Map
          ? VoucherVendor.fromJson(Map<String, dynamic>.from(j['vendor'] as Map))
          : null,
      lines: j['lines'] is List
          ? (j['lines'] as List)
              .whereType<Map>()
              .map((e) => VoucherLine.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }
}

// ── Draft line model (used in create form) ───────────────────────
int _uidCounter = 0;

class DraftLine {
  final int uid;
  int? accountId;
  String? accountCode;
  String? accountName;
  String lineType; // debit | credit
  String amount;

  DraftLine({
    int? uid,                 // pass existing uid to preserve widget key
    this.accountId,
    this.accountCode,
    this.accountName,
    this.lineType = 'debit',
    this.amount = '',
  }) : uid = uid ?? ++_uidCounter;

  bool get isDebit => lineType == 'debit';
  double get parsedAmount => double.tryParse(amount) ?? 0.0;
  bool get isValid => accountId != null && parsedAmount > 0;
}
