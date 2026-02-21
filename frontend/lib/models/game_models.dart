import 'package:collection/collection.dart';

enum GameStatus {
  LOBBY,
  SETUP,
  CARD_DRAFTING,
  CRIME_SELECTION,
  INVESTIGATION,
  WITNESS_IDENTIFICATION,
  GAME_OVER
}

enum Role { FORENSIC_SCIENTIST, MURDERER, INVESTIGATOR, WITNESS, ACCOMPLICE }

class Tile {
  final int id;
  final String title;
  final String type;
  final List<String> options;
  final int? selectedOption;

  Tile({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
    this.selectedOption,
  });

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
      options: (json['options'] as List).cast<String>(),
      selectedOption: json['selected_option'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'options': options,
      'selected_option': selectedOption,
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
  final int? seatIndex;
  final List<String>? meansCards;
  final List<String>? clueCards;
  final bool hasBadge;
  final List<Tile> activeTiles;

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
    this.hasBadge = true,
    this.activeTiles = const [],
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      isHost: json['is_host'] as bool? ?? false,
      isReady: json['is_ready'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? true,
      role: json['role'] != null
          ? Role.values.firstWhereOrNull((e) => e.name == json['role'])
          : null,
      seatIndex: json['seat_index'] as int?,
      meansCards: (json['means_cards'] as List?)?.cast<String>(),
      clueCards: (json['clue_cards'] as List?)?.cast<String>(),
      hasBadge: json['has_badge'] as bool? ?? true,
      activeTiles: (json['active_tiles'] as List?)
              ?.map((t) => Tile.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
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
    this.metadata = const {},
  });

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      roomId: json['room_id'] as String,
      roomCode: json['room_code'] as String? ?? '',
      status:
          GameStatus.values.firstWhereOrNull((e) => e.name == json['status']) ??
              GameStatus.LOBBY,
      round: json['round'] as int? ?? 0,
      players: (json['players'] as List<dynamic>)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      murdererId: json['murderer_id'] as String?,
      solutionMeansId: json['means_id'] as String?,
      solutionClueId: json['clue_id'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
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
      'metadata': metadata,
    };
  }
}
