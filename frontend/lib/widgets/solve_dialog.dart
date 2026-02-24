import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class SolveDialog extends StatefulWidget {
  final Player suspect;
  const SolveDialog({super.key, required this.suspect});

  @override
  State<SolveDialog> createState() => _SolveDialogState();
}

class _SolveDialogState extends State<SolveDialog> {
  String? _means;
  String? _clue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ACCUSE ${widget.suspect.name.toUpperCase()}'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Select the exact Means and Clue that prove their guilt:',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 24),
            _buildPicker('POTENTIAL MEANS', widget.suspect.meansCards ?? [],
                _means, (v) => setState(() => _means = v), Colors.redAccent),
            const SizedBox(height: 24),
            _buildPicker('KEY CLUE', widget.suspect.clueCards ?? [], _clue,
                (v) => setState(() => _clue = v), Colors.blueAccent),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: (_means != null && _clue != null)
              ? () {
                  context.read<GameProvider>().sendAction('solve', {
                    'suspect_id': widget.suspect.id,
                    'means_id': _means,
                    'clue_id': _clue,
                  });
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary),
          child: const Text('CERTIFY GUILT'),
        ),
      ],
    );
  }

  Widget _buildPicker(String label, List<Map<String, dynamic>> items,
      String? selected, Function(String) onSelect, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.5,
                color: accentColor)),
        const Divider(color: Colors.white12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((i) {
            final cardId = i['id'].toString();
            final cardName = i['name'] as String;
            final imageUrl = i['image_url'] as String?;
            final isSelected = selected == cardId;

            return GestureDetector(
              onTap: () => onSelect(cardId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 65,
                height: 100,
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : accentColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      imageUrl.startsWith('assets/')
                          ? Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(0.4),
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      size: 20, color: Colors.white10),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(0.4),
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      size: 20, color: Colors.white10),
                            ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 2),
                          color: Colors.black87,
                          child: Text(
                            cardName.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(Icons.check_circle,
                            size: 16, color: accentColor),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
