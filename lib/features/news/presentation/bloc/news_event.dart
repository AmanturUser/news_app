part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class NewsRequested extends NewsEvent {
  const NewsRequested();
}

class NewsRefreshRequested extends NewsEvent {
  const NewsRefreshRequested();
}

class NewsLoadMoreRequested extends NewsEvent {
  const NewsLoadMoreRequested();
}