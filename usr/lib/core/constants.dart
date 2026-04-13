import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Dholpur News Live';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static const List<String> categories = [
    'Local',
    'Rajasthan',
    'India',
    'Jobs',
    'Sports',
    'Entertainment'
  ];
}

class AppColors {
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
}
