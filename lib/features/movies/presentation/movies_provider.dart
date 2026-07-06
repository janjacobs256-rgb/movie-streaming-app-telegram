import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/movie_repository.dart';
import '../domain/movie_model.dart';

// Provider for the Movie Repository
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository();
});

// StateProvider for searching
final searchQueryProvider = StateProvider<String>((ref) => '');

// StateProvider for category selection
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Provider for all categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getCategories();
});

// Provider for the filtered movie list
final moviesListProvider = FutureProvider<List<MovieModel>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isNotEmpty) {
    return repo.searchMovies(query);
  } else if (category != 'All') {
    return repo.getMoviesByCategory(category);
  } else {
    return repo.getMovies();
  }
});
