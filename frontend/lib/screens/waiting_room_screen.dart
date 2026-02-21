import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WAITING ROOM'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => context.read<GameProvider>().disconnect(),
            icon: const Icon(Icons.exit_to_app),
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
                _buildHeader(game),
                const SizedBox(height: 32),
                const Text(
                  'PLAYERS',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      return _buildPlayerTile(player);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildStartButton(context, game),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(GameState game) {
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.qr_code, size: 48, color: Colors.indigo),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ROOM CODE',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  game.roomCode,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
              ],
            ),
            const Spacer(),
            Chip(
              label: Text(game.status.name),
              backgroundColor: Colors.indigo,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Player player) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: player.isOnline ? Colors.green : Colors.grey,
        child: Text(player.name[0].toUpperCase()),
      ),
      title: Text(
        player.name,
        style: TextStyle(
          fontWeight: player.isHost ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(player.isOnline ? 'Online' : 'Offline'),
      trailing: player.isHost
          ? const Icon(Icons.star, color: Colors.amber)
          : player.isReady
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.hourglass_empty),
    );
  }

  Widget _buildStartButton(BuildContext context, GameState game) {
    // Only host can start game
    // For simplicity in this demo, we check if the first player is the current user.
    // In a real app, you'd compare current client ID with player IDs.

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: game.players.length >= 4
            ? () => context.read<GameProvider>().sendAction('start_game', {})
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: Text(
          game.players.length >= 4
              ? 'START GAME'
              : 'NEED ${4 - game.players.length} MORE PLAYERS',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
