// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:confetti/confetti.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';
import 'dart:typed_data';

/// Shows a confetti (celebratory) animation: paper snippings falling down.
///
/// The widget fills the available space (like [SizedBox.expand] would).
///
/// When [isStopped] is `true`, the animation will not run. This is useful
/// when the widget is not visible yet, for example. Provide [colors]
/// to make the animation look good in context.
///
/// This is a partial port of this CodePen by Hemn Chawroka:
/// https://codepen.io/iprodev/pen/azpWBr

class ConfettiScreen extends StatelessWidget {
  const ConfettiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Confetti(),
    );
  }
}

class Confetti extends StatefulWidget {
  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with TickerProviderStateMixin {
  late ConfettiController _controllerCenter;
  late ConfettiController _controllerCenterRight;
  late ConfettiController _controllerCenterLeft;
  late ConfettiController _controllerTopCenter;
  late ConfettiController _controllerBottomCenter;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 8),
    vsync: this,
  )..repeat(reverse: true);

  Animation<AlignmentGeometry> animateVertically(double x) {
    return Tween<AlignmentGeometry>(
      begin: Alignment(x, -1.0),
      end: Alignment(x, 1.0),
    ).animate(_controller);
  }

  late List<Path> charPaths;

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 10));

    rootBundle.load("assets/Permanent_Marker/PermanentMarker-Regular.ttf").then((ByteData data) {
      // Create a font reader
      var reader = PMFontReader();
      // Parse the font
      var myFont = reader.parseTTFAsset(data);
      // Generate the complete path for a specific character
      charPaths = [
        myFont.generatePathForCharacter(97),
        myFont.generatePathForCharacter(98),
        myFont.generatePathForCharacter(99),
      ];
    });
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    _controllerTopCenter.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  Path drawChar(Size size) {
    return PMTransform.moveAndScale(charPaths.sample(1).single, 0, 0, 0.04, 0.04);
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          //CENTER -- Blast
          AlignTransition(
            alignment: animateVertically(-0.5),
            child: Stack(
              children: [
                ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality.explosive,
                  // don't specify a direction, blast randomly
                  shouldLoop: false,
                  numberOfParticles: 40, // number of particles to emit
                  // start again as soon as the animation is finished
                  colors: const [
                    // Colors.green,
                    // Colors.blue,
                    // Colors.pink,
                    Color.fromARGB(255, 255, 255, 100),
                    Color.fromARGB(120, 255, 255, 100),
                  ],
                  // manually specify the colors to be used
                  createParticlePath: drawChar, // define a custom shape/path.
                  strokeWidth: 4,
                  strokeColor: const Color.fromARGB(80, 255, 255, 100),
                ),
                TextButton(
                    onPressed: () => _controllerCenter.play(),
                    child: _display('blast\nstars')),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(-0.5, 1.0),
            child: TextButton(
                onPressed: () {
                  _controllerCenter.play();

                  final AnimationController controller = AnimationController(
                    duration: const Duration(seconds: 1),
                    vsync: this,
                  );

                  Tween<AlignmentGeometry>(
                    begin: Alignment(0, -1.0),
                    end: Alignment(0, 1.0),
                  ).animate(controller);
                },
                child: _display('blast\nstars')),
          ),

          //CENTER RIGHT -- Emit left
          AlignTransition(
            alignment: animateVertically(0.5),
            child: Stack(
              children: [
                ConfettiWidget(
                  confettiController: _controllerCenterRight,
                  blastDirection: 3 * pi / 2, // radial value - UP
                  // particleDrag: 0.05, // apply drag to the confetti
                  emissionFrequency: 0.01, // how often it should emit
                  numberOfParticles: 40, // number of particles to emit
                  gravity: 0.05, // gravity - or fall speed
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink
                  ], // manually specify the colors to be used
                  // strokeWidth: 4,
                  // strokeColor: const Color.fromARGB(80, 255, 255, 255),
                ),
                TextButton(
                    onPressed: () => _controllerCenterRight.play(),
                    child: _display('pump')),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0.5, 1.0),
            child: TextButton(
                onPressed: () => _controllerCenterRight.play(),
                child: _display('pump')),
          ),

          // //BOTTOM CENTER
          // AlignTransition(
          //   alignment: animateVertically(-0.8),
          //   child: Stack(
          //     children: [
          //       ConfettiWidget(
          //         confettiController: _controllerBottomCenter,
          //         blastDirection: -pi / 2,
          //         emissionFrequency: 0.03,
          //         numberOfParticles: 40,
          //         maxBlastForce: 50,
          //         minBlastForce: 40,
          //         gravity: 0.3,
          //         colors: const [
          //           Color.fromARGB(255, 255, 255, 100),
          //           Color.fromARGB(120, 255, 255, 100),
          //         ], // manually specify the colors to be used
          //         strokeWidth: 4,
          //         strokeColor: const Color.fromARGB(80, 255, 255, 100),
          //       ),
          //       TextButton(
          //           onPressed: () => _controllerBottomCenter.play(),
          //           child: _display('hard and\ninfrequent'))
          //     ],
          //   ),
          // ),
          // Align(
          //   alignment: const Alignment(-0.8, 1.0),
          //   child: TextButton(
          //       onPressed: () => _controllerBottomCenter.play(),
          //       child: _display('hard and\ninfrequent')),
          // ),

        ],
      ),
    );
  }

  Text _display(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
  }
}
