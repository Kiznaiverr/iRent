import 'iphone_model.dart';
import 'user_model.dart';

class RentalModel {
  final int id;
  final int userId;
  final int iphoneId;
  final String startDate;
  final String endDate;
  final String? returnDate;
  final String status;
  final double penalty;
  final IPhoneModel? iphone;
  final UserModel? user;

  RentalModel({
    required this.id,
    required this.userId,
    required this.iphoneId,
    required this.startDate,
    required this.endDate,
    this.returnDate,
    required this.status,
    required this.penalty,
    this.iphone,
    this.user,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      iphoneId: json['iphone_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      returnDate: json['return_date'],
      status: json['status'] ?? 'active',
      penalty: (json['penalty'] ?? 0).toDouble(),
      iphone: json['iphone'] != null
          ? IPhoneModel.fromJson(json['iphone'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'iphone_id': iphoneId,
      'start_date': startDate,
      'end_date': endDate,
      'return_date': returnDate,
      'status': status,
      'penalty': penalty,
      'iphone': iphone?.toJson(),
      'user': user?.toJson(),
    };
  }

  RentalModel copyWith({
    int? id,
    int? userId,
    int? iphoneId,
    String? startDate,
    String? endDate,
    String? returnDate,
    String? status,
    double? penalty,
    IPhoneModel? iphone,
    UserModel? user,
  }) {
    return RentalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      iphoneId: iphoneId ?? this.iphoneId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      penalty: penalty ?? this.penalty,
      iphone: iphone ?? this.iphone,
      user: user ?? this.user,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'returned':
        return 'Dikembalikan';
      case 'overdue':
        return 'Terlambat';
      default:
        return status;
    }
  }

  bool get isOverdue => status == 'overdue';
  bool get isActive => status == 'active';
}
