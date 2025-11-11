import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../models/pokemon_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PokemonCard? _selectedCard;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            context.read<PokemonProvider>().refreshCards();
            setState(() {
              _selectedCard = null;
            });
          },
          child: const Text('Pokemon Cards'),
        ),
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cards.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null && provider.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading cards',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshCards(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.cards.isEmpty) {
            return const Center(
              child: Text('No cards found'),
            );
          }

          // Sort cards alphabetically
          final sortedCards = List<PokemonCard>.from(provider.cards)
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final isMobile = constraints.maxWidth < 600;
              
              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 8.0,
                radius: const Radius.circular(10),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _selectedCard == null
                      ? _buildGridView(sortedCards, isDesktop, isMobile)
                      : _buildExpandedView(_selectedCard!, isDesktop, isMobile),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<PokemonCard> cards, bool isDesktop, bool isMobile) {
    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isMobile) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _buildGridCard(card);
      },
    );
  }

  Widget _buildGridCard(PokemonCard card) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCard = card;
        });
      },
      child: Hero(
        tag: 'card_${card.id}',
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: card.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedView(PokemonCard card, bool isDesktop, bool isMobile) {
    if (isMobile) {
      // Mobile: Card on top, description below
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseButton(),
          const SizedBox(height: 16),
          Center(
            child: Hero(
              tag: 'card_${card.id}',
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 560,
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: card.imageUrlHiRes ?? card.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 64),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildCardDescription(card),
        ],
      );
    } else {
      // Desktop/Tablet: Card on left, description on right
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseButton(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card on the left
              Hero(
                tag: 'card_${card.id}',
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    maxHeight: 560,
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: card.imageUrlHiRes ?? card.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, size: 64),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Description on the right
              Expanded(
                child: _buildCardDescription(card),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: () {
          setState(() {
            _selectedCard = null;
          });
        },
        icon: const Icon(Icons.arrow_back),
        iconSize: 32,
        style: IconButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildCardDescription(PokemonCard card) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            if (card.supertype != null)
              _buildInfoRow('Type', card.supertype!, Colors.blue),
            if (card.subtype != null)
              _buildInfoRow('Subtype', card.subtype!, Colors.purple),
            if (card.hp != null)
              _buildInfoRow('HP', card.hp!, Colors.red),
            if (card.rarity != null)
              _buildInfoRow('Rarity', card.rarity!, Colors.amber),
            if (card.artist != null)
              _buildInfoRow('Artist', card.artist!, Colors.green),
            if (card.set != null)
              _buildInfoRow('Set', card.set!, Colors.indigo),
            if (card.series != null)
              _buildInfoRow('Series', card.series!, Colors.teal),
            if (card.number != null)
              _buildInfoRow('Number', card.number!, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
