import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../integrations/supabase.dart';

class NewsProvider with ChangeNotifier {
  List<NewsArticle> _articles = [];
  List<NewsArticle> _breakingNews = [];
  List<NewsArticle> _savedArticles = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentCategory = 'Local';
  String _searchQuery = '';
  
  static const int _pageSize = 10;

  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get breakingNews => _breakingNews;
  List<NewsArticle> get savedArticles => _savedArticles;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get currentCategory => _currentCategory;

  Future<void> fetchBreakingNews() async {
    try {
      final response = await SupabaseConfig.client
          .from('news_articles')
          .select()
          .eq('is_breaking', true)
          .order('created_at', ascending: false)
          .limit(5);
          
      _breakingNews = (response as List).map((json) => NewsArticle.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching breaking news: $e');
    }
  }

  Future<void> fetchArticles({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _articles.clear();
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      var query = SupabaseConfig.client
          .from('news_articles')
          .select()
          .order('created_at', ascending: false)
          .range(_articles.length, _articles.length + _pageSize - 1);

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$_searchQuery%');
      } else if (_currentCategory != 'All') {
        query = query.eq('category', _currentCategory);
      }

      final response = await query;
      final newArticles = (response as List).map((json) => NewsArticle.fromJson(json)).toList();

      if (newArticles.length < _pageSize) {
        _hasMore = false;
      }

      _articles.addAll(newArticles);
    } catch (e) {
      debugPrint('Error fetching articles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_currentCategory != category) {
      _currentCategory = category;
      _searchQuery = '';
      fetchArticles(refresh: true);
    }
  }

  void searchNews(String query) {
    _searchQuery = query;
    fetchArticles(refresh: true);
  }

  void toggleSaveArticle(NewsArticle article) {
    final index = _savedArticles.indexWhere((a) => a.id == article.id);
    if (index >= 0) {
      _savedArticles.removeAt(index);
    } else {
      _savedArticles.add(article);
    }
    notifyListeners();
  }

  bool isArticleSaved(String id) {
    return _savedArticles.any((a) => a.id == id);
  }
}
