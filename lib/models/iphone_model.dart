class IPhoneModel {
  final int id;
  final String name;
  final double pricePerDay;
  final String specs;
  final List<String> images;
  final int stock;
  final String status;

  IPhoneModel({
    required this.id,
    required this.name,
    required this.pricePerDay,
    required this.specs,
    required this.images,
    required this.stock,
    required this.status,
  });

  factory IPhoneModel.fromJson(Map<String, dynamic> json) {
    // Parse images - bisa string tunggal atau array
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        imagesList = [json['images'] as String];
      }
    }

    return IPhoneModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      pricePerDay:
          double.tryParse(json['price_per_day']?.toString() ?? '0') ?? 0.0,
      specs: json['specs'] ?? '',
      images: imagesList,
      stock: json['stock'] ?? 0,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_per_day': pricePerDay,
      'specs': specs,
      'images': images,
      'stock': stock,
      'status': status,
    };
  }

  IPhoneModel copyWith({
    int? id,
    String? name,
    double? pricePerDay,
    String? specs,
    List<String>? images,
    int? stock,
    String? status,
  }) {
    return IPhoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      specs: specs ?? this.specs,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      status: status ?? this.status,
    );
  }

  bool get isAvailable => stock > 0 && status == 'active';
}
