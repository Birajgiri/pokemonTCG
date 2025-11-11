import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardDetailScreen extends StatelessWidget {
  final PokemonCard card;

  const CardDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 900;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(card.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: isDesktop
                  ? _buildDesktopLayout(context)
                  : _buildMobileLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Image on the left
        Expanded(
          flex: 2,
          child: Hero(
            tag: 'card_${card.id}',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CachedNetworkImage(
                imageUrl: card.imageUrlHiRes ?? card.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 600,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 600,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 64),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
        // Card Details on the right
        Expanded(
          flex: 3,
          child: _buildCardInfo(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Card Image
        Hero(
          tag: 'card_${card.id}',
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: card.imageUrlHiRes ?? card.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                height: 400,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 400,
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 64),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Card Details below
        _buildCardInfo(context),
      ],
    );
  }

  Widget _buildCardInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.name,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
          ),
          const SizedBox(height: 8),
          if (card.supertype != null || card.subtype != null)
            Text(
              '${card.supertype ?? ''}${card.supertype != null && card.subtype != null ? ' - ' : ''}${card.subtype ?? ''}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          const Divider(height: 30, thickness: 1.5),
          _buildDetailSection(context),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.hp != null)
          _buildInfoChip(
            context,
            icon: Icons.favorite,
            label: 'HP',
            value: card.hp!,
            color: Colors.red,
          ),
        if (card.rarity != null)
          _buildInfoChip(
            context,
            icon: Icons.star,
            label: 'Rarity',
            value: card.rarity!,
            color: Colors.amber,
          ),
        if (card.set != null)
          _buildInfoChip(
            context,
            icon: Icons.collections_bookmark,
            label: 'Set',
            value: '${card.set}${card.number != null ? ' #${card.number}' : ''}',
            color: Colors.blue,
          ),
        if (card.series != null)
          _buildInfoChip(
            context,
            icon: Icons.category,
            label: 'Series',
            value: card.series!,
            color: Colors.purple,
          ),
        if (card.artist != null)
          _buildInfoChip(
            context,
            icon: Icons.brush,
            label: 'Artist',
            value: card.artist!,
            color: Colors.green,
          ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
