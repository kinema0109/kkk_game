import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';

class LobbyBackground extends StatelessWidget {
  const LobbyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F0F),
            Color(0xFF050505),
          ],
        ),
      ),
    );
  }
}

class LobbyHeader extends StatelessWidget {
  final String title;
  const LobbyHeader({super.key, this.title = 'MANAGER GAME'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.security, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            letterSpacing: 8,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class LobbyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;

  const LobbyTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9, letterSpacing: 2, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: Colors.black26,
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white12),
                borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const PrimaryActionButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return HoverActionWrapper(
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : Text(label,
                  style: const TextStyle(
                      letterSpacing: 2, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const SecondaryActionButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return HoverActionWrapper(
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label,
              style: const TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

class MetricRoomTile extends StatelessWidget {
  final Map<String, dynamic> game;
  final bool isJoined;
  final VoidCallback? onTap;

  const MetricRoomTile({
    super.key,
    required this.game,
    required this.isJoined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverActionWrapper(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isJoined
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isJoined
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isJoined ? theme.colorScheme.primary : Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      game['room_code'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isJoined ? Colors.black : Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isJoined)
                    Icon(Icons.link,
                        size: 16, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                game['name'] ?? 'CLASSIFIED MISSION',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildSmallStat(
                      Icons.people_outline, '${game['player_count']}'),
                  const SizedBox(width: 16),
                  _buildSmallStat(Icons.videogame_asset_outlined,
                      (game['game_type'] ?? 'DECEPTION').toUpperCase()),
                  const Spacer(),
                  Icon(Icons.arrow_forward,
                      size: 16,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildSmallStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class HeaderMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const HeaderMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 8, letterSpacing: 2, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1.2)),
      ],
    );
  }
}

class EmptyStateSignal extends StatelessWidget {
  const EmptyStateSignal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar_rounded,
              size: 64, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 24),
          const Text('SCANNING FOR SIGNALS...',
              style: TextStyle(
                  letterSpacing: 4, color: Colors.white24, fontSize: 12)),
          const SizedBox(height: 12),
          const Text('NO ACTIVE MISSIONS IN SECTOR',
              style: TextStyle(color: Colors.white10, fontSize: 10)),
        ],
      ),
    );
  }
}

class LogoutLink extends StatelessWidget {
  const LogoutLink({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverActionWrapper(
      scale: 1.02,
      child: InkWell(
        onTap: () => context.read<AuthProvider>().signOut(),
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withOpacity(0.05),
        splashColor: Colors.redAccent.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.power_settings_new,
                  size: 18, color: Colors.redAccent),
              const SizedBox(width: 12),
              Text(
                'TERMINATE SESSION',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileLobbyHeader extends StatelessWidget {
  final String title;
  const MobileLobbyHeader({super.key, this.title = 'MANAGER GAME'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(Icons.security, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(letterSpacing: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class HoverActionWrapper extends StatefulWidget {
  final Widget child;
  final double scale;

  const HoverActionWrapper({
    super.key,
    required this.child,
    this.scale = 1.03,
  });

  @override
  State<HoverActionWrapper> createState() => _HoverActionWrapperState();
}

class _HoverActionWrapperState extends State<HoverActionWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
