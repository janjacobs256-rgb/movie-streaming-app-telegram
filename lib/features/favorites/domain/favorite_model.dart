class FavoriteModel {
  final String id;
  final String userId;
  final String movieId;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      movieId: json['movie_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
