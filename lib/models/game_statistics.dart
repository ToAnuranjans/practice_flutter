import 'package:flutter/foundation.dart';

class PlayerStats {
  final String name;
  int wins = 0;
  int losses = 0;
  int gamesPlayed = 0;
  int totalMoves = 0;
  DateTime? lastPlayedAt;
  double averageGameTime = 0; // in minutes

  PlayerStats({required this.name});

  double get winRate => gamesPlayed == 0 ? 0 : (wins / gamesPlayed) * 100;

  Map<String, dynamic> toJson() => {
    'name': name,
    'wins': wins,
    'losses': losses,
    'gamesPlayed': gamesPlayed,
    'totalMoves': totalMoves,
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    'averageGameTime': averageGameTime,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(name: json['name'] as String)
      ..wins = json['wins'] as int? ?? 0
      ..losses = json['losses'] as int? ?? 0
      ..gamesPlayed = json['gamesPlayed'] as int? ?? 0
      ..totalMoves = json['totalMoves'] as int? ?? 0
      ..lastPlayedAt = json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'] as String)
          : null
      ..averageGameTime = (json['averageGameTime'] as num?)?.toDouble() ?? 0;
  }
}

class GameRecord {
  final String id;
  final List<String> playerNames;
  final List<String> ranking; // Ordered by finish
  final DateTime playedAt;
  final int durationInSeconds;
  final int totalMoves;

  GameRecord({
    required this.id,
    required this.playerNames,
    required this.ranking,
    required this.playedAt,
    required this.durationInSeconds,
    required this.totalMoves,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'playerNames': playerNames,
    'ranking': ranking,
    'playedAt': playedAt.toIso8601String(),
    'durationInSeconds': durationInSeconds,
    'totalMoves': totalMoves,
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      playerNames: List<String>.from(json['playerNames'] as List),
      ranking: List<String>.from(json['ranking'] as List),
      playedAt: DateTime.parse(json['playedAt'] as String),
      durationInSeconds: json['durationInSeconds'] as int,
      totalMoves: json['totalMoves'] as int,
    );
  }
}

class GameStatisticsManager extends ChangeNotifier {
  final Map<String, PlayerStats> _playerStats = {};
  final List<GameRecord> _gameHistory = [];

  List<PlayerStats> get topPlayers {
    final stats = _playerStats.values.toList();
    stats.sort((a, b) => b.wins.compareTo(a.wins));
    return stats;
  }

  List<GameRecord> get gameHistory => _gameHistory.toList();

  PlayerStats getOrCreatePlayer(String name) {
    if (!_playerStats.containsKey(name)) {
      _playerStats[name] = PlayerStats(name: name);
    }
    return _playerStats[name]!;
  }

  void recordGameResult({
    required List<String> playerNames,
    required List<String> ranking,
    required int durationInSeconds,
    required int totalMoves,
  }) {
    // Update player statistics
    for (int i = 0; i < ranking.length; i++) {
      final playerName = ranking[i];
      final stats = getOrCreatePlayer(playerName);

      if (i == 0) {
        stats.wins++;
      } else {
        stats.losses++;
      }
      stats.gamesPlayed++;
      stats.lastPlayedAt = DateTime.now();
      stats.totalMoves += totalMoves;
    }

    // Record game history
    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerNames: playerNames,
      ranking: ranking,
      playedAt: DateTime.now(),
      durationInSeconds: durationInSeconds,
      totalMoves: totalMoves,
    );
    _gameHistory.insert(0, record);

    notifyListeners();
  }

  void resetStatistics() {
    _playerStats.clear();
    _gameHistory.clear();
    notifyListeners();
  }
}
