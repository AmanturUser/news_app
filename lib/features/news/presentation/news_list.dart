// lib/screens/news_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_work/features/news/presentation/widget/news_item.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/const/form_status.dart';
import 'bloc/news_bloc.dart';
import 'news_detail/news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    context.read<NewsBloc>().add(const NewsRequested());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NewsBloc>().add(const NewsLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<NewsBloc>().add(const NewsRefreshRequested()),
          ),
        ],
      ),
      body: BlocBuilder<NewsBloc, NewsState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.isLoadingMore != current.isLoadingMore,
        builder: (context, state) {
          if (state.status == FormStatus.submissionInProgress) {
            return const Center(
              child: SpinKitFadingCircle(
                color: Colors.deepPurple,
                size: 50.0,
              ),
            );
          }

          if (state.status == FormStatus.submissionFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<NewsBloc>().add(const NewsRequested()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state.status == FormStatus.submissionSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NewsBloc>().add(const NewsRefreshRequested());
              },
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  for (var article in state.news)
                    NewsItem(
                      article: article,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewsDetailScreen(article: article),
                          ),
                        );
                      },
                    ),
                  if (state.isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                          child: const SpinKitThreeBounce(
                        color: Colors.deepPurple,
                        size: 24.0,
                      )),
                    )
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
