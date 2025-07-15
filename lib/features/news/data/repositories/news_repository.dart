import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:test_work/features/news/domain/entities/news_entity.dart';
import '../../../../core/error_journal/error_journal.dart';
import '../../domain/repository/repository.dart';
import '../data_source/news_server.dart';


@Injectable(as: NewsRepository)

class NewsRepositoryImpl implements NewsRepository{
  final NewsSource newsSource;
  NewsRepositoryImpl({required this.newsSource});

  @override
  Future<Either<Failure, List<NewsArticle>>> getNews({required int page}) async {
    return await _getNews(page);
  }

  Future<Either<Failure, List<NewsArticle>>> _getNews(int page) async {
    try {
      final truth = await newsSource.getNews(page: page);
      return Right(truth);
    } on SocketException {
      return Left(ServerError(error:'No internet connection. Please check your network.'));
    } on HttpException {
      return Left(ServerError(error:'Network error occurred'));
    } on FormatException {
      return Left(ServerError(error:'Invalid response format from server'));
    }
    on Failure catch (e) {
      return Left(ServerError(error: e.message));
    }
  }
}