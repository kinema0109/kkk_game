import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/lobby_screen.dart';
import 'screens/waiting_room_screen.dart';
import 'screens/game_screen.dart';
import 'models/game_models.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deception: Murder in Hong Kong',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const GameWrapper(),
    );
  }
}

class GameWrapper extends StatelessWidget {
  const GameWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected || provider.gameState == null) {
          return const LobbyScreen();
        }

        final status = provider.gameState!.status;

        // Route based on game status
        if (status == GameStatus.LOBBY || status == GameStatus.SETUP) {
          return const WaitingRoomScreen();
        } else {
          return const GameScreen();
        }
      },
    );
  }
}
