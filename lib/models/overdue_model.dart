class OverdueModel {
  final int id;
  final int orderId;
  final int iphoneId;
  final int userId;
  final String rentalStartDate;
  final String rentalEndDate;
  final String? actualReturnDate;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String iphoneName;
  final String pricePerDay;
  final String userName;
  final String userPhone;
  final String userEmail;
  final String orderCode;
  final String orderTotal;
  final int daysOverdue;
  final int penaltyPerDay;
  final String totalPenalty;
  final String originalEndDate;
  final String currentDate;
  final String? userProfile;

  OverdueModel({
    required this.id,
    required this.orderId,
    required this.iphoneId,
    required this.userId,
    required this.rentalStartDate,
    required this.rentalEndDate,
    this.actualReturnDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.iphoneName,
    required this.pricePerDay,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.orderCode,
    required this.orderTotal,
    required this.daysOverdue,
    required this.penaltyPerDay,
    required this.totalPenalty,
    required this.originalEndDate,
    required this.currentDate,
    this.userProfile,
  });

  factory OverdueModel.fromJson(Map<String, dynamic> json) {
    return OverdueModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      iphoneId: json['iphone_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rentalStartDate: json['rental_start_date'] ?? '',
      rentalEndDate: json['rental_end_date'] ?? '',
      actualReturnDate: json['actual_return_date'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      iphoneName: json['iphone_name'] ?? '',
      pricePerDay: json['price_per_day'] ?? '',
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      userEmail: json['user_email'] ?? '',
      orderCode: json['order_code'] ?? '',
      orderTotal: json['order_total'] ?? '',
      daysOverdue: int.tryParse(json['days_overdue']?.toString() ?? '0') ?? 0,
      penaltyPerDay: json['penalty_per_day'] ?? 0,
      totalPenalty: json['total_penalty'] ?? '',
      originalEndDate: json['original_end_date'] ?? '',
      currentDate: json['current_date'] ?? '',
      userProfile: json['profile']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'iphone_id': iphoneId,
      'user_id': userId,
      'rental_start_date': rentalStartDate,
      'rental_end_date': rentalEndDate,
      'actual_return_date': actualReturnDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'iphone_name': iphoneName,
      'price_per_day': pricePerDay,
      'user_name': userName,
      'user_phone': userPhone,
      'user_email': userEmail,
      'order_code': orderCode,
      'order_total': orderTotal,
      'days_overdue': daysOverdue,
      'penalty_per_day': penaltyPerDay,
      'total_penalty': totalPenalty,
      'original_end_date': originalEndDate,
      'current_date': currentDate,
      'profile': userProfile,
    };
  }

  OverdueModel copyWith({
    int? id,
    int? orderId,
    int? iphoneId,
    int? userId,
    String? rentalStartDate,
    String? rentalEndDate,
    String? actualReturnDate,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? iphoneName,
    String? pricePerDay,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? orderCode,
    String? orderTotal,
    int? daysOverdue,
    int? penaltyPerDay,
    String? totalPenalty,
    String? originalEndDate,
    String? currentDate,
    String? userProfile,
  }) {
    return OverdueModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      iphoneId: iphoneId ?? this.iphoneId,
      userId: userId ?? this.userId,
      rentalStartDate: rentalStartDate ?? this.rentalStartDate,
      rentalEndDate: rentalEndDate ?? this.rentalEndDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iphoneName: iphoneName ?? this.iphoneName,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      orderCode: orderCode ?? this.orderCode,
      orderTotal: orderTotal ?? this.orderTotal,
      daysOverdue: daysOverdue ?? this.daysOverdue,
      penaltyPerDay: penaltyPerDay ?? this.penaltyPerDay,
      totalPenalty: totalPenalty ?? this.totalPenalty,
      originalEndDate: originalEndDate ?? this.originalEndDate,
      currentDate: currentDate ?? this.currentDate,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}
