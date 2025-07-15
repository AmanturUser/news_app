import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_work/features/news/domain/entities/news_entity.dart';
import 'package:test_work/features/news/domain/use_case/get_news.dart';
import '../../../../core/const/form_status.dart';

part 'news_event.dart';

part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetNews getNews;

  NewsBloc({required this.getNews}) : super(NewsState()) {
    on<NewsRequested>(_newsRequested);
    on<NewsRefreshRequested>(_onNewsRefreshRequested);
    on<NewsLoadMoreRequested>(_onNewsLoadMoreRequested);
  }

  _newsRequested(NewsRequested event, Emitter emit) async {
    emit(state.copyWith(status: FormStatus.submissionInProgress));
    final either = await getNews.call(state.page);
    either.fold(
        (error) => emit(state.copyWith(status: FormStatus.submissionFailure, error: error.message)),
        (news) {
      emit(state.copyWith(news: news, status: FormStatus.submissionSuccess));
    });
  }

  _onNewsRefreshRequested(NewsRefreshRequested event, Emitter emit) async {
    emit(state.copyWith(status: FormStatus.submissionInProgress));
    final either = await getNews.call(1);
    either.fold(
        (error) => emit(state.copyWith(status: FormStatus.submissionFailure)),
        (news) {
      emit(state.copyWith(
        news: news,
        status: FormStatus.submissionSuccess,
        hasReachedMax: news.length < 10,
      ));
    });
  }

  _onNewsLoadMoreRequested(NewsLoadMoreRequested event, Emitter emit) async {
    if (!state.hasReachedMax) {
      emit(state.copyWith(isLoadingMore: true));
      final either = await getNews.call(state.page + 1);
      either.fold(
          (error) => emit(
              state.copyWith(isLoadingMore: false)),
          (news) {
        emit(state.copyWith(
          news: [...state.news, ...news],
          isLoadingMore: false,
          page: state.page + 1,
          hasReachedMax: news.length < 10,
        ));
      });
    }
  }
}
