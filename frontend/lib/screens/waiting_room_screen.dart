import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRIEFING ROOM'),
        actions: [
          IconButton(
            onPressed: () => context.read<GameProvider>().disconnect(),
            icon: const Icon(Icons.logout),
            tooltip: 'ABANDON MISSION',
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          final game = provider.gameState;

          if (game == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoomInfo(context, game),
                const SizedBox(height: 40),
                _buildPlayerCount(context, game),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      return _buildPlayerTile(context, player, index);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionControl(context, game),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomInfo(BuildContext context, GameState game) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SECURE ROOM ACCESS',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(
                game.roomCode,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStatusChip(context, game.status),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildStatusChip(BuildContext context, GameStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name,
        style: const TextStyle(
            color: Colors.amber,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1),
      ),
    );
  }

  Widget _buildPlayerCount(BuildContext context, GameState game) {
    return Row(
      children: [
        const Text('AGENT LIST',
            style: TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
        const Spacer(),
        Text(
          '${game.players.length} / 12',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPlayerTile(BuildContext context, Player player, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: player.isOnline
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
          child: Text(player.name[0].toUpperCase(),
              style: TextStyle(
                  color: player.isOnline ? Colors.green : Colors.red)),
        ),
        title: Text(player.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(player.isOnline ? 'ACTIVE' : 'DISCONNECTED',
            style: const TextStyle(fontSize: 10, letterSpacing: 1)),
        trailing: player.isHost
            ? const Icon(Icons.star, color: Colors.amber, size: 18)
            : player.isReady
                ? const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 18)
                : const Icon(Icons.hourglass_bottom,
                    color: Colors.white10, size: 18),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
  }

  Widget _buildActionControl(BuildContext context, GameState game) {
    final canStart = game.players.length >= 4;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canStart
            ? () => context.read<GameProvider>().sendAction('start_game', {})
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        child: Text(
          canStart
              ? 'COMMENCE OPERATION'
              : 'WAITING FOR REINFORCEMENTS (${4 - game.players.length})',
          style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
      ),
    ).animate(target: canStart ? 1 : 0).shimmer(duration: 2.seconds);
  }
}
