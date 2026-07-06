import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/supabase_config.dart';
import '../../favorites/presentation/favorites_provider.dart';
import '../domain/movie_model.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveThumbnailUrl = movie.thumbnailUrl.isNotEmpty
        ? movie.thumbnailUrl
        : '${SupabaseConfig.backendUrl}/thumbnail/${movie.id}';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C2F48), width: 1),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B1E30), Color(0xFF121420)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: effectiveThumbnailUrl.isNotEmpty
                    ? Image.network(
                        effectiveThumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                movie.category,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                movie.formattedDuration,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('No Poster', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class MovieDetailBottomSheet extends ConsumerWidget {
  final MovieModel movie;

  const MovieDetailBottomSheet({super.key, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(isFavoriteProvider(movie.id));

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF121420),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2F48), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  movie.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26),
                ),
              ),
              isFavoriteAsync.when(
                data: (isFav) => IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: isFav ? const Color(0xFFE50914) : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () async {
                    try {
                      if (isFav) {
                        await ref.read(favoriteRepositoryProvider).removeFavorite(movie.id);
                      } else {
                        await ref.read(favoriteRepositoryProvider).addFavorite(movie.id);
                      }
                      ref.invalidate(isFavoriteProvider(movie.id));
                      ref.invalidate(favoriteMoviesProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
                loading: () => const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (err, stack) => const SizedBox(width: 48, height: 48),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE50914).withOpacity(0.5)),
                ),
                child: Text(
                  movie.category,
                  style: const TextStyle(
                    color: Color(0xFFFF2E3B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(movie.formattedDuration, style: TextStyle(color: Colors.grey[400])),
              const SizedBox(width: 12),
              Icon(Icons.save_rounded, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(movie.formattedSize, style: TextStyle(color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 20),
          if (movie.description.isNotEmpty) ...[
            Text(
              movie.description,
              style: TextStyle(color: Colors.grey[300], fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 24),
          ],
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go('/player', extra: movie);
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text('Stream Now'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
