import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_card.dart';
import '../services/pokemon_api_service.dart';
import 'welcome_screen.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final PokemonApiService _apiService = PokemonApiService();
  PokemonCard? _card1;
  PokemonCard? _card2;
  String? _winner;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRandomBattle();
  }

  Future<void> _loadRandomBattle() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
      _winner = null;
      _card1 = null;
      _card2 = null;
    });

    try {
      // Fetch random cards from API
      final cards = await _apiService.fetchCards(pageSize: 100);
      
      if (!mounted) return;
      
      if (cards.isEmpty) {
        setState(() {
          _error = 'No cards available';
          _isLoading = false;
        });
        return;
      }

      // Shuffle and pick 2 random cards
      cards.shuffle();
      final card1 = cards[0];
      final card2 = cards[1];

      // Determine winner based on HP
      String winner;
      final hp1 = int.tryParse(card1.hp ?? '0') ?? 0;
      final hp2 = int.tryParse(card2.hp ?? '0') ?? 0;

      if (hp1 > hp2) {
        winner = '${card1.name} WINS!';
      } else if (hp2 > hp1) {
        winner = '${card2.name} WINS!';
      } else {
        winner = 'It\'s a TIE!';
      }

      if (!mounted) return;

      setState(() {
        _card1 = card1;
        _card2 = card2;
        _winner = winner;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = 'Failed to load cards: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              ),
            );
          },
          child: Image.asset(
            'assets/images/logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade700,
              Colors.teal.shade600,
              Colors.green.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          child: SafeArea(
            child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRandomBattle,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Winner announcement
                      if (_winner != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber[700]!, Colors.amber[300]!],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.emoji_events, size: 32, color: Colors.white),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  _winner!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Battle cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 700) {
                            // Desktop layout - side by side
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildCardDisplay(_card1, 1)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildCardDisplay(_card2, 2)),
                              ],
                            );
                          } else {
                            // Mobile layout - stacked
                            return Column(
                              children: [
                                _buildCardDisplay(_card1, 1),
                                const SizedBox(height: 24),
                                _buildCardDisplay(_card2, 2),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      // Battle Again button
                      ElevatedButton.icon(
                        onPressed: _loadRandomBattle,
                        icon: const Icon(Icons.refresh, size: 28),
                        label: const Text(
                          'BATTLE AGAIN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardDisplay(PokemonCard? card, int cardNumber) {
    if (card == null) {
      return const SizedBox.shrink();
    }

    final isWinner = _winner?.contains(card.name) ?? false;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isWinner ? Colors.amber : Colors.grey[300]!,
          width: isWinner ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Card(
        elevation: 6,
        color: Colors.white.withOpacity(0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              // Card number
              Text(
                'Card $cardNumber',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),

              // Pokemon image
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 240,
                  maxWidth: 180,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: card.imageUrlHiRes ?? card.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 240,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 240,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 64),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Pokemon name
              Text(
                card.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // HP display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'HP: ${card.hp ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Winner badge
              if (isWinner) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'WINNER',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
