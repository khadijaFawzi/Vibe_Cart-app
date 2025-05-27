class Comment {
  final int id;
  final int productId;
  final String body;
  final int userId;
  final String userName;
  final DateTime? createdAt; // اجعلها nullable
  int likesCount; // متغير جديد

  Comment({
    required this.id,
    required this.productId,
    required this.body,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.likesCount = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      productId: json['product_id'],
      body: json['body'],
      userId: json['user_id'],
      userName: json['user_name'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      likesCount: json['likes_count'] ?? 0,
    );
  }
}
