import 'package:dartz/dartz.dart';
import 'package:test_work/features/news/domain/entities/news_entity.dart';

import '../../../../core/error_journal/error_journal.dart';

abstract interface class NewsRepository {
  Future<Either<Failure, List<NewsArticle>>> getNews({required int page});
}
