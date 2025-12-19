import 'package:flutter/material.dart';
import '../models/game_statistics.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0; // 0: Players, 1: History
  late GameStatisticsManager _stats;

  @override
  void initState() {
    super.initState();
    _stats = GameStatisticsManager();
  }

  @override
  void dispose() {
    _stats.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.purple.shade700,
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          tabs: [
            Tab(text: 'Top Players'),
            Tab(text: 'Game History'),
          ],
        ),
      ),
      body: _selectedTab == 0 ? _buildPlayersTab() : _buildHistoryTab(),
    );
  }

  Widget _buildPlayersTab() {
    final topPlayers = _stats.topPlayers;

    if (topPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No games played yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: topPlayers.length,
      itemBuilder: (context, index) {
        final player = topPlayers[index];
        final medal = index == 0
            ? '🥇'
            : index == 1
            ? '🥈'
            : index == 2
            ? '🥉'
            : '${index + 1}.';

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(medal, style: TextStyle(fontSize: 24)),
            ),
            title: Text(
              player.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                Text('${player.wins} Wins'),
                SizedBox(width: 8),
                Container(
                  height: 4,
                  width: 4,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
                SizedBox(width: 8),
                Text('${player.losses} Losses'),
                SizedBox(width: 8),
                Container(
                  height: 4,
                  width: 4,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
                SizedBox(width: 8),
                Text('${player.winRate.toStringAsFixed(1)}%'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.gamesPlayed}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'games',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () => _showPlayerStats(player),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final history = _stats.gameHistory;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No game history',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final game = history[index];
        final date = game.playedAt;
        final timeAgo = _formatTimeAgo(game.playedAt);

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Final Ranking:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 4),
                for (int i = 0; i < game.ranking.length; i++)
                  Padding(
                    padding: EdgeInsets.only(left: 8, top: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(game.ranking[i]),
                      ],
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duration: ${(game.durationInSeconds / 60).toStringAsFixed(1)} min',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Moves: ${game.totalMoves}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlayerStats(PlayerStats player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                _buildStatCard('Wins', '${player.wins}'),
                _buildStatCard('Losses', '${player.losses}'),
                _buildStatCard('Games', '${player.gamesPlayed}'),
                _buildStatCard(
                  'Win Rate',
                  '${player.winRate.toStringAsFixed(1)}%',
                ),
                _buildStatCard('Total Moves', '${player.totalMoves}'),
              ],
            ),
            if (player.lastPlayedAt != null) ...[
              SizedBox(height: 24),
              Text(
                'Last played: ${_formatTimeAgo(player.lastPlayedAt!)}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
