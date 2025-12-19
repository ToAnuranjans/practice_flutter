import 'dart:math';
import '../models/ludo_game_model.dart';

enum DifficultyLevel { easy, medium, hard }

class AIPlayer {
  final String name;
  final DifficultyLevel difficulty;
  final PlayerColor color;
  final Random _random = Random();

  AIPlayer({required this.name, required this.difficulty, required this.color});

  /// Returns the best piece to move based on difficulty level
  int? decideMoveAI(LudoGameState gameState) {
    if (gameState.validMoves == null || gameState.validMoves!.isEmpty) {
      return null;
    }

    final player = gameState.currentPlayer;
    final validMoves = gameState.validMoves!;

    switch (difficulty) {
      case DifficultyLevel.easy:
        return _easyMove(validMoves, player);
      case DifficultyLevel.medium:
        return _mediumMove(validMoves, player, gameState);
      case DifficultyLevel.hard:
        return _hardMove(validMoves, player, gameState);
    }
  }

  /// Easy: Random valid move
  int _easyMove(List<int> validMoves, LudoPlayer player) {
    return validMoves[_random.nextInt(validMoves.length)];
  }

  /// Medium: Prioritize pieces already on board or those closer to home
  int _mediumMove(
    List<int> validMoves,
    LudoPlayer player,
    LudoGameState gameState,
  ) {
    final bestMove = validMoves.reduce((a, b) {
      final pieceA = player.pieces[a];
      final pieceB = player.pieces[b];

      // Prioritize pieces on board over pieces in base
      if (pieceA.position >= 0 && pieceB.position < 0) return a;
      if (pieceA.position < 0 && pieceB.position >= 0) return b;

      // If both on board, prioritize piece closer to safe home
      if (pieceA.position >= 0 && pieceB.position >= 0) {
        return pieceA.position > pieceB.position ? a : b;
      }

      // If both in base, random
      return _random.nextBool() ? a : b;
    });

    return bestMove;
  }

  /// Hard: Smart strategy - advance pieces to home, capture enemy pieces, avoid dangers
  int _hardMove(
    List<int> validMoves,
    LudoPlayer player,
    LudoGameState gameState,
  ) {
    int? bestMove;
    int bestScore = -999;

    for (final pieceId in validMoves) {
      final piece = player.pieces[pieceId];
      int score = 0;

      // Score based on position
      if (piece.position < 0) {
        // Getting piece out is good
        score += 50;
      } else {
        // Advance towards home is better
        score += piece.position;
      }

      // Check if this move would capture an opponent piece
      final newPosition = piece.position == -1
          ? LudoBoard.homeEntry[player.color]!
          : piece.position + gameState.diceValue;

      if (newPosition <= 51 && !LudoBoard.isSafePosition(newPosition)) {
        // Check for opponent pieces to capture
        for (var opponent in gameState.players) {
          if (opponent.color == player.color) continue;
          for (var opponentPiece in opponent.pieces) {
            if (opponentPiece.position == newPosition) {
              score += 100; // Bonus for capturing
            }
          }
        }
      }

      // Penalize moving to unsafe positions if possible to avoid
      if (newPosition < 52 && !LudoBoard.isSafePosition(newPosition)) {
        // Check if any opponent piece can reach this position
        for (var opponent in gameState.players) {
          if (opponent.color == player.color) continue;
          for (var opponentPiece in opponent.pieces) {
            if (opponentPiece.position >= 0 && opponentPiece.position < 52) {
              final distanceToOurPiece = (newPosition - opponentPiece.position)
                  .abs();
              if (distanceToOurPiece <= 6) {
                score -= 30; // Penalty for being vulnerable
              }
            }
          }
        }
      }

      // Bonus for reaching safe home
      if (newPosition >= 52) {
        score += 200;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMove = pieceId;
      }
    }

    return bestMove ?? validMoves[0];
  }

  /// Decide if AI should roll dice (always returns true)
  bool shouldRollDice() => true;

  /// Get thinking delay based on difficulty
  Duration getThinkingDelay() {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Duration(milliseconds: 300 + _random.nextInt(200));
      case DifficultyLevel.medium:
        return Duration(milliseconds: 600 + _random.nextInt(400));
      case DifficultyLevel.hard:
        return Duration(milliseconds: 1000 + _random.nextInt(500));
    }
  }
}
