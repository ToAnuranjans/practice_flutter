import 'package:flutter/foundation.dart';

// Player colors and data
enum PlayerColor { red, green, yellow, blue }

class LudoPiece {
  final int id;
  final PlayerColor playerColor;
  int position; // 0-51 for board, 52-55 for home
  bool isInHome;

  LudoPiece({
    required this.id,
    required this.playerColor,
    this.position = -1,
    this.isInHome = false,
  });

  bool get isSafeHome => position >= 52 && position <= 55;
}

class LudoPlayer {
  final PlayerColor color;
  final String name;
  final List<LudoPiece> pieces;
  int diceValue = 0;
  bool canRollDice = false;
  int consecutiveRolls = 0;

  LudoPlayer({required this.color, required this.name})
    : pieces = List.generate(4, (i) => LudoPiece(id: i, playerColor: color));

  bool get hasWon => pieces.every((p) => p.isSafeHome);
  bool get hasPiecesOnBoard => pieces.any((p) => p.position >= 0);
}

class LudoBoard {
  static const int boardSize = 52;
  static const int safePositions = 4;

  // Safe positions on the board (every 13 squares: 0, 13, 26, 39)
  static const List<int> safePosOnBoard = [0, 13, 26, 39];

  // Home entry positions for each player (starting position on board)
  static const Map<PlayerColor, int> homeEntry = {
    PlayerColor.red: 0,
    PlayerColor.green: 13,
    PlayerColor.yellow: 26,
    PlayerColor.blue: 39,
  };

  // Check if position is safe from capture
  static bool isSafePosition(int position) {
    return safePosOnBoard.contains(position);
  }

  // Get safe home positions for each player
  static int getSafeHomeStart(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return 52;
      case PlayerColor.green:
        return 52;
      case PlayerColor.yellow:
        return 52;
      case PlayerColor.blue:
        return 52;
    }
  }
}

class LudoGameState extends ChangeNotifier {
  final List<LudoPlayer> players;
  int currentPlayerIndex = 0;
  int diceValue = 0;
  List<int>? validMoves;
  int? selectedPieceId;
  List<LudoPlayer> gameRanking = [];
  bool gameOver = false;
  bool isPaused = false;
  int totalMovesMade = 0;
  DateTime gameStartTime = DateTime.now();

  LudoGameState({required this.players}) {
    if (players.isEmpty) {
      throw ArgumentError('At least one player is required');
    }
    _initializeGame();
  }

  int get elapsedSeconds {
    if (isPaused) return 0;
    return DateTime.now().difference(gameStartTime).inSeconds;
  }

  void _initializeGame() {
    currentPlayerIndex = 0;
    players[currentPlayerIndex].canRollDice = true;
    gameRanking.clear();
    gameOver = false;
    isPaused = false;
    totalMovesMade = 0;
    gameStartTime = DateTime.now();
  }

  LudoPlayer get currentPlayer => players[currentPlayerIndex];

  void togglePause() {
    isPaused = !isPaused;
    notifyListeners();
  }

  void rollDice() {
    if (!currentPlayer.canRollDice || isPaused) return;

    diceValue = 1 + (DateTime.now().millisecond % 6);
    currentPlayer.diceValue = diceValue;
    currentPlayer.canRollDice = false;

    _calculateValidMoves();
    notifyListeners();

    // If no valid moves and didn't roll a 6, pass to next player after delay
    if ((validMoves == null || validMoves!.isEmpty) && diceValue != 6) {
      Future.delayed(Duration(seconds: 2), () {
        nextPlayer();
      });
    }
  }

  void _calculateValidMoves() {
    validMoves = [];

    for (var piece in currentPlayer.pieces) {
      if (_canMovePiece(piece, diceValue)) {
        validMoves!.add(piece.id);
      }
    }
  }

  bool _canMovePiece(LudoPiece piece, int dice) {
    // Piece not on board yet
    if (piece.position == -1) {
      return dice == 6; // Can only enter with 6
    }

    // Piece in safe home
    if (piece.isSafeHome) {
      return false; // Can't move after reaching home
    }

    // Check if move would exceed board
    int newPosition = piece.position + dice;
    if (newPosition > 51 && newPosition < 52) {
      return true; // Can move to safe home
    }
    if (newPosition <= 51) {
      return true; // Can move on board
    }

    return false;
  }

  void movePiece(int pieceId) {
    final piece = currentPlayer.pieces[pieceId];

    if (!_canMovePiece(piece, diceValue)) {
      return;
    }

    int newPosition = piece.position + diceValue;

    // Piece enters from base
    if (piece.position == -1) {
      piece.position = LudoBoard.homeEntry[currentPlayer.color]!;
    } else if (newPosition <= 51) {
      // Move on board
      piece.position = newPosition;
    } else if (newPosition > 51) {
      // Move to safe home
      piece.position = 52 + (newPosition - 52);
      piece.isInHome = true;
    }

    // Capture opponent pieces if not in safe position
    if (!LudoBoard.isSafePosition(piece.position) && piece.position < 52) {
      _captureOpponentPieces(piece.position);
    }

    selectedPieceId = null;
    validMoves = null;
    totalMovesMade++;

    // Check for win
    if (currentPlayer.hasWon) {
      gameRanking.add(currentPlayer);
      players.removeAt(currentPlayerIndex);

      if (players.length == 1) {
        gameRanking.add(players[0]);
        gameOver = true;
        notifyListeners();
        return;
      }

      if (currentPlayerIndex >= players.length) {
        currentPlayerIndex = 0;
      }
    }

    // If rolled 6, can roll again
    if (diceValue == 6) {
      currentPlayer.consecutiveRolls++;
      if (currentPlayer.consecutiveRolls < 3) {
        currentPlayer.canRollDice = true;
      } else {
        currentPlayer.consecutiveRolls = 0;
        nextPlayer();
      }
    } else {
      nextPlayer();
    }

    notifyListeners();
  }

  void _captureOpponentPieces(int position) {
    for (var player in players) {
      if (player.color == currentPlayer.color) continue;

      for (var piece in player.pieces) {
        if (piece.position == position && !LudoBoard.isSafePosition(position)) {
          piece.position = -1;
          piece.isInHome = false;
        }
      }
    }
  }

  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    diceValue = 0;
    currentPlayer.canRollDice = true;
    currentPlayer.consecutiveRolls = 0;
    selectedPieceId = null;
    validMoves = null;
    notifyListeners();
  }

  void resetGame() {
    _initializeGame();
    for (var player in players) {
      for (var piece in player.pieces) {
        piece.position = -1;
        piece.isInHome = false;
      }
      player.consecutiveRolls = 0;
    }
    gameRanking.clear();
    gameOver = false;
    notifyListeners();
  }
}
