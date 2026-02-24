import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../l10n/app_localizations.dart';

class DraftingView extends StatefulWidget {
  const DraftingView({super.key});

  @override
  State<DraftingView> createState() => _DraftingViewState();
}

class _DraftingViewState extends State<DraftingView> {
  final Set<String> _selectedMeans = {};
  final Set<String> _selectedClues = {};

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    // Find self within players
    final selfPlayer = game.players.firstWhereOrNull((p) => p.isMe);

    if (selfPlayer == null) return const SizedBox.shrink();

    // If Forensic Scientist OR already drafted, show waiting message
    if (selfPlayer.role == Role.FORENSIC_SCIENTIST || selfPlayer.hasDrafted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                selfPlayer.hasDrafted
                    ? Icons.check_circle_outline
                    : Icons.psychology,
                size: 64,
                color: selfPlayer.hasDrafted
                    ? Colors.greenAccent
                    : Colors.white24),
            const SizedBox(height: 24),
            Text(
              (selfPlayer.hasDrafted
                  ? 'WAITING FOR OTHER SUSPECTS...'
                  : l10n.waitingForSuspectsSelection.toUpperCase()),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color:
                    selfPlayer.hasDrafted ? Colors.greenAccent : Colors.white38,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selfPlayer.hasDrafted
                  ? 'Your equipment is ready. The investigation will begin soon.'
                  : 'The investigation will begin once suspects have chosen their equipment.',
              style: const TextStyle(fontSize: 12, color: Colors.white24),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    final means = selfPlayer.draftMeans ?? [];
    final clues = selfPlayer.draftClues ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInstruction(context),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSection('MEANS CARDS', means, _selectedMeans,
                    Theme.of(context).colorScheme.secondary),
                const SizedBox(height: 24),
                _buildSection('CLUE CARDS', clues, _selectedClues,
                    Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildInstruction(BuildContext context) {
    return Column(
      children: [
        Text(
          'EQUIPMENT LOG',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const Text(
          'Select 5 Means and 5 Clues to define your suspect profile.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> cards,
      Set<String> selected, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white54)),
        const Divider(color: Colors.white10),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final cardId = card['id'] as String;
              final isSelected = selected.contains(cardId);
              return _buildCardItem(card, isSelected, selected, themeColor);
            },
          );
        }),
      ],
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, bool isSelected,
      Set<String> selected, Color themeColor) {
    final cardId = card['id'] as String;
    final cardName = card['name'] as String? ?? 'Unknown';
    final imageUrl = card['image_url'] as String?;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selected.remove(cardId);
          } else if (selected.length < 5) {
            selected.add(cardId);
          }
        });
      },
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color:
              isSelected ? themeColor.withValues(alpha: 0.2) : Colors.black45,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? themeColor : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: themeColor.withValues(alpha: 0.2), blurRadius: 8)
                ]
              : [],
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
                  opacity: AlwaysStoppedAnimation(isSelected ? 0.6 : 0.3),
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, size: 20)),
                )
              else
                Image.network(
                  imageUrl ?? 'https://placehold.co/90x120?text=?',
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(isSelected ? 0.6 : 0.3),
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, size: 20)),
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
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.check_circle, size: 16, color: themeColor),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildConfirmButton(BuildContext context) {
    final canConfirm = _selectedMeans.length == 5 && _selectedClues.length == 5;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canConfirm
            ? () {
                context.read<GameProvider>().sendAction('confirm_draft', {
                  'selected_means': _selectedMeans.toList(),
                  'selected_clues': _selectedClues.toList(),
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          canConfirm
              ? 'INITIALIZE PROFILE'
              : 'REQUIRE ${5 - _selectedMeans.length} M / ${5 - _selectedClues.length} C',
          style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
      ),
    )
        .animate(target: canConfirm ? 1 : 0)
        .shimmer(duration: 2.seconds, color: Colors.white24);
  }
}
