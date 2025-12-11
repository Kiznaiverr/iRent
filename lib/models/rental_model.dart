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
  final String? userName;
  final String? userProfile;

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
    this.userName,
    this.userProfile,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    // Handle different field names from API
    final startDate = json['rental_start_date'] ?? json['start_date'] ?? '';
    final endDate = json['rental_end_date'] ?? json['end_date'] ?? '';
    final returnDate = json['actual_return_date'] ?? json['return_date'];

    // Create iPhone object from iphone_name if available
    IPhoneModel? iphone;
    if (json['iphone_name'] != null) {
      iphone = IPhoneModel(
        id: json['iphone_id'] ?? 0,
        name: json['iphone_name'],
        pricePerDay: 0, // Default value since not provided
        specs: '',
        images: [], // Empty list for images
        stock: 0,
        status: 'active',
      );
    } else if (json['iphone'] != null) {
      iphone = IPhoneModel.fromJson(json['iphone']);
    }

    return RentalModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      iphoneId: json['iphone_id'] ?? 0,
      startDate: startDate,
      endDate: endDate,
      returnDate: returnDate,
      status: json['status'] ?? 'active',
      penalty: double.tryParse(json['penalty']?.toString() ?? '0') ?? 0.0,
      iphone: iphone,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      userName: json['user_name']?.toString(),
      userProfile: json['profile']?.toString(),
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
      'user_name': userName,
      'profile': userProfile,
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
    String? userName,
    String? userProfile,
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
      userName: userName ?? this.userName,
      userProfile: userProfile ?? this.userProfile,
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
