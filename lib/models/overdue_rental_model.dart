class OverdueRental {
  final int rentalId;
  final String iphoneName;
  final String orderCode;
  final int daysOverdue;
  final int dailyPenalty;
  final int penaltyAmount;

  OverdueRental({
    required this.rentalId,
    required this.iphoneName,
    required this.orderCode,
    required this.daysOverdue,
    required this.dailyPenalty,
    required this.penaltyAmount,
  });

  factory OverdueRental.fromJson(Map<String, dynamic> json) {
    return OverdueRental(
      rentalId: json['rental_id'] is int
          ? json['rental_id']
          : int.tryParse(json['rental_id']?.toString() ?? '0') ?? 0,
      iphoneName: json['iphone_name'] ?? '',
      orderCode: json['order_code'] ?? '',
      daysOverdue: json['days_overdue'] is int
          ? json['days_overdue']
          : int.tryParse(json['days_overdue']?.toString() ?? '0') ?? 0,
      dailyPenalty: json['daily_penalty'] is int
          ? json['daily_penalty']
          : int.tryParse(json['daily_penalty']?.toString() ?? '0') ?? 0,
      penaltyAmount: json['penalty_amount'] is int
          ? json['penalty_amount']
          : int.tryParse(json['penalty_amount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_id': rentalId,
      'iphone_name': iphoneName,
      'order_code': orderCode,
      'days_overdue': daysOverdue,
      'daily_penalty': dailyPenalty,
      'penalty_amount': penaltyAmount,
    };
  }
}

class PenaltyInfo {
  final bool hasPenalty;
  final String? warning;
  final int totalDaysOverdue;
  final int totalPenalty;
  final List<OverdueRental> overdueRentals;

  PenaltyInfo({
    required this.hasPenalty,
    this.warning,
    required this.totalDaysOverdue,
    required this.totalPenalty,
    required this.overdueRentals,
  });

  factory PenaltyInfo.fromJson(Map<String, dynamic> json) {
    return PenaltyInfo(
      hasPenalty: json['has_penalty'] ?? false,
      warning: json['warning'],
      totalDaysOverdue: json['total_days_overdue'] ?? 0,
      totalPenalty: json['total_penalty'] ?? 0,
      overdueRentals:
          (json['overdue_rentals'] as List<dynamic>?)
              ?.map((e) => OverdueRental.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_penalty': hasPenalty,
      'warning': warning,
      'total_days_overdue': totalDaysOverdue,
      'total_penalty': totalPenalty,
      'overdue_rentals': overdueRentals.map((e) => e.toJson()).toList(),
    };
  }
}
