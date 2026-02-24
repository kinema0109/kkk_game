import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/game_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/lobby_screen.dart';
import 'screens/waiting_room_screen.dart';
import 'screens/game_screen.dart';
import 'screens/auth_screen.dart';
import 'models/game_models.dart';
import 'theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
    final provider = context.watch<GameProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deception: Manager Game',
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: provider.locale,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const AuthScreen();
    }

    return const GameWrapper();
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
