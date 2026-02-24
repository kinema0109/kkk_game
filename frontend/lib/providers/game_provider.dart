import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_models.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  GameState? _gameState;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _error;
  StreamSubscription? _subscription;
  Locale _locale = const Locale('en');

  List<dynamic> _publicGames = [];
  List<dynamic> _myGames = [];
  bool _fetchingGames = false;

  String? _lastRoomId;
  String? _lastClientId;
  String? _lastPlayerName;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _shouldReconnect = false;

  GameState? get gameState => _gameState;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  List<dynamic> get publicGames => _publicGames;
  List<dynamic> get myGames => _myGames;
  bool get fetchingGames => _fetchingGames;
  String? get lastClientId => _lastClientId;
  Locale get locale => _locale;

  void setLocale(Locale l) {
    _locale = l;
    notifyListeners();
  }

  Future<void> fetchLobbyGames() async {
    _fetchingGames = true;
    notifyListeners();
    try {
      final res = await ApiService.listGames();
      _publicGames = res['public_games'] ?? [];
      _myGames = res['my_games'] ?? [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _fetchingGames = false;
      notifyListeners();
    }
  }

  Future<void> createRoom(String playerName, String clientId,
      {bool isPublic = true}) async {
    _isConnecting = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.createGame(name: null, isPublic: isPublic);
      final roomId = res['game_id'];
      await connect(roomId, clientId, playerName);
    } catch (e) {
      _isConnecting = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> joinRoom(
      String roomCode, String playerName, String clientId) async {
    _isConnecting = true;
    _error = null;
    notifyListeners();

    try {
      final res =
          await ApiService.joinGame(roomCode: roomCode, name: playerName);
      final roomId = res['game_id'];
      await connect(roomId, clientId, playerName);
    } catch (e) {
      _isConnecting = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> connect(
      String roomId, String clientId, String playerName) async {
    if (_isConnecting && _lastRoomId == roomId) return;

    // Close existing connection and subscription
    _shouldReconnect = false;
    await _subscription?.cancel();
    await _channel?.sink.close();

    _lastRoomId = roomId;
    _lastClientId = clientId;
    _lastPlayerName = playerName;

    _isConnecting = true;
    _error = null;
    _shouldReconnect = true;
    notifyListeners();

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken ?? '';

      // Robustness: Backend requires clientId to match the sub claim in JWT Token
      final finalClientId = session?.user.id ?? clientId;

      // If no token in debug, you might want a fallback or error
      if (token.isEmpty && !kDebugMode) {
        throw Exception("No authentication session found");
      }

      final uri = Uri.parse(
          'ws://localhost:8000/ws/$roomId/$finalClientId/$playerName?token=$token');

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready; // Ensure connection is established

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      notifyListeners();

      _subscription = _channel!.stream.listen(
        (data) {
          final message = jsonDecode(data);
          if (message['type'] == 'game_update') {
            _gameState = GameState.fromJson(message['state'],
                currentUserId: _lastClientId);
            notifyListeners();
          }
        },
        onError: (err) {
          _handleDisconnect("Connection Error: $err");
        },
        onDone: () {
          _handleDisconnect("Connection Closed");
        },
      );
    } catch (err) {
      _handleDisconnect("Failed to connect: $err");
    }
  }

  void _handleDisconnect(String message) {
    _isConnected = false;
    _isConnecting = false;
    _error = message;
    _channel = null;
    notifyListeners();

    if (_shouldReconnect) {
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    if (_reconnectAttempts >= 5) {
      _error = "Maximum reconnection attempts reached.";
      notifyListeners();
      return;
    }

    _reconnectAttempts++;
    final backoff = Duration(seconds: _reconnectAttempts * 2);

    _reconnectTimer = Timer(backoff, () {
      if (_lastRoomId != null &&
          _lastClientId != null &&
          _lastPlayerName != null) {
        connect(_lastRoomId!, _lastClientId!, _lastPlayerName!);
      }
    });
  }

  void sendAction(String type, Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode({
        'type': type,
        'data': data,
      }));
    }
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _isConnecting = false;
    _gameState = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
