import 'package:flutter/material.dart';
import 'dart:math';

class ShakeCurve extends Curve {
  @override
  double transform(double t) => sin(t * pi * 2);
}

class XAnimation extends StatefulWidget {
  const XAnimation({super.key});

  @override
  State<XAnimation> createState() => _XAnimationState();
}

class _XAnimationState extends State<XAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 300).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(title: Text('Animations')),
      body: Container(
        height: _animation.value,
        width: _animation.value,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: FlutterLogo(),
      ),
    );
  }
}
