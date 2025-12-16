import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:practice_flutter/models/photo.dart';

class PhotosService {
  static Future<List<Photo>> fetchPhotos() async {
    final client = http.Client();
    final response = await client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/photos'),
    );

    return compute(parsePhotos, response.body);
  }

  static Future<List<Photo>> parsePhotos(String responseBody) async {
    if (kDebugMode) {
      print(responseBody);
    }
    try {
      final parsed = (jsonDecode(responseBody) as List<Object?>)
          .cast<Map<String, Object?>>();
      return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }
}
