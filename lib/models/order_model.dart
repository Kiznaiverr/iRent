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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      iphoneId: json['iphone_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pre_ordered',
      orderCode: json['order_code'] ?? '',
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
      'total_price': totalPrice,
      'status': status,
      'order_code': orderCode,
      'iphone': iphone?.toJson(),
      'user': user?.toJson(),
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
