import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import 'lobby/lobby_widgets.dart';
import 'eldritch_library_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late final TextEditingController _nameController;
  final TextEditingController _roomController = TextEditingController();

  String get _clientId =>
      Supabase.instance.client.auth.currentUser?.id ?? const Uuid().v4();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    final displayName =
        user?.userMetadata?['display_name'] ?? user?.email?.split('@')[0] ?? '';
    _nameController = TextEditingController(text: displayName);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GameProvider>();
      provider.disconnect(); // Clear any stale connection/reconnection state
      provider.fetchLobbyGames();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      body: Stack(
        children: [
          const LobbyBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 960;

                if (isWide) {
                  return Row(
                    children: [
                      Container(
                        width: 380,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          border: const Border(
                              right: BorderSide(color: Colors.white10)),
                        ),
                        child: _buildSidebar(theme),
                      ),
                      Expanded(
                        child: _buildMainDashboard(theme),
                      ),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const MobileLobbyHeader(),
                        _buildForm(theme),
                        const SizedBox(height: 24),
                        _buildRoomList(theme),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LobbyHeader(),
          const SizedBox(height: 60),
          const SectionTitle(
              title: 'OPERATIVE IDENTITY', icon: Icons.security_rounded),
          const SizedBox(height: 24),
          LobbyTextField(
            controller: _nameController,
            label: 'CODENAME',
            icon: Icons.fingerprint,
          ),
          const SizedBox(height: 24),
          LobbyTextField(
            controller: _roomController,
            label: 'DIRECT FREQUENCY',
            icon: Icons.wifi_tethering,
            hint: '6-DIGIT INTEL CODE',
          ),
          const SizedBox(height: 48),
          _buildActionButtons(),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EldritchLibraryScreen()),
            ),
            icon: const Icon(Icons.auto_stories_rounded, color: Colors.white70),
            label: Text(
              'ELDRITCH ARCHIVES',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 48),
          const LogoutLink(),
        ],
      ),
    );
  }

  Widget _buildMainDashboard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDashboardTopBar(theme),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                    title: 'LIVE INTEL FEED', icon: Icons.sensors_rounded),
                const SizedBox(height: 24),
                Expanded(
                  child: Consumer<GameProvider>(
                    builder: (context, provider, child) {
                      if (provider.fetchingGames) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final Map<String, dynamic> uniqueGames = {};
                      for (var g in provider.myGames) {
                        uniqueGames[g['room_code']] = g;
                      }
                      for (var g in provider.publicGames) {
                        if (!uniqueGames.containsKey(g['room_code'])) {
                          uniqueGames[g['room_code']] = g;
                        }
                      }
                      final allGames = uniqueGames.values.toList();

                      if (allGames.isEmpty) {
                        return const EmptyStateSignal();
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              (constraints.maxWidth / 300).floor().clamp(1, 4);
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1.4,
                            ),
                            itemCount: allGames.length,
                            itemBuilder: (context, index) {
                              final game = allGames[index];
                              final isJoined = provider.myGames.any(
                                  (g) => g['room_code'] == game['room_code']);
                              return MetricRoomTile(
                                game: game,
                                isJoined: isJoined,
                                onTap: provider.isConnecting
                                    ? null
                                    : () {
                                        if (_nameController.text.isNotEmpty) {
                                          provider.joinRoom(
                                            game['room_code'],
                                            _nameController.text,
                                            _clientId,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'IDENTIFY YOURSELF FIRST')),
                                          );
                                        }
                                      },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTopBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Text(
            'FIELD OPERATIONS COMMAND',
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 4,
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Consumer<GameProvider>(
            builder: (context, provider, child) {
              return HeaderMetric(
                label: 'ACTIVE SIGNALS',
                value: provider.publicGames.length.toString(),
                color: theme.colorScheme.primary,
              );
            },
          ),
          const SizedBox(width: 48),
          Consumer<GameProvider>(
              builder: (context, provider, child) =>
                  _buildRefreshButton(provider)),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(GameProvider provider) {
    return IconButton(
      icon: const Icon(Icons.sync, size: 20),
      onPressed:
          provider.fetchingGames ? null : () => provider.fetchLobbyGames(),
    )
        .animate(target: provider.fetchingGames ? 1 : 0)
        .rotate(duration: 1.seconds);
  }

  Widget _buildRoomList(ThemeData theme) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final Map<String, dynamic> uniqueGames = {};
        for (var g in provider.myGames) {
          uniqueGames[g['room_code']] = g;
        }
        for (var g in provider.publicGames) {
          if (!uniqueGames.containsKey(g['room_code'])) {
            uniqueGames[g['room_code']] = g;
          }
        }
        final allGames = uniqueGames.values.toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'INTEL FEED', icon: Icons.rss_feed),
              const SizedBox(height: 16),
              if (allGames.isEmpty)
                const EmptyStateSignal()
              else
                ...allGames.map((game) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MetricRoomTile(
                        game: game,
                        isJoined: provider.myGames
                            .any((g) => g['room_code'] == game['room_code']),
                        onTap: provider.isConnecting
                            ? null
                            : () {
                                if (_nameController.text.isNotEmpty) {
                                  provider.joinRoom(
                                    game['room_code'],
                                    _nameController.text,
                                    _clientId,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('IDENTIFY YOURSELF FIRST')),
                                  );
                                }
                              },
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'OPERATIVE IDENTITY', icon: Icons.security),
          const SizedBox(height: 24),
          LobbyTextField(
              controller: _nameController,
              label: 'CODENAME',
              icon: Icons.fingerprint),
          const SizedBox(height: 16),
          LobbyTextField(
              controller: _roomController,
              label: 'DIRECT FREQUENCY',
              icon: Icons.sensors),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            PrimaryActionButton(
              onPressed: provider.isConnecting
                  ? null
                  : () {
                      if (_nameController.text.isNotEmpty &&
                          _roomController.text.isNotEmpty) {
                        provider.joinRoom(_roomController.text.toUpperCase(),
                            _nameController.text, _clientId);
                      }
                    },
              isLoading: provider.isConnecting,
              label: 'JOIN SESSION',
            ),
            const SizedBox(height: 16),
            SecondaryActionButton(
              onPressed: provider.isConnecting
                  ? null
                  : () {
                      if (_nameController.text.isNotEmpty) {
                        provider.createRoom(_nameController.text, _clientId);
                      }
                    },
              label: 'CREATE NEW MISSION',
            ),
          ],
        );
      },
    );
  }
}
