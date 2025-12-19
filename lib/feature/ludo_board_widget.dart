import 'package:flutter/material.dart';
import '../models/ludo_game_model.dart';

class LudoBoardWidget extends StatelessWidget {
  final LudoGameState gameState;
  final Function(int) onPieceTap;

  const LudoBoardWidget({
    super.key,
    required this.gameState,
    required this.onPieceTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LudoBoardPainter(gameState, onPieceTap),
      size: Size(400, 400),
    );
  }
}

class LudoBoardPainter extends CustomPainter {
  final LudoGameState gameState;
  final Function(int) onPieceTap;
  late Paint boardPaint;
  late Paint safePaint;
  late Paint pathPaint;

  LudoBoardPainter(this.gameState, this.onPieceTap) {
    boardPaint = Paint()..color = Colors.white;
    safePaint = Paint()..color = Colors.yellow.shade100;
    pathPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 15;
    final boardRect = Rect.fromLTWH(
      cellSize * 3,
      cellSize * 3,
      cellSize * 9,
      cellSize * 9,
    );

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey.shade200,
    );

    // Draw main board
    canvas.drawRect(boardRect, boardPaint..style = PaintingStyle.fill);
    canvas.drawRect(
      boardRect,
      boardPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw home areas (corners)
    _drawHomeArea(canvas, size, PlayerColor.red, cellSize);
    _drawHomeArea(canvas, size, PlayerColor.green, cellSize);
    _drawHomeArea(canvas, size, PlayerColor.yellow, cellSize);
    _drawHomeArea(canvas, size, PlayerColor.blue, cellSize);

    // Draw path cells
    _drawPathCells(canvas, size, cellSize);

    // Draw safe positions
    _drawSafePositions(canvas, size, cellSize);

    // Draw pieces
    _drawPieces(canvas, size, cellSize);
  }

  void _drawHomeArea(
    Canvas canvas,
    Size size,
    PlayerColor color,
    double cellSize,
  ) {
    Offset offset;
    Color areaColor;

    switch (color) {
      case PlayerColor.red:
        offset = Offset(0, 0);
        areaColor = Colors.red.shade200;
        break;
      case PlayerColor.green:
        offset = Offset(size.width - cellSize * 3, 0);
        areaColor = Colors.green.shade200;
        break;
      case PlayerColor.yellow:
        offset = Offset(size.width - cellSize * 3, size.height - cellSize * 3);
        areaColor = Colors.yellow.shade200;
        break;
      case PlayerColor.blue:
        offset = Offset(0, size.height - cellSize * 3);
        areaColor = Colors.blue.shade200;
        break;
    }

    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, cellSize * 3, cellSize * 3),
      Paint()..color = areaColor,
    );

    // Draw 4 home positions
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        final x = offset.dx + cellSize * (0.5 + i);
        final y = offset.dy + cellSize * (0.5 + j);
        canvas.drawCircle(
          Offset(x, y),
          cellSize * 0.3,
          Paint()..color = areaColor.withOpacity(0.3),
        );
      }
    }
  }

  void _drawPathCells(Canvas canvas, Size size, double cellSize) {
    // Draw main path around the board
    final boardOffset = cellSize * 3;
    final boardSize = cellSize * 9;

    // Top row
    for (int i = 0; i < 6; i++) {
      final x = boardOffset + cellSize + i * cellSize;
      _drawPathCell(canvas, Offset(x, boardOffset), cellSize);
    }

    // Right column
    for (int i = 0; i < 6; i++) {
      final y = boardOffset + cellSize + i * cellSize;
      _drawPathCell(
        canvas,
        Offset(boardOffset + boardSize - cellSize, y),
        cellSize,
      );
    }

    // Bottom row
    for (int i = 0; i < 6; i++) {
      final x = boardOffset + boardSize - cellSize - i * cellSize;
      _drawPathCell(
        canvas,
        Offset(x, boardOffset + boardSize - cellSize),
        cellSize,
      );
    }

    // Left column
    for (int i = 0; i < 6; i++) {
      final y = boardOffset + boardSize - cellSize - i * cellSize;
      _drawPathCell(canvas, Offset(boardOffset, y), cellSize);
    }
  }

  void _drawPathCell(Canvas canvas, Offset offset, double cellSize) {
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, cellSize, cellSize),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, cellSize, cellSize),
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  void _drawSafePositions(Canvas canvas, Size size, double cellSize) {
    final boardOffset = cellSize * 3;
    final positions = [
      Offset(boardOffset + cellSize * 4.5, boardOffset),
      Offset(size.width - boardOffset, boardOffset + cellSize * 4.5),
      Offset(boardOffset + cellSize * 4.5, size.height - boardOffset),
      Offset(boardOffset, boardOffset + cellSize * 4.5),
    ];

    for (var pos in positions) {
      canvas.drawCircle(pos, cellSize * 0.35, Paint()..color = Colors.yellow);
    }
  }

  void _drawPieces(Canvas canvas, Size size, double cellSize) {
    final boardOffset = cellSize * 3;

    for (var player in gameState.players) {
      for (var piece in player.pieces) {
        if (piece.position == -1) {
          // In home base
          _drawPieceInHome(canvas, size, piece, player, cellSize);
        } else if (piece.isSafeHome) {
          // In safe home
          _drawPieceInSafeHome(canvas, size, piece, player, cellSize);
        } else {
          // On board path
          final offset = _getPathCellOffset(
            piece.position,
            boardOffset,
            cellSize,
          );
          _drawPiece(canvas, offset, piece, player, cellSize);
        }
      }
    }
  }

  void _drawPieceInHome(
    Canvas canvas,
    Size size,
    LudoPiece piece,
    LudoPlayer player,
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
          size.width - cellSize * (2.5 - (piece.id % 2)),
          cellSize * (0.5 + (piece.id ~/ 2)),
        );
        break;
      case PlayerColor.yellow:
        baseOffset = Offset(
          size.width - cellSize * (2.5 - (piece.id % 2)),
          size.height - cellSize * (2.5 - (piece.id ~/ 2)),
        );
        break;
      case PlayerColor.blue:
        baseOffset = Offset(
          cellSize * (0.5 + (piece.id % 2)),
          size.height - cellSize * (2.5 - (piece.id ~/ 2)),
        );
        break;
    }

    _drawPiece(canvas, baseOffset, piece, player, cellSize);
  }

  void _drawPieceInSafeHome(
    Canvas canvas,
    Size size,
    LudoPiece piece,
    LudoPlayer player,
    double cellSize,
  ) {
    Offset homeOffset;
    final homeIndex = piece.position - 52;

    switch (player.color) {
      case PlayerColor.red:
        homeOffset = Offset(
          cellSize * 3 + cellSize * 4.5,
          cellSize * (3 - homeIndex),
        );
        break;
      case PlayerColor.green:
        homeOffset = Offset(
          size.width - cellSize * 3 - cellSize * 4.5,
          cellSize * (3 + homeIndex),
        );
        break;
      case PlayerColor.yellow:
        homeOffset = Offset(
          cellSize * 3 + cellSize * 4.5,
          size.height - cellSize * (3 - homeIndex),
        );
        break;
      case PlayerColor.blue:
        homeOffset = Offset(
          size.width - cellSize * 3 - cellSize * 4.5,
          cellSize * (3 - homeIndex),
        );
        break;
    }

    _drawPiece(canvas, homeOffset, piece, player, cellSize);
  }

  Offset _getPathCellOffset(int position, double boardOffset, double cellSize) {
    // Position 0-5: top row
    // Position 6-11: right column
    // Position 12-17: bottom row
    // Position 18-23: left column

    if (position < 6) {
      return Offset(boardOffset + cellSize + position * cellSize, boardOffset);
    } else if (position < 12) {
      return Offset(
        boardOffset + cellSize * 9 - cellSize,
        boardOffset + cellSize + (position - 6) * cellSize,
      );
    } else if (position < 18) {
      return Offset(
        boardOffset + cellSize * 9 - cellSize - (position - 12) * cellSize,
        boardOffset + cellSize * 9 - cellSize,
      );
    } else {
      return Offset(
        boardOffset,
        boardOffset + cellSize * 9 - cellSize - (position - 18) * cellSize,
      );
    }
  }

  void _drawPiece(
    Canvas canvas,
    Offset offset,
    LudoPiece piece,
    LudoPlayer player,
    double cellSize,
  ) {
    final isSelected =
        gameState.selectedPieceId == piece.id &&
        gameState.currentPlayer.color == player.color;

    canvas.drawCircle(
      offset,
      cellSize * 0.35,
      Paint()..color = _getPlayerColor(player.color),
    );

    if (isSelected) {
      canvas.drawCircle(
        offset,
        cellSize * 0.38,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Draw piece number
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${piece.id + 1}',
        style: TextStyle(
          color: Colors.white,
          fontSize: cellSize * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      offset - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  Color _getPlayerColor(PlayerColor color) {
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

  @override
  bool shouldRepaint(LudoBoardPainter oldDelegate) => true;
}
