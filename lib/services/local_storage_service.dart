import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_card.dart';

class LocalStorageService {
  static const String _cardsKey = 'pokemon_cards';

  Future<void> saveCards(List<PokemonCard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsJson = cards.map((card) => card.toJson()).toList();
      await prefs.setString(_cardsKey, json.encode(cardsJson));
    } catch (e) {
      print('Error saving cards: $e');
    }
  }

  Future<List<PokemonCard>> loadCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsString = prefs.getString(_cardsKey);
      
      if (cardsString != null) {
        final List<dynamic> cardsJson = json.decode(cardsString);
        return cardsJson.map((json) => PokemonCard.fromStorageJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading cards: $e');
      return [];
    }
  }

  Future<void> clearCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cardsKey);
    } catch (e) {
      print('Error clearing cards: $e');
    }
  }
}
