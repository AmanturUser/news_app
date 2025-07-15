import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:test_work/core/const/const.dart';
import 'package:test_work/features/news/domain/entities/news_entity.dart';
import '../../../../core/error_journal/error_journal.dart';
import '../../../../core/services/api_service.dart';

abstract interface class INewsSource {
  Future<List<NewsArticle>> getNews({required int page});
}

@injectable
class NewsSource implements INewsSource {
  ApiService apiService = ApiService();

  @override
  Future<List<NewsArticle>> getNews({required int page}) async {
    final response = await apiService.get(
        '/everything?q=bitcoin&pageSize=10&page=$page&apiKey=${ApiUrl.apiKey}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok') {
        final articles = data['articles'] as List;
        final newsArticles = articles
            .map((article) => NewsArticle.fromJson(article))
            .toList();
        return newsArticles;
      } else {
        throw ServerError(error: 'API Error: ${data['message'] ?? 'Unknown error'}');
      }
    } else if (response.statusCode == 401) {
      throw ServerError(error:'Invalid API key. Please check your NewsAPI key.');
    } else if (response.statusCode == 429) {
      final data = json.decode(response.body);
      throw ServerError(error: 'API Error: ${data['message']}');
    } else {
      throw ServerError(error:'Failed to load news: HTTP ${response.statusCode}');
    }
  }
}
