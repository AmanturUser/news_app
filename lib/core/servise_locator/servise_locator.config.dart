import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:test_work/features/news/domain/use_case/get_news.dart';

import '../../features/news/data/data_source/news_server.dart';
import '../../features/news/data/repositories/news_repository.dart';
import '../../features/news/domain/repository/repository.dart';
import '../../features/news/presentation/bloc/news_bloc.dart';

extension GetItInjectableX on _i1.GetIt {
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );

    gh.factory<NewsSource>(() => NewsSource());
    gh.factory<NewsRepository>(
        () => NewsRepositoryImpl(newsSource: gh<NewsSource>()));
    gh.factory<GetNews>(() => GetNews(newsRepository: gh<NewsRepository>()));
    gh.factory<NewsBloc>(() => NewsBloc(getNews: gh<GetNews>()));

    return this;
  }
}
