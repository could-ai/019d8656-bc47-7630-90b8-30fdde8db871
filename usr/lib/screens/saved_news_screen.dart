import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';

class SavedNewsScreen extends StatelessWidget {
  const SavedNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved News'),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, child) {
          if (provider.savedArticles.isEmpty) {
            return const Center(
              child: Text('No saved articles yet.'),
            );
          }

          return ListView.builder(
            itemCount: provider.savedArticles.length,
            itemBuilder: (context, index) {
              return NewsCard(article: provider.savedArticles[index]);
            },
          );
        },
      ),
    );
  }
}
