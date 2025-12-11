import 'iphone_model.dart';
import 'user_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final int iphoneId;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status;
  final String orderCode;
  final IPhoneModel? iphone;
  final UserModel? user;
  final String? userName;
  final String? userProfile;
  final String? iphoneName;
  final String? pricePerDay;

  OrderModel({
    required this.id,
    required this.userId,
    required this.iphoneId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.orderCode,
    this.iphone,
    this.user,
    this.userName,
    this.userProfile,
    this.iphoneName,
    this.pricePerDay,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      iphoneId: json['iphone_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pre_ordered',
      orderCode: json['order_code'] ?? '',
      iphone: json['iphone'] != null
          ? IPhoneModel.fromJson(json['iphone'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      userName: json['user_name']?.toString(),
      userProfile: json['profile']?.toString(),
      iphoneName: json['iphone_name']?.toString(),
      pricePerDay: json['price_per_day']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'iphone_id': iphoneId,
      'start_date': startDate,
      'end_date': endDate,
      'total_price': totalPrice,
      'status': status,
      'order_code': orderCode,
      'iphone': iphone?.toJson(),
      'user': user?.toJson(),
      'user_name': userName,
      'profile': userProfile,
      'iphone_name': iphoneName,
      'price_per_day': pricePerDay,
    };
  }

  OrderModel copyWith({
    int? id,
    int? userId,
    int? iphoneId,
    String? startDate,
    String? endDate,
    double? totalPrice,
    String? status,
    String? orderCode,
    IPhoneModel? iphone,
    UserModel? user,
    String? userName,
    String? userProfile,
    String? iphoneName,
    String? pricePerDay,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      iphoneId: iphoneId ?? this.iphoneId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderCode: orderCode ?? this.orderCode,
      iphone: iphone ?? this.iphone,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      userProfile: userProfile ?? this.userProfile,
      iphoneName: iphoneName ?? this.iphoneName,
      pricePerDay: pricePerDay ?? this.pricePerDay,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pre_ordered':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}
