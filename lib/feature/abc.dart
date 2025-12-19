import 'dart:math';

import 'package:flutter/material.dart';

class Abc extends StatefulWidget {
  const Abc({super.key});

  @override
  State<Abc> createState() => _AbcState();
}

class _AbcState extends State<Abc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abc')),
      body: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // perspective (smaller = less depth)
            ..rotateX(pi)
            ..rotateY(pi),
          child: Container(
            height: 200,
            width: 200,
            color: Colors.red,
            child: Stack(
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(
                      3,
                      2,
                      0.0015,
                    ) // perspective (smaller = less depth)
                    ..rotateX(pi)
                    ..rotateY(pi),
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Colors.green,
                  ),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(
                      3,
                      2,
                      0.0015,
                    ) // perspective (smaller = less depth)
                    ..rotateX(pi)
                    ..rotateY(pi),
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
