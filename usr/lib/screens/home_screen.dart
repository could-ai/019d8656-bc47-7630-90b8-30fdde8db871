import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/breaking_news_banner.dart';
import '../widgets/ad_banner_widget.dart';
import 'saved_news_screen.dart';
import 'admin_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: AppConstants.categories.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<NewsProvider>().fetchArticles();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NewsProvider>();
      provider.fetchBreakingNews();
      provider.setCategory(AppConstants.categories[0]);
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      context.read<NewsProvider>().setCategory(AppConstants.categories[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
          },
          child: const Text('Dholpur News Live', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedNewsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.white,
          tabs: AppConstants.categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<NewsProvider>().fetchArticles(refresh: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(
              child: BreakingNewsBanner(),
            ),
            const SliverToBoxAdapter(
              child: AdBannerWidget(),
            ),
            Consumer<NewsProvider>(
              builder: (context, provider, child) {
                if (provider.articles.isEmpty && provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (provider.articles.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('कोई ख़बर नहीं मिली')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == provider.articles.length) {
                        return provider.hasMore
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      return NewsCard(article: provider.articles[index]);
                    },
                    childCount: provider.articles.length + (provider.hasMore ? 1 : 0),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
