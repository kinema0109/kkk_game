import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CardType { investigator, ancient_one, item, spell, condition, encounter }

class DynamicCardTemplate extends StatelessWidget {
  final String title;
  final String
      content; // This is the 'description' from metadata or the 'content' column
  final Map<String, dynamic> metadata;
  final CardType type;
  final Color? accentColor;

  const DynamicCardTemplate({
    super.key,
    required this.title,
    required this.content,
    required this.metadata,
    this.type = CardType.item,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Background Texture
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/paper-fibers.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header: Name & Type
                  _buildHeader(),
                  const SizedBox(height: 12),

                  // Middle Section: Stats or Icons
                  Expanded(
                    flex: 4,
                    child: _buildBody(),
                  ),

                  // Bottom Section: Effect/Content
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 5,
                    child: _buildFooter(),
                  ),
                ],
              ),
            ),

            // Corner Decorations (Optional theme touch)
            Positioned(
              top: -10,
              right: -10,
              child: Icon(Icons.shield_moon_outlined,
                  size: 40, color: _getAccentColor().withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            color: _getAccentColor(),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        if (metadata['title'] != null)
          Text(
            metadata['title'].toString().toUpperCase(),
            style: GoogleFonts.montserrat(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (type == CardType.investigator) {
      final stats = metadata['stats'] as Map<String, dynamic>? ?? {};
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCircle(
                    'HP', stats['health']?.toString() ?? '?', Colors.redAccent),
                _buildStatCircle('SAN', stats['sanity']?.toString() ?? '?',
                    Colors.blueAccent),
              ],
            ),
            const Divider(color: Colors.white10, height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSmallStat('Lore', stats['lore']?.toString() ?? '0'),
                _buildSmallStat('Inf', stats['influence']?.toString() ?? '0'),
                _buildSmallStat('Obs', stats['observation']?.toString() ?? '0'),
                _buildSmallStat('Str', stats['strength']?.toString() ?? '0'),
                _buildSmallStat('Will', stats['will']?.toString() ?? '0'),
              ],
            ),
          ],
        ),
      );
    }

    // Default: Show Icon/Placeholder for items/spells
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Icon(
          _getDefaultIcon(),
          size: 70,
          color: _getAccentColor().withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (metadata['effect'] != null) ...[
                  Text(
                    "EFFECT",
                    style: GoogleFonts.montserrat(
                      color: _getAccentColor().withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metadata['effect'],
                    style: GoogleFonts.notoSerif(
                        color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],
                if (metadata['abilities'] != null) ...[
                  for (var ability in (metadata['abilities'] as List))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "• $ability",
                        style: GoogleFonts.notoSerif(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ),
                ],
                Text(
                  content,
                  style: GoogleFonts.notoSerif(
                    color: Colors.white38,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (metadata['expansion'] != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              metadata['expansion'].toString().toUpperCase(),
              style:
                  GoogleFonts.montserrat(color: Colors.white12, fontSize: 10),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCircle(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(value,
                style: GoogleFonts.cinzel(
                    color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8)),
      ],
    );
  }

  Color _getAccentColor() {
    if (accentColor != null) return accentColor!;
    switch (type) {
      case CardType.investigator:
        return Colors.tealAccent.shade400;
      case CardType.ancient_one:
        return Colors.deepOrangeAccent;
      case CardType.condition:
        return Colors.amber.shade700;
      case CardType.spell:
        return Colors.deepPurpleAccent;
      case CardType.item:
        return Colors.blueGrey.shade400;
      case CardType.encounter:
        return Colors.green.shade700;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case CardType.investigator:
        return Icons.person_search;
      case CardType.ancient_one:
        return Icons.auto_awesome;
      case CardType.condition:
        return Icons.warning_amber_rounded;
      case CardType.spell:
        return Icons.auto_stories;
      case CardType.item:
        return Icons.gavel;
      case CardType.encounter:
        return Icons.location_on;
    }
  }
}
