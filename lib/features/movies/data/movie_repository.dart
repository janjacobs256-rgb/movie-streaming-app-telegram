import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_config.dart';
import '../domain/movie_model.dart';

class MovieRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MovieModel>> getMovies() async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .order('created_at', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => MovieModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MovieModel>> getMoviesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => MovieModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => MovieModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('movies')
          .select('category');
      
      final List<dynamic> data = response as List<dynamic>;
      final categories = data
          .map((item) => item['category'] as String? ?? 'General')
          .toSet()
          .toList();
      
      if (!categories.contains('All')) {
        categories.insert(0, 'All');
      }
      return categories;
    } catch (e) {
      return ['All', 'General'];
    }
  }

  // Force indexing by invoking the backend /index endpoint
  Future<int> triggerIndexing() async {
    try {
      final response = await http.post(
        Uri.parse('${SupabaseConfig.backendUrl}/index'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['new_videos_indexed'] as int? ?? 0;
      } else {
        throw Exception('Failed to index videos: ${response.body}');
      }
    } catch (e) {
      throw Exception('Indexer error: $e');
    }
  }
}
