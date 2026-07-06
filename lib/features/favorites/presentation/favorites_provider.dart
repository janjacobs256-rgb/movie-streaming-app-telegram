import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../movies/domain/movie_model.dart';
import '../data/favorite_repository.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

final favoriteMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.getFavoriteMovies();
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, movieId) async {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.isFavorite(movieId);
});
