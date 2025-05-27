// lib/models/comment_like.dart

class CommentLike {
  final int id;
  final int commentId;
  final int userId;

  CommentLike({
    required this.id,
    required this.commentId,
    required this.userId,
  });

  factory CommentLike.fromJson(Map<String, dynamic> json) {
    return CommentLike(
      id: json['id'],
      commentId: json['comment_id'],
      userId: json['user_id'],
    );
  }
}

