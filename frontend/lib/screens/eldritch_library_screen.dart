import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/dynamic_card_template.dart';

class EldritchLibraryScreen extends StatefulWidget {
  const EldritchLibraryScreen({super.key});

  @override
  State<EldritchLibraryScreen> createState() => _EldritchLibraryScreenState();
}

class _EldritchLibraryScreenState extends State<EldritchLibraryScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  int _page = 0;
  static const int _pageSize = 20;

  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  Timer? _searchTimer;

  final List<String> _categories = [
    'ALL',
    'INVESTIGATOR',
    'WEAPON',
    'ITEM',
    'ALLY',
    'SERVICE',
    'SPELL',
    'CONDITION',
    'ANCIENT_ONE',
    'LOCATION',
    'RESEARCH',
    'OTHER_WORLD',
    'EXPEDITION'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCards(reset: true);
  }

  Future<void> _fetchCards({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _page = 0;
        _cards = [];
        _hasMore = true;
      });
    } else {
      if (!_hasMore || _isMoreLoading) return;
      setState(() => _isMoreLoading = true);
    }

    try {
      final startIndex = _page * _pageSize;
      final endIndex = startIndex + _pageSize - 1;

      var query = _supabase
          .from('library_cards')
          .select()
          .eq('game_type', 'eldritch_horror');

      // 4x4 Filter Mapping
      if (_selectedCategory != 'ALL') {
        const assetSubTypes = ['WEAPON', 'ITEM', 'ALLY', 'SERVICE'];
        const encounterSubTypes = [
          'LOCATION_ENCOUNTER',
          'RESEARCH_ENCOUNTER',
          'OTHER_WORLD_ENCOUNTER',
          'EXPEDITION_ENCOUNTER'
        ];

        String mappedCat = _selectedCategory;
        if (_selectedCategory == 'LOCATION') mappedCat = 'LOCATION_ENCOUNTER';
        if (_selectedCategory == 'RESEARCH') mappedCat = 'RESEARCH_ENCOUNTER';
        if (_selectedCategory == 'OTHER_WORLD')
          mappedCat = 'OTHER_WORLD_ENCOUNTER';
        if (_selectedCategory == 'EXPEDITION')
          mappedCat = 'EXPEDITION_ENCOUNTER';

        if (assetSubTypes.contains(mappedCat)) {
          query = query.eq('type', 'ITEM').eq('metadata->>sub_type', mappedCat);
        } else if (encounterSubTypes.contains(mappedCat)) {
          query = query
              .eq('type', 'ENCOUNTER')
              .eq('metadata->>sub_type', mappedCat);
        } else {
          query = query.eq('type', mappedCat);
        }
      }

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('content', '%$_searchQuery%');
      }

      final response = await query.order('content').range(startIndex, endIndex);

      final List<Map<String, dynamic>> newCards =
          List<Map<String, dynamic>>.from(response as List);

      setState(() {
        if (reset) {
          _cards = newCards;
          _isLoading = false;
        } else {
          _cards.addAll(newCards);
          _isMoreLoading = false;
        }
        _hasMore = newCards.length >= _pageSize;
        _page++;
      });
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      setState(() {
        _isLoading = false;
        _isMoreLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('ELDRITCH ARCHIVES'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchCards(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (v) {
                _searchTimer?.cancel();
                _searchTimer = Timer(const Duration(milliseconds: 500), () {
                  setState(() => _searchQuery = v);
                  _fetchCards(reset: true);
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search artifacts, spells, investigators...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: Colors.tealAccent.shade400,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                      _fetchCards(reset: true);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final typeStr = card['type'].toString();

                      // Map database type to DynamicCardTemplate type
                      CardType templateType = CardType.item;
                      if (typeStr == 'SPELL') templateType = CardType.spell;
                      if (typeStr == 'CONDITION')
                        templateType = CardType.condition;
                      if (typeStr == 'ENCOUNTER')
                        templateType = CardType.encounter;
                      if (typeStr == 'INVESTIGATOR') {
                        templateType = CardType.investigator;
                      }
                      if (typeStr == 'ANCIENT_ONE') {
                        templateType = CardType.ancient_one;
                      }

                      return GestureDetector(
                        onTap: () => _showCardDetail(card, templateType),
                        child: Hero(
                          tag: 'card_${card['id']}',
                          child: Transform.scale(
                            scale: 0.9,
                            child: _buildCardPreview(card, templateType),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_hasMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: _isMoreLoading
                            ? const CircularProgressIndicator()
                            : TextButton.icon(
                                onPressed: () => _fetchCards(),
                                icon: const Icon(Icons.add,
                                    color: Colors.tealAccent),
                                label: const Text(
                                  'LOAD MORE ARTIFACTS',
                                  style: TextStyle(color: Colors.tealAccent),
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardPreview(Map<String, dynamic> card, CardType type) {
    final imageUrl = card['image_url'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white10),
        ),
      );
    }

    final metadata = card['metadata'] as Map<String, dynamic>? ?? {};
    return DynamicCardTemplate(
      title: card['content'] ?? 'Unnamed Card',
      content: metadata['description'] ?? 'No description available.',
      metadata: metadata,
      type: type,
    );
  }

  void _showCardDetail(Map<String, dynamic> card, CardType type) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (card['image_url'] != null)
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Image.network(
                    card['image_url'],
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                )
              else
                _buildCardPreview(card, type),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
