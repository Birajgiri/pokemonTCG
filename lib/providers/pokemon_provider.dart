import 'package:flutter/foundation.dart';
import '../models/pokemon_card.dart';
import '../services/pokemon_api_service.dart';
import '../services/local_storage_service.dart';

class PokemonProvider with ChangeNotifier {
  final PokemonApiService _apiService = PokemonApiService();
  final LocalStorageService _storageService = LocalStorageService();

  List<PokemonCard> _cards = [];
  List<PokemonCard> _allCards = []; // Store all cards for local filtering
  bool _isLoading = false;
  String? _error;

  List<PokemonCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PokemonProvider() {
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First, load from local storage
      final cachedCards = await _storageService.loadCards();
      if (cachedCards.isNotEmpty) {
        _cards = cachedCards;
        _allCards = cachedCards;
        _isLoading = false;
        notifyListeners();
      }

      // Then fetch from API
      final apiCards = await _apiService.fetchCards(pageSize: 100);
      _cards = apiCards;
      _allCards = apiCards;
      
      // Save to local storage
      await _storageService.saveCards(apiCards);
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      // If we have cached cards, keep showing them
      if (_cards.isEmpty) {
        print('Error loading cards: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCards() async {
    await loadCards();
  }

  PokemonCard? getCardById(String id) {
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> searchCards(String query) async {
    if (query.isEmpty) {
      _cards = _allCards;
      notifyListeners();
      return;
    }

    // Do instant local search - no loading needed
    final lowerQuery = query.toLowerCase();
    _cards = _allCards.where((card) {
      return card.name.toLowerCase().contains(lowerQuery);
    }).toList();
    
    notifyListeners();
  }
}
