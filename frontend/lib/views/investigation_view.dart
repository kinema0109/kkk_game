import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../l10n/app_localizations.dart';

class InvestigationView extends StatelessWidget {
  final bool isForensicSetup;
  const InvestigationView({super.key, this.isForensicSetup = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.gameState;
    if (game == null) return const SizedBox.shrink();

    final fs =
        game.players.firstWhereOrNull((p) => p.role == Role.FORENSIC_SCIENTIST);
    final tiles = fs?.activeTiles ?? [];
    final isSelfFS = fs?.isMe ?? false;

    if (tiles.isEmpty) {
      return _buildLoadingState(l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 16, 8),
          child: Row(
            children: [
              Icon(Icons.radar, size: 16, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                isForensicSetup
                    ? l10n.statusForensicSetup.toUpperCase()
                    : l10n.hienTruong,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
              const Spacer(),
              if (isForensicSetup && isSelfFS)
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<GameProvider>()
                        .sendAction('confirm_tiles', {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(l10n.confirmTiles.toUpperCase()),
                ),
            ],
          ),
        ),
        if (game.meansCard != null && game.clueCard != null)
          _buildCrimeInfo(context, game.meansCard!, game.clueCard!),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1500 ? 4 : 2;
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: tiles.length,
              itemBuilder: (context, index) {
                final tile = tiles[index];
                return _buildTileCard(context, tile, isSelfFS, fs, index,
                    key: ValueKey(tile.id));
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            l10n.examiningScene,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
                letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTileCard(
      BuildContext context, Tile tile, bool isSelfFS, Player? fs, int index,
      {Key? key}) {
    Color borderColor = Colors.white10;
    IconData icon = Icons.search;

    if (tile.title.toLowerCase().contains('cause')) {
      borderColor = Colors.purple;
      icon = Icons.coronavirus;
    } else if (tile.title.toLowerCase().contains('location')) {
      borderColor = Colors.teal;
      icon = Icons.location_on;
    } else if (tile.title.toLowerCase().contains('trace')) {
      borderColor = Colors.orange;
      icon = Icons.fingerprint;
    } else if (tile.title.toLowerCase().contains('motive')) {
      borderColor = Colors.blue;
      icon = Icons.psychology;
    } else if (tile.title.toLowerCase().contains('corpse')) {
      borderColor = Colors.redAccent;
      icon = Icons.person_off;
    }

    return Card(
      key: key,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
            color: borderColor.withValues(alpha: 0.5),
            width: 2), // Matching user screenshot style
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                if (tile.imageUrl != null)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: (tile.imageUrl!.startsWith('assets/'))
                            ? AssetImage(tile.imageUrl!) as ImageProvider
                            : NetworkImage(tile.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Icon(icon, size: 14, color: borderColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tile.title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: borderColor,
                        letterSpacing: 1.2),
                  ),
                ),
                if (isSelfFS &&
                    tile.type == 'SCENE' &&
                    (fs?.tilesReplaced ?? 0) < 2)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    color: borderColor.withValues(alpha: 0.5),
                    tooltip: 'Replace Tile',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      context.read<GameProvider>().sendAction('replace_tile', {
                        'tile_id': tile.id,
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tile.options.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final text = entry.value;
                  final isSelected = tile.selectedOption == idx;

                  return _buildOptionChip(context, text, isSelected, isSelfFS,
                      tile.id.toString(), idx, borderColor);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
  }

  Widget _buildCrimeInfo(BuildContext context, Map<String, dynamic> means,
      Map<String, dynamic> clue) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.murdererCards.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildCrimeMiniCard(means, Colors.orangeAccent),
                    const SizedBox(width: 12),
                    _buildCrimeMiniCard(clue, Colors.lightBlueAccent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrimeMiniCard(Map<String, dynamic> card, Color color) {
    return Expanded(
      child: Row(
        children: [
          if (card['image_url'] != null)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: (card['image_url']!.startsWith('assets/'))
                      ? AssetImage(card['image_url']!) as ImageProvider
                      : NetworkImage(card['image_url']!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (card['content'] != null)
                  Text(
                    card['content'],
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(BuildContext context, String text, bool isSelected,
      bool isSelfFS, String tileId, int idx, Color activeColor) {
    return InkWell(
      onTap: isSelfFS
          ? () {
              context.read<GameProvider>().sendAction('select_tile_option', {
                'tile_id': tileId,
                'option_index': idx,
              });
            }
          : null,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white10,
            width: 1,
          ),
        ),
        child: Text(
          isSelected ? text.toUpperCase() : text,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.white : Colors.white24,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
