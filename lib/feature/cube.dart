import 'dart:math' as math;

import 'package:flutter/material.dart';

class XCube extends StatefulWidget {
  const XCube({super.key});

  @override
  State<XCube> createState() => _XCubeState();
}

class _XCubeState extends State<XCube> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animating = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    setState(() {
      _animating = !_animating;
      if (_animating) {
        _controller.repeat();
      } else {
        _controller.stop(canceled: false);
      }
    });
  }

  Widget _buildFace(double size, Color color, String label) {
    return Container(
      width: size,
      height: size,
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  // Create a transformed face using a local transform and the global rotation.
  Widget _positionedFace({
    required double size,
    required Matrix4 faceTransform,
    required Widget child,
    required Matrix4 globalTransform,
  }) {
    // Combine global rotation with face-specific transform
    final Matrix4 m = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..multiply(globalTransform)
      ..multiply(faceTransform);

    return Transform(transform: m, alignment: Alignment.center, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.6;

        return GestureDetector(
          onTap: _toggleAnimation,
          child: Center(
            child: SizedBox(
              width: size,
              height: size,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final double t = _controller.value * math.pi * 2;
                  // Global rotation applied to the whole cube
                  final Matrix4 global = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(t * 0.6)
                    ..rotateY(t * 0.9);

                  final double half = size / 2;

                  // Face transforms: translate forward by half the cube, then rotate to face direction
                  final faceFront = Matrix4.identity()
                    ..translate(0.0, 0.0, half);
                  final faceBack = Matrix4.identity()
                    ..rotateY(math.pi)
                    ..translate(0.0, 0.0, half);
                  final faceRight = Matrix4.identity()
                        // Face transforms: translate forward by half the cube, then rotate to face direction
                        final faceFront = Matrix4.identity()..translate(0.0, 0.0, half);
                        final faceBack = Matrix4.identity()..rotateY(math.pi)..translate(0.0, 0.0, half);
                        final faceRight = Matrix4.identity()..rotateY(math.pi / 2)..translate(0.0, 0.0, half);
                        final faceLeft = Matrix4.identity()..rotateY(-math.pi / 2)..translate(0.0, 0.0, half);
                        final faceTop = Matrix4.identity()..rotateX(-math.pi / 2)..translate(0.0, 0.0, half);
                        final faceBottom = Matrix4.identity()..rotateX(math.pi / 2)..translate(0.0, 0.0, half);

                        // Prepare faces with their base colors and local normals
                        final faces = <Map<String, dynamic>>[
                          {
                            'transform': faceBack,
                            'color': Colors.blue.shade700,
                            'label': 'Back',
                            'normal': vmath.Vector3(0, 0, -1),
                          },
                          {
                            'transform': faceLeft,
                            'color': Colors.green.shade700,
                            'label': 'Left',
                            'normal': vmath.Vector3(-1, 0, 0),
                          },
                          {
                            'transform': faceRight,
                            'color': Colors.orange.shade700,
                            'label': 'Right',
                            'normal': vmath.Vector3(1, 0, 0),
                          },
                          {
                            'transform': faceTop,
                            'color': Colors.purple.shade700,
                            'label': 'Top',
                            'normal': vmath.Vector3(0, -1, 0),
                          },
                          {
                            'transform': faceBottom,
                            'color': Colors.teal.shade700,
                            'label': 'Bottom',
                            'normal': vmath.Vector3(0, 1, 0),
                          },
                          {
                            'transform': faceFront,
                            'color': Colors.red.shade700,
                            'label': 'Front',
                            'normal': vmath.Vector3(0, 0, 1),
                          },
                        ];

                        // Combine global and face transforms, compute depth and simple shading, then sort back-to-front
                        final lightDir = vmath.Vector3(0, 0, 1)..normalize();
                        final List<Map<String, dynamic>> painted = [];

                        for (final face in faces) {
                          final Matrix4 M = Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..multiply(global)
                            ..multiply(face['transform'] as Matrix4);

                          // transformed center depth (z)
                          final vmath.Vector3 center = M.transform3(vmath.Vector3.zero());

                          // compute transformed normal (rotation only)
                          final Matrix4 rotOnly = Matrix4.copy(M);
                          rotOnly.setTranslationRaw(0, 0, 0);
                          final vmath.Vector3 tnormal = rotOnly.transform3((face['normal'] as vmath.Vector3).clone())..normalize();

                          // simple diffuse shading
                          double shade = tnormal.dot(lightDir);
                          shade = (shade * 0.5) + 0.5; // map from [-1,1] to [0,1]
                          shade = shade.clamp(0.2, 1.0);

                          final Color baseColor = face['color'] as Color;
                          final Color shaded = Color.lerp(Colors.black, baseColor, shade)!;

                          painted.add({
                            'matrix': M,
                            'z': center.z,
                            'widget': _buildFace(size, shaded, face['label'] as String),
                          });
                        }

                        painted.sort((a, b) => (a['z'] as double).compareTo(b['z'] as double));

                        // Render faces from far to near
                        return Stack(
                          clipBehavior: Clip.none,
                          children: painted.map<Widget>((entry) {
                            return Transform(
                              transform: entry['matrix'] as Matrix4,
                              alignment: Alignment.center,
                              child: entry['widget'] as Widget,
                            );
                          }).toList(),
                        );
                        faceTransform: faceBack,
                        globalTransform: global,
                        child: _buildFace(size, Colors.blue.shade700, 'Back'),
                      ),
                      _positionedFace(
                        size: size,
                        faceTransform: faceLeft,
                        globalTransform: global,
                        child: _buildFace(size, Colors.green.shade700, 'Left'),
                      ),
                      _positionedFace(
                        size: size,
                        faceTransform: faceRight,
                        globalTransform: global,
                        child: _buildFace(
                          size,
                          Colors.orange.shade700,
                          'Right',
                        ),
                      ),
                      _positionedFace(
                        size: size,
                        faceTransform: faceTop,
                        globalTransform: global,
                        child: _buildFace(size, Colors.purple.shade700, 'Top'),
                      ),
                      _positionedFace(
                        size: size,
                        faceTransform: faceBottom,
                        globalTransform: global,
                        child: _buildFace(size, Colors.teal.shade700, 'Bottom'),
                      ),
                      // Front face (drawn last so it's on top)
                      _positionedFace(
                        size: size,
                        faceTransform: faceFront,
                        globalTransform: global,
                        child: _buildFace(size, Colors.red.shade700, 'Front'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
