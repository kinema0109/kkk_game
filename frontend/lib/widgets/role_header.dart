import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_models.dart';
import '../l10n/app_localizations.dart';

class RoleHeader extends StatelessWidget {
  final Player player;

  const RoleHeader({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
        border: Border(
          bottom: BorderSide(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.yourIdentity.toUpperCase(),
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (player.avatarUrl != null)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(player.avatarUrl!),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      _getRoleColor(player.role).withValues(alpha: 0.2),
                  child: Text(
                    player.name[0].toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(player.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Text(
                (player.role != null
                        ? _getRoleLabel(player.role!, l10n)
                        : 'UNKNOWN')
                    .toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(player.role),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: _getRoleColor(player.role).withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 1000.ms)
              .scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
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
