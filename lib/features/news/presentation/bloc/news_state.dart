part of 'news_bloc.dart';

class NewsState extends Equatable {
  const NewsState({
    this.status = FormStatus.pure,
    this.news = const [],
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.error = ''
  });
  final FormStatus status;
  final List<NewsArticle> news;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int page;
  final String error;

  NewsState copyWith(
      {
        FormStatus? status,
        List<NewsArticle>? news,
        bool? hasReachedMax,
        bool? isLoadingMore,
        int? page,
        String? error
      }
      ) {
    return NewsState(
        status: status ?? this.status,
        news: news ?? this.news,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        page: page ?? this.page,
        error: error ?? this.error
    );
  }
  @override
  List<Object> get props => [
    status,
    news,
    hasReachedMax,
    isLoadingMore,
    page,
    error
  ];
}
