class AccountingPeriodModel {
  AccountingPeriodModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.closedAt,
  });

  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // open | closed
  final DateTime? closedAt;

  bool get isOpen => status.toLowerCase() == 'open';

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
    );
  }
}
