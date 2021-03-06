import 'dart:convert';

import 'package:app_4/models/http_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.description,
    @required this.id,
    @required this.imageUrl,
    this.isFavorite = false,
    @required this.price,
    @required this.title,
  });

  Future<void> toggleFavorite(String token, String userId) async {
    final url =
        'https://shop-app-8139c.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    var currentFavoriteStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.put(
      url,
      body: json.encode(
        isFavorite,
      ),
    );
    if (response.statusCode >= 400) {
      isFavorite = currentFavoriteStatus;
      notifyListeners();

      throw HttpException('Could not modify the favorite status');
    }
    currentFavoriteStatus = null;
  }
}
