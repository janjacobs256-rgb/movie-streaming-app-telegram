import 'package:supabase_flutter/supabase_flutter.dart';
import '../../movies/domain/movie_model.dart';

class FavoriteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MovieModel>> getFavoriteMovies() async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('*, movies(*)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) {
        final fav = json as Map<String, dynamic>;
        final movieJson = fav['movies'] as Map<String, dynamic>;
        return MovieModel.fromJson(movieJson);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isFavorite(String movieId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('movie_id', movieId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> addFavorite(String movieId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated.');

    await _supabase.from('favorites').insert({
      'user_id': userId,
      'movie_id': movieId,
    });
  }

  Future<void> removeFavorite(String movieId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated.');

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('movie_id', movieId);
  }
}
