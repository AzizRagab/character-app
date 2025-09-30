// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class ApiService {
  static const String baseUrl = "https://rickandmortyapi.com/api/character";

  Future<List<Character>> getCharacters() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Character> characters = [];

        for (var item in data['results']) {
          characters.add(Character.fromJson(item));
        }

        return characters;
      } else {
        throw 'Failed to load characters';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }
}