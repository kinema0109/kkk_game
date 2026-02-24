import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/role_header.dart';
import '../views/drafting_view.dart';
import '../views/crime_selection_view.dart';
import '../views/investigation_view.dart';
import '../views/witness_identification_view.dart';
import '../views/game_over_view.dart';
import '../views/suspect_hand_view.dart';
import '../l10n/app_localizations.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final game = provider.gameState;
        if (game == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout(game, l10n);
          }
          return _buildMobileLayout(game, l10n);
        });
      },
    );
  }

  Widget _buildMobileLayout(GameState game, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.language),
          onPressed: () {
            final provider = context.read<GameProvider>();
            final newLocale = provider.locale.languageCode == 'en'
                ? const Locale('vi')
                : const Locale('en');
            provider.setLocale(newLocale);
          },
        ),
        title: Text(_getStatusLabel(game.status, l10n)),
        actions: [
          IconButton(
            onPressed: () => context.read<GameProvider>().disconnect(),
            icon: const Icon(Icons.logout),
            tooltip: l10n.abandonMission,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.action, icon: const Icon(Icons.flash_on, size: 20)),
            Tab(
                text: l10n.dossiers,
                icon: const Icon(Icons.description, size: 20)),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMainView(game, l10n),
          SuspectHandView(game: game),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(GameState game, AppLocalizations l10n) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar: Unit Roster
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              border: const Border(right: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    l10n.unitRoster,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final p = game.players[index];
                      final isSelf =
                          p.id == context.read<GameProvider>().lastClientId;
                      return _buildPlayerTile(p, isSelf, l10n);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    onPressed: () => context.read<GameProvider>().disconnect(),
                    icon: const Icon(Icons.logout, size: 16),
                    label: Text(l10n.abandonMission),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Body
          Expanded(
            child: Column(
              children: [
                // Dashboard Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    border:
                        const Border(bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.status == GameStatus.INVESTIGATION
                                ? l10n.hoSoPhapY
                                : '${l10n.dossier.toUpperCase()}: ${_getStatusLabel(game.status, l10n)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.phaseRound}: ${game.round} / 3',
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.language, color: Colors.white38),
                        onPressed: () {
                          final provider = context.read<GameProvider>();
                          final newLocale = provider.locale.languageCode == 'en'
                              ? const Locale('vi')
                              : const Locale('en');
                          provider.setLocale(newLocale);
                        },
                      ),
                    ],
                  ),
                ),
                // Main Workspace
                Expanded(
                  child: Row(
                    children: [
                      // Investigation Scene
                      Expanded(
                        flex: 2,
                        child: _getPhaseView(game, l10n),
                      ),
                      // Suspect Hand Shelf (Visible on side or bottom depending on preference)
                      // For now, let's keep it in a scrollable bottom or side panel
                    ],
                  ),
                ),
                // Bottom Suspect Hand Shelf
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: SuspectHandView(game: game),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(Player p, bool isSelf, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelf
            ? Colors.blue.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.02),
        border: Border.all(
          color: isSelf ? Colors.blue.withValues(alpha: 0.3) : Colors.white10,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isSelf ? Colors.blue : Colors.white24,
            backgroundImage:
                p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
            child: p.avatarUrl == null
                ? Text(
                    p.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSelf ? '${p.name} (${l10n.you})' : p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                    color: isSelf ? Colors.blue : Colors.white70,
                  ),
                ),
                if (p.role != null)
                  Text(
                    _getRoleLabel(p.role!, l10n).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      color: _getRoleColor(p.role).withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          if (p.isOnline)
            const Icon(Icons.circle, size: 8, color: Colors.greenAccent)
          else
            const Icon(Icons.circle_outlined, size: 8, color: Colors.white10),
        ],
      ),
    );
  }

  String _getRoleLabel(Role role, AppLocalizations l10n) {
    switch (role) {
      case Role.FORENSIC_SCIENTIST:
        return l10n.roleForensicScientist;
      case Role.MURDERER:
        return l10n.roleMurderer;
      case Role.INVESTIGATOR:
        return l10n.roleInvestigator;
      case Role.WITNESS:
        return l10n.roleWitness;
      case Role.ACCOMPLICE:
        return l10n.roleAccomplice;
    }
  }

  Color _getRoleColor(Role? role) {
    switch (role) {
      case Role.MURDERER:
      case Role.ACCOMPLICE:
        return Colors.redAccent;
      case Role.WITNESS:
        return Colors.blueAccent;
      case Role.FORENSIC_SCIENTIST:
        return Colors.purpleAccent;
      case Role.INVESTIGATOR:
        return Colors.greenAccent;
      default:
        return Colors.amber;
    }
  }

  String _getStatusLabel(GameStatus status, AppLocalizations l10n) {
    switch (status) {
      case GameStatus.LOBBY:
        return l10n.statusLobby;
      case GameStatus.SETUP:
        return l10n.statusSetup;
      case GameStatus.CARD_DRAFTING:
        return l10n.statusCardDrafting;
      case GameStatus.CRIME_SELECTION:
        return l10n.statusCrimeSelection;
      case GameStatus.FORENSIC_SETUP:
        return l10n.statusForensicSetup;
      case GameStatus.INVESTIGATION:
        return l10n.statusInvestigation;
      case GameStatus.WITNESS_IDENTIFICATION:
        return l10n.statusWitnessIdentification;
      case GameStatus.GAME_OVER:
        return l10n.statusGameOver;
    }
  }

  Widget _buildMainView(GameState game, AppLocalizations l10n) {
    final player = game.players.firstWhereOrNull((p) => p.isMe);
    if (player == null) return const SizedBox.shrink();

    return Column(
      children: [
        RoleHeader(player: player),
        Expanded(
          child: _getPhaseView(game, l10n),
        ),
      ],
    );
  }

  Widget _getPhaseView(GameState game, AppLocalizations l10n) {
    switch (game.status) {
      case GameStatus.CARD_DRAFTING:
        return const DraftingView();
      case GameStatus.CRIME_SELECTION:
        return const CrimeSelectionView();
      case GameStatus.FORENSIC_SETUP:
        return const InvestigationView(isForensicSetup: true);
      case GameStatus.INVESTIGATION:
        return const InvestigationView();
      case GameStatus.WITNESS_IDENTIFICATION:
        return const WitnessIdentificationView();
      case GameStatus.GAME_OVER:
        return const GameOverView();
      case GameStatus.LOBBY:
      case GameStatus.SETUP:
        return Center(
          child: Text(
            'PHASE: ${game.status.name}\nSYSTEM INITIALIZING...',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white24, letterSpacing: 2),
          ),
        );
    }
  }
}
