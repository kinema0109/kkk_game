import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/game_models.dart';
import '../widgets/solve_dialog.dart';
import '../l10n/app_localizations.dart';

class SuspectHandView extends StatelessWidget {
  final GameState game;
  const SuspectHandView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selfPlayer = game.players.firstWhereOrNull((p) => p.isMe);
    final isSelfFS = selfPlayer?.role == Role.FORENSIC_SCIENTIST;
    final suspects =
        game.players.where((p) => p.role != Role.FORENSIC_SCIENTIST).toList();

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return _buildHorizontalLayout(
            context, suspects, l10n, isSelfFS, selfPlayer);
      }
      return _buildVerticalLayout(
          context, suspects, l10n, isSelfFS, selfPlayer);
    });
  }

  Widget _buildVerticalLayout(BuildContext context, List<Player> suspects,
      AppLocalizations l10n, bool isSelfFS, Player? selfPlayer) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.people, size: 16, color: Colors.white24),
              const SizedBox(width: 8),
              Text(
                l10n.suspectDossiers.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: suspects.length,
            itemBuilder: (context, index) {
              final p = suspects[index];
              return _buildSuspectCard(context, p, l10n, isSelfFS, selfPlayer,
                  key: ValueKey(p.id));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, List<Player> suspects,
      AppLocalizations l10n, bool isSelfFS, Player? selfPlayer) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      itemCount: suspects.length,
      itemBuilder: (context, index) {
        final p = suspects[index];
        return Container(
          width: 380,
          margin: const EdgeInsets.only(right: 16),
          child: _buildSuspectDashboardCard(
              context, p, l10n, isSelfFS, selfPlayer,
              key: ValueKey(p.id)),
        );
      },
    );
  }

  Widget _buildSuspectDashboardCard(BuildContext context, Player p,
      AppLocalizations l10n, bool isSelfFS, Player? selfPlayer,
      {Key? key}) {
    return Card(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: const Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                if (p.avatarUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(p.avatarUrl!),
                    ),
                  )
                else
                  const Icon(Icons.person, size: 16, color: Colors.white24),
                const SizedBox(width: 8),
                Text(
                  p.name.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                if (p.role != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(p.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _getRoleColor(p.role).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _getRoleLabel(p.role!, l10n).toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(p.role),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardSection(context, l10n.potentialMeans,
                      p.meansCards ?? [], Colors.red),
                  const SizedBox(height: 16),
                  _buildCardSection(
                      context, l10n.keyClues, p.clueCards ?? [], Colors.blue),
                ],
              ),
            ),
          ),
          if (game.status == GameStatus.INVESTIGATION &&
              !isSelfFS &&
              (selfPlayer?.hasBadge ?? false))
            _buildSolveButton(context, p, l10n),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context, String label,
      List<Map<String, dynamic>> cards, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 10, color: accent),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: accent.withValues(alpha: 0.7),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (cards.isEmpty && game.status == GameStatus.CARD_DRAFTING)
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Center(
              child: Text(
                'DRAFTING...',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: accent.withValues(alpha: 0.3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: cards.map((c) => _buildCardItem(c, accent)).toList(),
          ),
      ],
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, Color accent) {
    final name = card['name'] as String? ?? 'Unknown';
    final imageUrl = card['image_url'] as String?;

    return Container(
      width: 62,
      height: 90,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.startsWith('assets/'))
            Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(1.0),
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.broken_image,
                    size: 20, color: accent.withValues(alpha: 0.3)),
              ),
            )
          else
            Image.network(
              imageUrl ?? 'https://placehold.co/62x100?text=?',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(1.0),
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.broken_image,
                    size: 20, color: accent.withValues(alpha: 0.3)),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(4)),
                ),
                child: Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolveButton(
      BuildContext context, Player suspect, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _showSolveDialog(context, suspect),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5)),
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(l10n.solveAction,
              style: const TextStyle(
                  letterSpacing: 2, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSuspectCard(BuildContext context, Player p,
      AppLocalizations l10n, bool isSelfFS, Player? selfPlayer,
      {Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage:
              p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
          child: p.avatarUrl == null ? Text(p.name[0].toUpperCase()) : null,
        ),
        title: Row(
          children: [
            Text(
              p.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            if (p.role != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRoleColor(p.role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: _getRoleColor(p.role).withValues(alpha: 0.3)),
                ),
                child: Text(
                  _getRoleLabel(p.role!, l10n).toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: _getRoleColor(p.role),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          l10n.equippedWith(
              p.clueCards?.length ?? 0, p.meansCards?.length ?? 0),
          style: const TextStyle(fontSize: 10, color: Colors.white38),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandRow(context, l10n.potentialMeans, p.meansCards ?? [],
                    Colors.redAccent),
                const SizedBox(height: 16),
                _buildHandRow(context, l10n.keyClues, p.clueCards ?? [],
                    Colors.blueAccent),
                const SizedBox(height: 20),
                if (game.status == GameStatus.INVESTIGATION &&
                    !isSelfFS &&
                    (selfPlayer?.hasBadge ?? false))
                  _buildSolveButton(context, p, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandRow(BuildContext context, String label,
      List<Map<String, dynamic>> cards, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: accentColor.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 8),
        if (cards.isEmpty && game.status == GameStatus.CARD_DRAFTING)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accentColor.withValues(alpha: 0.1)),
            ),
            child: const Text('DRAFTING...',
                style: TextStyle(fontSize: 10, color: Colors.white24)),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: cards
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(c['name'] as String? ?? '?',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70)),
                    ))
                .toList(),
          ),
      ],
    );
  }

  void _showSolveDialog(BuildContext context, Player suspect) {
    showDialog(
      context: context,
      builder: (context) => SolveDialog(suspect: suspect),
    );
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
}
