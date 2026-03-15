import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/news.dart';

class NewsService {
  Future<List<News>> getNews() async {
    final response = await http.get(Uri.parse(ApiConfig.getNews));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => News.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
