import 'package:flutter/material.dart';
import '../models/ludo_game_model.dart';
import 'ludo_board_widget.dart';

class LudoGameScreen extends StatefulWidget {
  final int playerCount;

  const LudoGameScreen({super.key, this.playerCount = 4});

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen>
    with TickerProviderStateMixin {
  late LudoGameState gameState;
  late AnimationController diceAnimationController;
  late AnimationController pieceAnimationController;
  bool isDiceRolling = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();

    diceAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    pieceAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _initializeGame() {
    final players = <LudoPlayer>[];

    final playerNames = [
      'Player 1 (Red)',
      'Player 2 (Green)',
      'Player 3 (Yellow)',
      'Player 4 (Blue)',
    ];
    final playerColors = [
      PlayerColor.red,
      PlayerColor.green,
      PlayerColor.yellow,
      PlayerColor.blue,
    ];

    for (int i = 0; i < widget.playerCount; i++) {
      players.add(LudoPlayer(color: playerColors[i], name: playerNames[i]));
    }

    gameState = LudoGameState(players: players);
  }

  @override
  void dispose() {
    diceAnimationController.dispose();
    pieceAnimationController.dispose();
    super.dispose();
  }

  void _rollDice() {
    if (isDiceRolling || !gameState.currentPlayer.canRollDice) return;

    setState(() {
      isDiceRolling = true;
    });

    diceAnimationController.forward(from: 0.0).then((_) {
      gameState.rollDice();

      setState(() {
        isDiceRolling = false;
      });

      if (gameState.validMoves != null && gameState.validMoves!.isEmpty) {
        _showSnackBar('No valid moves! Passing to next player...');
      }
    });
  }

  void _selectPiece(int pieceId) {
    if (!gameState.currentPlayer.canRollDice || gameState.diceValue == 0)
      return;

    if (gameState.validMoves == null ||
        !gameState.validMoves!.contains(pieceId)) {
      _showSnackBar('Cannot move this piece!');
      return;
    }

    setState(() {
      gameState.selectedPieceId = pieceId;
    });
  }

  void _confirmMove() {
    if (gameState.selectedPieceId == null) return;

    pieceAnimationController.forward(from: 0.0).then((_) {
      gameState.movePiece(gameState.selectedPieceId!);
      setState(() {});

      if (gameState.gameOver) {
        _showGameOverDialog();
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < gameState.gameRanking.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${i + 1}. ${gameState.gameRanking[i].name}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initializeGame();
              });
            },
            child: Text('Play Again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ludo Game'),
        centerTitle: true,
        backgroundColor: Colors.purple.shade700,
        actions: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                _formatTime(gameState.elapsedSeconds),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: gameState.gameOver
          ? _buildGameOverScreen()
          : gameState.isPaused
          ? _buildPausedScreen()
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildPlayerInfoBar(),
                  _buildGameBoard(),
                  _buildGameControls(),
                ],
              ),
            ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildPausedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pause_circle, size: 80, color: Colors.purple.shade700),
          SizedBox(height: 24),
          Text(
            'Game Paused',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              gameState.togglePause();
              setState(() {});
            },
            icon: Icon(Icons.play_arrow),
            label: Text('Resume Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.home),
            label: Text('Exit to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfoBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.purple.shade100,
      child: Column(
        children: [
          Text(
            gameState.currentPlayer.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getColorForPlayer(gameState.currentPlayer.color),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Dice: ${gameState.diceValue == 0 ? "Roll to play" : gameState.diceValue}',
            style: TextStyle(fontSize: 16),
          ),
          if (gameState.validMoves != null && gameState.validMoves!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Valid moves: ${gameState.validMoves!.map((id) => id + 1).join(", ")}',
                style: TextStyle(fontSize: 14, color: Colors.green.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTapDown: (details) {
          final boardSize = 400.0;
          final cellSize = boardSize / 15;

          for (var player in gameState.players) {
            for (var piece in player.pieces) {
              if (piece.position == -1) {
                // Check home positions
                final homePositions = _getHomePiecePositions(
                  player,
                  piece,
                  boardSize,
                  cellSize,
                );

                if (_isPointInCircle(
                  details.localPosition,
                  homePositions,
                  cellSize * 0.35,
                )) {
                  _selectPiece(piece.id);
                  return;
                }
              }
            }
          }
        },
        child: LudoBoardWidget(gameState: gameState, onPieceTap: _selectPiece),
      ),
    );
  }

  List<Offset> _getHomePiecePositions(
    LudoPlayer player,
    LudoPiece piece,
    double boardSize,
    double cellSize,
  ) {
    Offset baseOffset;

    switch (player.color) {
      case PlayerColor.red:
        baseOffset = Offset(
          cellSize * (0.5 + (piece.id % 2)),
          cellSize * (0.5 + (piece.id ~/ 2)),
        );
        break;
      case PlayerColor.green:
        baseOffset = Offset(
          boardSize - cellSize * (2.5 - (piece.id % 2)),
          cellSize * (0.5 + (piece.id ~/ 2)),
        );
        break;
      case PlayerColor.yellow:
        baseOffset = Offset(
          boardSize - cellSize * (2.5 - (piece.id % 2)),
          boardSize - cellSize * (2.5 - (piece.id ~/ 2)),
        );
        break;
      case PlayerColor.blue:
        baseOffset = Offset(
          cellSize * (0.5 + (piece.id % 2)),
          boardSize - cellSize * (2.5 - (piece.id ~/ 2)),
        );
        break;
    }

    return [baseOffset];
  }

  bool _isPointInCircle(Offset point, List<Offset> centers, double radius) {
    for (var center in centers) {
      final distance = (point - center).distance;
      if (distance <= radius) {
        return true;
      }
    }
    return false;
  }

  Widget _buildGameControls() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Dice button
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(
                parent: diceAnimationController,
                curve: Curves.elasticInOut,
              ),
            ),
            child: ElevatedButton(
              onPressed: isDiceRolling || !gameState.currentPlayer.canRollDice
                  ? null
                  : _rollDice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isDiceRolling ? 'Rolling...' : 'Roll Dice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Move button
          if (gameState.selectedPieceId != null && gameState.diceValue > 0)
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                CurvedAnimation(
                  parent: pieceAnimationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: ElevatedButton(
                onPressed: _confirmMove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Move Piece ${(gameState.selectedPieceId ?? 0) + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          SizedBox(height: 16),

          // Pause button
          ElevatedButton.icon(
            onPressed: () {
              gameState.togglePause();
              setState(() {});
            },
            icon: Icon(Icons.pause),
            label: Text(
              'Pause',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Pass turn button (if no valid moves after dice roll)
          if (gameState.diceValue > 0 &&
              (gameState.validMoves == null || gameState.validMoves!.isEmpty) &&
              gameState.selectedPieceId == null)
            ElevatedButton(
              onPressed: () {
                gameState.nextPlayer();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pass Turn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          SizedBox(height: 16),

          // Reset button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _initializeGame();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'New Game',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Game Over!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 32),
          Text(
            'Final Rankings:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          for (int i = 0; i < gameState.gameRanking.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${i + 1}. ${gameState.gameRanking[i].name}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getColorForPlayer(gameState.gameRanking[i].color),
                ),
              ),
            ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _initializeGame();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Play Again',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForPlayer(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return Colors.red;
      case PlayerColor.green:
        return Colors.green;
      case PlayerColor.yellow:
        return Colors.yellow.shade700;
      case PlayerColor.blue:
        return Colors.blue;
    }
  }
}
