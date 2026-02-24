import 'package:collection/collection.dart';

enum GameStatus {
  LOBBY,
  SETUP,
  CARD_DRAFTING,
  CRIME_SELECTION,
  FORENSIC_SETUP,
  INVESTIGATION,
  WITNESS_IDENTIFICATION,
  GAME_OVER
}

enum Role { FORENSIC_SCIENTIST, MURDERER, INVESTIGATOR, WITNESS, ACCOMPLICE }

class Tile {
  final String id;
  final String title;
  final String type;
  final List<String> options;
  final int? selectedOption;
  final String? imageUrl;

  Tile({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
    this.selectedOption,
    this.imageUrl,
  });

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      id: json['id'].toString(),
      title: json['title'] as String,
      type: json['type'] as String,
      options: (json['options'] as List).cast<String>(),
      selectedOption: json['selected_option'] as int?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'options': options,
      'selected_option': selectedOption,
      'image_url': imageUrl,
    };
  }
}

class Player {
  final String id;
  final String name;
  final bool isHost;
  final bool isReady;
  final bool isOnline;
  final Role? role;
  final bool isMe;
  final int? seatIndex;
  final List<Map<String, dynamic>>? meansCards;
  final List<Map<String, dynamic>>? clueCards;
  final List<Map<String, dynamic>>? draftMeans;
  final List<Map<String, dynamic>>? draftClues;
  final bool hasBadge;
  final bool hasDrafted;
  final int tilesReplaced;
  final List<Tile> activeTiles;
  final String? avatarUrl;

  Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.isReady = false,
    this.isOnline = true,
    this.role,
    this.seatIndex,
    this.meansCards,
    this.clueCards,
    this.draftMeans,
    this.draftClues,
    this.hasBadge = true,
    this.hasDrafted = false,
    this.tilesReplaced = 0,
    this.activeTiles = const [],
    this.avatarUrl,
    this.isMe = false,
  });

  factory Player.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final metadata = (json['metadata'] as Map<String, dynamic>?) ?? {};
    final id = json['id'] as String;
    return Player(
      id: id,
      name: json['name'] as String,
      isHost: json['is_host'] as bool? ?? false,
      isReady: json['is_ready'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? true,
      isMe: id == currentUserId,
      role: metadata['role'] != null
          ? Role.values.firstWhereOrNull((e) => e.name == metadata['role'])
          : null,
      seatIndex: metadata['seat_index'] as int?,
      meansCards:
          (metadata['means_cards'] as List?)?.cast<Map<String, dynamic>>(),
      clueCards:
          (metadata['clue_cards'] as List?)?.cast<Map<String, dynamic>>(),
      draftMeans:
          (metadata['draft_means'] as List?)?.cast<Map<String, dynamic>>(),
      draftClues:
          (metadata['draft_clues'] as List?)?.cast<Map<String, dynamic>>(),
      hasBadge: metadata['has_badge'] as bool? ?? true,
      hasDrafted: metadata['has_drafted'] as bool? ?? false,
      tilesReplaced: metadata['tiles_replaced'] as int? ?? 0,
      activeTiles: (metadata['active_tiles'] as List?)
              ?.map((t) => Tile.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      avatarUrl: metadata['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_host': isHost,
      'is_ready': isReady,
      'is_online': isOnline,
      'role': role?.name,
      'seat_index': seatIndex,
      'means_cards': meansCards,
      'clue_cards': clueCards,
      'has_badge': hasBadge,
      'active_tiles': activeTiles.map((t) => t.toJson()).toList(),
    };
  }
}

class GameState {
  final String roomId;
  final String roomCode;
  final GameStatus status;
  final int round;
  final List<Player> players;
  final String? murdererId;
  final String? solutionMeansId;
  final String? solutionClueId;
  final Map<String, dynamic>? meansCard;
  final Map<String, dynamic>? clueCard;
  final Map<String, dynamic> metadata;

  GameState({
    required this.roomId,
    required this.roomCode,
    required this.status,
    required this.round,
    required this.players,
    this.murdererId,
    this.solutionMeansId,
    this.solutionClueId,
    this.meansCard,
    this.clueCard,
    this.metadata = const {},
  });

  factory GameState.fromJson(Map<String, dynamic> json,
      {String? currentUserId}) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return GameState(
      roomId: json['room_id'] as String,
      roomCode: json['room_code'] as String? ?? '',
      status:
          GameStatus.values.firstWhereOrNull((e) => e.name == json['status']) ??
              GameStatus.LOBBY,
      round: data['round'] as int? ?? 0,
      players: (json['players'] as List<dynamic>)
          .map((p) => Player.fromJson(p as Map<String, dynamic>,
              currentUserId: currentUserId))
          .toList(),
      murdererId: data['murderer_id'] as String?,
      solutionMeansId: data['means_id'] as String?,
      solutionClueId: data['clue_id'] as String?,
      meansCard: data['means_card'] as Map<String, dynamic>?,
      clueCard: data['clue_card'] as Map<String, dynamic>?,
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'room_code': roomCode,
      'status': status.name,
      'round': round,
      'players': players.map((p) => p.toJson()).toList(),
      'murderer_id': murdererId,
      'means_id': solutionMeansId,
      'clue_id': solutionClueId,
      'means_card': meansCard,
      'clue_card': clueCard,
      'metadata': metadata,
    };
  }
}
