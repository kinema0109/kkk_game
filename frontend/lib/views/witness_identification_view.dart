import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class WitnessIdentificationView extends StatelessWidget {
  const WitnessIdentificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    // Placeholder for self detection
    final player = game.players[0];
    final isMurderer = player.role == Role.MURDERER;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent, size: 64)
              .animate()
              .shake(hz: 3),
          const SizedBox(height: 24),
          const Text(
            'CASE SOLVED',
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            isMurderer
                ? 'YOU HAVE BEEN EXPOSED. IDENTIFY THE WITNESS TO SECURE YOUR ESCAPE!'
                : 'THE CRIME HAS BEEN SOLVED. WAITING FOR THE MURDERER\'S LAST STAND...',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                fontSize: 13),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 40),
          if (isMurderer)
            Expanded(
              child: ListView.separated(
                itemCount: game.players.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = game.players[index];
                  if (p.role == Role.FORENSIC_SCIENTIST ||
                      p.role == Role.MURDERER) {
                    return const SizedBox.shrink();
                  }
                  return _buildTargetTile(context, p);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTargetTile(BuildContext context, Player target) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        onTap: () => _confirmIdentification(context, target),
        leading: const Icon(Icons.person_search, color: Colors.amberAccent),
        title: Text(target.name,
            style:
                const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 12, color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1);
  }

  void _confirmIdentification(BuildContext context, Player target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('EXPOSE ${target.name}?'),
        content: const Text(
            'Are you certain this individual is the Witness? If you fail, the Investigation wins.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ABORT')),
          ElevatedButton(
            onPressed: () {
              context
                  .read<GameProvider>()
                  .sendAction('identify_witness', {'target_id': target.id});
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
            child: const Text('CONFIRM EXPOSURE'),
          ),
        ],
      ),
    );
  }
}
