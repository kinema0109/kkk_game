import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/game_models.dart';

class GameProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  GameState? _gameState;
  bool _isConnected = false;
  String? _error;

  GameState? get gameState => _gameState;
  bool get isConnected => _isConnected;
  String? get error => _error;

  void connect(String roomId, String clientId, String playerName) {
    // Current local backend URL (Adjust if running on Render/Production)
    final uri =
        Uri.parse('ws://localhost:8000/ws/$roomId/$clientId/$playerName');

    _channel = WebSocketChannel.connect(uri);
    _isConnected = true;
    _error = null;
    notifyListeners();

    _channel!.stream.listen(
      (data) {
        final message = jsonDecode(data);
        if (message['type'] == 'game_update') {
          _gameState = GameState.fromJson(message['state']);
          notifyListeners();
        }
      },
      onError: (err) {
        _isConnected = false;
        _error = err.toString();
        notifyListeners();
      },
      onDone: () {
        _isConnected = false;
        notifyListeners();
      },
    );
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
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
