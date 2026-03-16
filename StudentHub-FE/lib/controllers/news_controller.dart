import 'package:bai1/models/news.dart';
import 'package:bai1/services/news_service.dart';

class NewsController {
  final NewsService _newsService = NewsService();

  Future<List<News>> fetchNews() async {
    try {
      return await _newsService.getNews();
    } catch (e) {
      print("Error fetching news: $e");
      return [];
    }
  }
}
