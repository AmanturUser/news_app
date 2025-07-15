import 'package:equatable/equatable.dart';

class NewsArticle extends Equatable {
  final String title;
  final String description;
  final String content;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String sourceName;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      content: json['content'] ?? 'No Content Available',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      sourceName: json['source']?['name'] ?? 'Unknown Source',
    );
  }


  @override
  List<Object?> get props => [
    title,
    description,
    content,
    url,
    urlToImage,
    publishedAt,
    sourceName,
  ];
}