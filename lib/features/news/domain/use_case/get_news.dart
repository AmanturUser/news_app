import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:test_work/features/news/domain/entities/news_entity.dart';

import '../../../../core/error_journal/error_journal.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/repository.dart';

@injectable
class GetNews implements UseCase<List<NewsArticle>, int> {
  final NewsRepository newsRepository;

  GetNews({required this.newsRepository});

  @override
  Future<Either<Failure, List<NewsArticle>>> call(int page) async {
    return await newsRepository.getNews(page: page);
  }
}
