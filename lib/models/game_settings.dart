import 'package:flutter/foundation.dart';

class GameSettings extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  double _gameSpeed = 1.0; // 0.5 to 2.0
  String _playerName = 'Player';

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  double get gameSpeed => _gameSpeed;
  String get playerName => _playerName;

  // Setters
  void setSoundEnabled(bool value) {
    if (_soundEnabled != value) {
      _soundEnabled = value;
      notifyListeners();
    }
  }

  void setVibrationEnabled(bool value) {
    if (_vibrationEnabled != value) {
      _vibrationEnabled = value;
      notifyListeners();
    }
  }

  void setDarkModeEnabled(bool value) {
    if (_darkModeEnabled != value) {
      _darkModeEnabled = value;
      notifyListeners();
    }
  }

  void setGameSpeed(double value) {
    final clipped = value.clamp(0.5, 2.0);
    if (_gameSpeed != clipped) {
      _gameSpeed = clipped;
      notifyListeners();
    }
  }

  void setPlayerName(String value) {
    if (_playerName != value && value.isNotEmpty) {
      _playerName = value;
      notifyListeners();
    }
  }

  void resetToDefaults() {
    _soundEnabled = true;
    _vibrationEnabled = true;
    _darkModeEnabled = false;
    _gameSpeed = 1.0;
    _playerName = 'Player';
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'soundEnabled': _soundEnabled,
    'vibrationEnabled': _vibrationEnabled,
    'darkModeEnabled': _darkModeEnabled,
    'gameSpeed': _gameSpeed,
    'playerName': _playerName,
  };

  void fromJson(Map<String, dynamic> json) {
    _soundEnabled = json['soundEnabled'] as bool? ?? true;
    _vibrationEnabled = json['vibrationEnabled'] as bool? ?? true;
    _darkModeEnabled = json['darkModeEnabled'] as bool? ?? false;
    _gameSpeed = (json['gameSpeed'] as num?)?.toDouble() ?? 1.0;
    _playerName = json['playerName'] as String? ?? 'Player';
    notifyListeners();
  }
}
