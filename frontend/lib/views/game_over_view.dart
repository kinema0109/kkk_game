import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class GameOverView extends StatelessWidget {
  const GameOverView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    final winner = game.metadata['winner'] ?? 'UNKNOWN';
    final isGoodWin = winner == 'GOOD';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isGoodWin
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            Colors.black,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGoodWin ? Icons.verified_user_rounded : Icons.dangerous_rounded,
            color: isGoodWin ? Colors.greenAccent : Colors.redAccent,
            size: 100,
          ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            isGoodWin ? 'JUSTICE PREVAILS' : 'THE SHADOWS ESCAPE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isGoodWin ? Colors.greenAccent : Colors.redAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),
          Text(
            isGoodWin
                ? 'The investigators have solved the crime.'
                : 'The murderer has eluded justice.',
            style: const TextStyle(
                color: Colors.white54, fontStyle: FontStyle.italic),
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 32),
          _buildSolutionCard(context, game),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.read<GameProvider>().sendAction('reset_game', {}),
                icon: const Icon(Icons.refresh),
                label: const Text('NEW INVESTIGATION',
                    style: TextStyle(
                        letterSpacing: 1, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isGoodWin ? Colors.green.shade900 : Colors.red.shade900,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 1.5.seconds),
        ],
      ),
    );
  }

  Widget _buildSolutionCard(BuildContext context, GameState game) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text('FINAL REPORT',
              style: TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12)),
          const Divider(
              color: Colors.amberAccent, indent: 40, endIndent: 40, height: 24),
          const Text('The crime was committed using:',
              style: TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (game.meansCard != null)
                _buildCardMini(game.meansCard!, Colors.redAccent),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('&',
                    style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
              if (game.clueCard != null)
                _buildCardMini(game.clueCard!, Colors.blueAccent),
            ],
          ),
          if (game.meansCard == null && game.clueCard == null)
            Text(
              '${game.solutionMeansId} & ${game.solutionClueId}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 1.2.seconds).slideY(begin: 0.1);
  }

  Widget _buildCardMini(Map<String, dynamic> card, Color accentColor) {
    final String name = card['name'] ?? 'Unknown';
    final String? imageUrl = card['image_url'];

    return Column(
      children: [
        Container(
          width: 80,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: accentColor.withValues(alpha: 0.5), width: 2),
            color: Colors.black45,
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null
              ? (imageUrl.startsWith('assets/')
                  ? Image.asset(imageUrl, fit: BoxFit.cover)
                  : Image.network(imageUrl, fit: BoxFit.cover))
              : const Center(
                  child: Icon(Icons.broken_image, color: Colors.white10)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
