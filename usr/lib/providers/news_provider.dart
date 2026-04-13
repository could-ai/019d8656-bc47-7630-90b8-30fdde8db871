import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewsProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<NewsArticle> _articles = [];
  List<NewsArticle> _breakingNews = [];
  List<NewsArticle> _savedArticles = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _currentCategory = 'Local';
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get breakingNews => _breakingNews;
  List<NewsArticle> get savedArticles => _savedArticles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get currentCategory => _currentCategory;
  bool get hasMore => _hasMore;

  NewsProvider() {
    _loadSavedArticles();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _fetchBreakingNews(),
        fetchNews(refresh: true),
      ]);
    } catch (e) {
      debugPrint('Error fetching initial data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchBreakingNews() async {
    try {
      _breakingNews = await _supabaseService.getBreakingNews();
    } catch (e) {
      debugPrint('Error fetching breaking news: $e');
    }
  }

  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _hasMore = true;
      _articles.clear();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final newArticles = await _supabaseService.getNews(
        category: _currentCategory,
        limit: _limit,
        offset: _offset,
      );

      if (newArticles.length < _limit) {
        _hasMore = false;
      }

      _articles.addAll(newArticles);
      _offset += newArticles.length;
    } catch (e) {
      debugPrint('Error fetching news: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_currentCategory != category) {
      _currentCategory = category;
      fetchNews(refresh: true);
    }
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      return await _supabaseService.searchNews(query);
    } catch (e) {
      debugPrint('Error searching news: $e');
      return [];
    }
  }

  // Saved Articles Logic
  Future<void> _loadSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_articles') ?? [];
    _savedArticles = savedData
        .map((jsonStr) => NewsArticle.fromJson(jsonDecode(jsonStr)))
        .toList();
    notifyListeners();
  }

  Future<void> toggleSaveArticle(NewsArticle article) async {
    final isSaved = isArticleSaved(article.id);
    
    if (isSaved) {
      _savedArticles.removeWhere((a) => a.id == article.id);
    } else {
      _savedArticles.add(article);
    }
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final savedData = _savedArticles
        .map((a) => jsonEncode(a.toJson()))
        .toList();
    await prefs.setStringList('saved_articles', savedData);
  }

  bool isArticleSaved(String id) {
    return _savedArticles.any((a) => a.id == id);
  }
}
