class MovieModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int telegramMessageId;
  final int telegramChannelId;
  final String fileId;
  final int fileSize;
  final int durationSeconds;
  final String thumbnailUrl;
  final DateTime createdAt;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.telegramMessageId,
    required this.telegramChannelId,
    required this.fileId,
    required this.fileSize,
    required this.durationSeconds,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      telegramMessageId: (json['telegram_message_id'] as num).toInt(),
      telegramChannelId: (json['telegram_channel_id'] as num).toInt(),
      fileId: json['file_id'] as String? ?? '',
      fileSize: (json['file_size'] as num).toInt(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'telegram_message_id': telegramMessageId,
      'telegram_channel_id': telegramChannelId,
      'file_id': fileId,
      'file_size': fileSize,
      'duration_seconds': durationSeconds,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    if (durationSeconds <= 0) return 'Unknown';
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  String get formattedSize {
    if (fileSize <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = fileSize.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
