class AccountingPeriodModel {
  AccountingPeriodModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.closedAt,
    this.businessId,
    this.priorPeriodId,
    this.closingVoucherId,
    this.openingVoucherId,
    this.carryForwards = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // open | closed
  final DateTime? closedAt;
  final int? businessId;
  final int? priorPeriodId;
  final int? closingVoucherId;
  final int? openingVoucherId;
  final List<dynamic> carryForwards;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOpen => status.toLowerCase() == 'open';

  /// null business_id = global/default period (applies across businesses)
  bool get isGlobal => businessId == null;

  factory AccountingPeriodModel.fromJson(Map<String, dynamic> json) {
    return AccountingPeriodModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? 'open',
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'].toString())
          : null,
      businessId: _toInt(json['business_id']),
      priorPeriodId: _toInt(json['prior_period_id']),
      closingVoucherId: _toInt(json['closing_voucher_id']),
      openingVoucherId: _toInt(json['opening_voucher_id']),
      carryForwards: json['carry_forwards'] is List ? json['carry_forwards'] as List : const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
