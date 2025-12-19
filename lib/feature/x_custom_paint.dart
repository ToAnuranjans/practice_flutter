import 'package:flutter/material.dart';

class XCustomPaint extends StatefulWidget {
  const XCustomPaint({super.key});

  @override
  State<XCustomPaint> createState() => _XCustomPaintState();
}

class _XCustomPaintState extends State<XCustomPaint> {
  var size = 300.0;

  @override
  Widget build(BuildContext context) {
    var smallSize = size / 6.0;
    var bigSize = size / 2.0;
    return Scaffold(
      appBar: AppBar(title: Text('X Custom Paint')),
      body: Padding(
        padding: const EdgeInsets.all(45.0),
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 10),
              ),
              child: CustomPaint(painter: _XPainter()),
            ),
            _makeHole(Offset(0, 0), smallSize),
            _makeHole(Offset(size - smallSize, 0), smallSize),
            _makeHole(Offset(0, size - smallSize), smallSize),
            _makeHole(Offset(size - smallSize, size - smallSize), smallSize),
            _makeHollow(
              Offset((size - bigSize) / 2, (size - bigSize) / 2),
              bigSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _makeHole(Offset offset, double size) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 10),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _makeHollow(Offset offset, double size) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 10),
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
    );
  }
}

class _XPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
