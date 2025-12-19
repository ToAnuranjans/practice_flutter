import 'dart:math' as math show pi;

import 'package:flutter/material.dart';

class XCube extends StatefulWidget {
  const XCube({super.key});

  @override
  State<XCube> createState() => _XCubeState();
}

class _XCubeState extends State<XCube> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Rotation angles for the whole cube
  double _rotX = -0.5;
  double _rotY = 0.6;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    Tween<double>(begin: 0, end: 1).animate(_controller).addListener(() {
      setState(() {});
    });
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 180; // cube face size
    final double half = size / 2; // distance from center to each face

    return Scaffold(
      appBar: AppBar(title: const Text("3D Cube")),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              // drag horizontally -> rotateY, vertically -> rotateX
              _rotY += details.delta.dx * 0.01;
              _rotX -= details.delta.dy * 0.01;
            });
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.00002) // perspective (smaller = less depth)
              ..rotateX(_rotX)
              ..rotateY(_rotY),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  // FRONT (+Z)
                  _face(
                    size: size,
                    color: Colors.red,
                    label: "Front",
                    transform: Matrix4.identity()
                      ..translateByDouble(0.0, 0.0, half, 1.0),
                  ),

                  // BACK (-Z) : rotate 180 around Y then push forward
                  _face(
                    size: size,
                    color: Colors.blue,
                    label: "Back",
                    transform: Matrix4.identity()
                      ..rotateX(math.pi)
                      ..translateByDouble(0.0, 0.0, half, 1.0),
                  ),

                  // // RIGHT (+X)
                  _face(
                    size: size,
                    color: Colors.green,
                    label: "Right",
                    transform: Matrix4.identity()
                      ..rotateY(math.pi / 2)
                      ..translateByDouble(0.0, 0.0, half, 1.0),
                  ),

                  // // LEFT (-X)
                  _face(
                    size: size,
                    color: Colors.orange,
                    label: "Left",
                    transform: Matrix4.identity()
                      ..rotateY(-math.pi / 2)
                      ..translateByDouble(0.0, 0.0, half, 1.0),
                  ),

                  // // TOP (-Y)
                  _face(
                    size: size,
                    color: Colors.purple,
                    label: "Top",
                    transform: Matrix4.identity()
                      ..rotateX(-math.pi / 2)
                      ..translateByDouble(0.0, 0.0, half, 1.0),
                  ),

                  // // BOTTOM (+Y)
                  _face(
                    size: size,
                    color: Colors.teal,
                    label: "Bottom",
                    transform: Matrix4.identity()
                      ..rotateX(math.pi / 2)
                      ..translateByDouble(0.0, 0.0, half, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _face({
    required double size,
    required Color color,
    required String label,
    required Matrix4 transform,
  }) {
    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(1),
          border: Border.all(color: Colors.black54, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
