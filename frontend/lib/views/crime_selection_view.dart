import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class CrimeSelectionView extends StatefulWidget {
  const CrimeSelectionView({super.key});

  @override
  State<CrimeSelectionView> createState() => _CrimeSelectionViewState();
}

class _CrimeSelectionViewState extends State<CrimeSelectionView> {
  String? _selectedMeans;
  String? _selectedClue;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    // Find self within players
    final player = game.players.firstWhereOrNull((p) => p.isMe);
    if (player == null ||
        (player.role != Role.MURDERER && player.role != Role.ACCOMPLICE)) {
      return _buildWaitingState();
    }

    final means = player.meansCards ?? [];
    final clues = player.clueCards ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildRadioSection(
                    'SELECT MURDER WEAPON',
                    means,
                    _selectedMeans,
                    (val) => setState(() => _selectedMeans = val),
                    Colors.redAccent),
                const SizedBox(height: 24),
                _buildRadioSection(
                    'SELECT KEY EVIDENCE',
                    clues,
                    _selectedClue,
                    (val) => setState(() => _selectedClue = val),
                    Colors.blueAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
              strokeWidth: 2, color: Colors.redAccent),
          const SizedBox(height: 24),
          Text(
            'THE CRIME IS BEING COMMITTED...',
            style: TextStyle(
              color: Colors.redAccent.withValues(alpha: 0.7),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'COMMIT THE CRIME',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 3,
          ),
        ),
        Text(
          'Choose the items that will define the case.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildRadioSection(String title, List<Map<String, dynamic>> cards,
      String? selected, Function(String) onSelect, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white54)),
        const Divider(color: Colors.white10),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final cardId = card['id'] as String;
              final cardName = card['name'] as String? ?? 'Unknown';
              final imageUrl = card['image_url'] as String?;
              final isSelected = selected == cardId;

              return GestureDetector(
                onTap: () => onSelect(cardId),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.2)
                        : Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : accentColor.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: accentColor.withValues(alpha: 0.2),
                                blurRadius: 8)
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null && imageUrl.startsWith('assets/'))
                          Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            opacity:
                                AlwaysStoppedAnimation(isSelected ? 0.6 : 0.3),
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.broken_image, size: 20)),
                          )
                        else
                          Image.network(
                            imageUrl ?? 'https://placehold.co/90x140?text=?',
                            fit: BoxFit.cover,
                            opacity:
                                AlwaysStoppedAnimation(isSelected ? 0.6 : 0.3),
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.broken_image, size: 20)),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                cardName.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(Icons.check_circle,
                                size: 16, color: accentColor),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final canConfirm = _selectedMeans != null && _selectedClue != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canConfirm
            ? () {
                context.read<GameProvider>().sendAction('confirm_crime', {
                  'means_id': _selectedMeans,
                  'clue_id': _selectedClue,
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade900,
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text('SEAL THE CASE',
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
      ),
    ).animate(target: canConfirm ? 1 : 0).shake(hz: 4, curve: Curves.easeInOut);
  }
}
