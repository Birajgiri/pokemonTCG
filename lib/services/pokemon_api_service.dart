import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_card.dart';

class PokemonApiService {
  static const String baseUrl = 'https://api.pokemontcg.io/v2';
  static const String apiKey = 'e2a66998-cd20-40a6-adcf-41e16b3e81c2';

  Future<List<PokemonCard>> fetchCards({int page = 1, int pageSize = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cards?page=$page&pageSize=$pageSize'),
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> cardsJson = jsonData['data'];
        
        return cardsJson.map((json) => PokemonCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load Pokemon cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cards: $e');
    }
  }

  Future<PokemonCard> fetchCardById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cards/$id'),
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PokemonCard.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching card: $e');
    }
  }

  Future<List<PokemonCard>> searchCards(String query) async {
    try {
      // Clean and format the search query
      final cleanQuery = query.trim();
      
      // URL encode the query to handle special characters and spaces
      final encodedQuery = Uri.encodeComponent('name:"*$cleanQuery*"');
      
      final response = await http.get(
        Uri.parse('$baseUrl/cards?q=$encodedQuery&pageSize=100'),
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> cardsJson = jsonData['data'];
        
        return cardsJson.map((json) => PokemonCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching cards: $e');
    }
  }
}
