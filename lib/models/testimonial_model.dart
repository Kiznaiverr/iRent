class TestimonialModel {
  final int id;
  final int userId;
  final String content;
  final int rating;
  final String createdAt;
  final String userName;
  final String? profile;

  TestimonialModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.rating,
    required this.createdAt,
    required this.userName,
    this.profile,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    // Parse user_name dengan berbagai fallback
    String name = 'User';
    if (json['user_name'] != null && json['user_name'].toString().isNotEmpty) {
      name = json['user_name'].toString();
    } else if (json['user'] != null && json['user']['name'] != null) {
      name = json['user']['name'].toString();
    }

    return TestimonialModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      content: (json['content'] ?? json['message'] ?? '').toString(),
      rating: (json['rating'] ?? 5) is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 5,
      createdAt: (json['created_at'] ?? '').toString(),
      userName: name,
      profile: json['profile']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'rating': rating,
      'created_at': createdAt,
      'user_name': userName,
      'profile': profile,
    };
  }

  TestimonialModel copyWith({
    int? id,
    int? userId,
    String? content,
    int? rating,
    String? createdAt,
    String? userName,
    String? profile,
  }) {
    return TestimonialModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      profile: profile ?? this.profile,
    );
  }
}
