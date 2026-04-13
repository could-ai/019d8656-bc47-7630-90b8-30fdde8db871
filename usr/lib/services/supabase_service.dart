import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_article.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NewsArticle>> getNews({String? category, int limit = 20, int offset = 0}) async {
    var query = _client.from('news_articles').select().order('created_at', ascending: false);
    
    if (category != null && category != 'Local') {
      query = query.eq('category', category);
    }
    
    final response = await query.range(offset, offset + limit - 1);
    
    return (response as List).map((json) => NewsArticle.fromJson(json)).toList();
  }

  Future<List<NewsArticle>> getBreakingNews() async {
    final response = await _client
        .from('news_articles')
        .select()
        .eq('is_breaking', true)
        .order('created_at', ascending: false)
        .limit(5);
        
    return (response as List).map((json) => NewsArticle.fromJson(json)).toList();
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    final response = await _client
        .from('news_articles')
        .select()
        .ilike('title', '%$query%')
        .order('created_at', ascending: false)
        .limit(20);
        
    return (response as List).map((json) => NewsArticle.fromJson(json)).toList();
  }
}
