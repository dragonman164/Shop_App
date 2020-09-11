import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier{
  final String id,title,description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false });

  Future<void> toggleFavoriteStatus() async{
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://shop-app-87a68.firebaseio.com/products/$id.json';
    try{
     await http.patch(url,body: json.encode({
        'isFavorite':isFavorite,
      }));
    }catch(error){
 isFavorite = oldStatus;
 notifyListeners();
    }

  }


}