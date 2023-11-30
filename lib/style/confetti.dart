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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background_night_sky.jpg"),
              fit: BoxFit.cover),
        ),
        child: Confetti(),
      ),
    );
  }
}

class Confetti extends StatefulWidget {
  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with TickerProviderStateMixin {
  late final ConfettiController _controllerOnce = ConfettiController(
      duration: const Duration(seconds: 1)
  );
  late final ConfettiController _controllerJet = ConfettiController(
      duration: const Duration(seconds: 1)
  );

  Animation<AlignmentGeometry> animateVertically(double x) {
    return Tween<AlignmentGeometry>(
      begin: Alignment(x, -1.0),
      end: Alignment(x, 1.0),
    ).animate(AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )
      ..repeat(reverse: true));
  }

  late List<Path> charPaths;

  @override
  void initState() {
    super.initState();

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

    _controllerJet.play();
  }

  @override
  void dispose() {
    _controllerOnce.dispose();
    super.dispose();
  }

  Path drawChar(Size size) {
    return PMTransform.moveAndScale(charPaths.sample(1).single, 0, 0, 0.08, 0.08);
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    var newSize = 2 * size.width / 3;
    final halfWidth = newSize / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(newSize, halfWidth);

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
    const xOffset = 0.5;
    return SafeArea(
      child: Stack(
        children: <Widget>[
          //CENTER -- Blast
          AlignTransition(
            alignment: animateVertically(-xOffset*1.2),
            child: Stack(
              children: [
                buildFireworksWidget(),
                _largeText( 'English', Colors.white ),
              ],
            ),
          ),

          //CENTER RIGHT -- Emit left
          AlignTransition(
            alignment: animateVertically(xOffset*1.2),
            child: Stack(
              children: [
                buildFireworksWidget(),
                _largeText( 'Teacher', Colors.white),
              ],
            ),
          ),

          Align(
            alignment: const Alignment(-xOffset, 0.3),
            child: Stack(
              alignment: Alignment.center,
                children: [
              _largeText('英語', Colors.yellow),
              buildJetWidget(),
            ]),
          ),

          Align(
            alignment: const Alignment(xOffset, 0.3),
            child: Stack(
                alignment: Alignment.center,
                children: [
              _largeText('校長', Colors.yellow),
              buildJetWidget(),
            ]),
          ),

          // Bottom word stack
          Align(
            alignment: const Alignment(-(xOffset*1.3), 1.0),
            child: Wrap(
              children: [
                Column(
                  children: <Widget>[
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('ビサヤ語')),
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('韓国語')),
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('英語')),
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('中国語')),
                  ],
                ),
              ],
            ),
          ),

          Align(
            alignment: const Alignment(xOffset*1.3, 1.0),
            child: Wrap(
              children: [
                Column(
                  children: <Widget>[
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('先生')),
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('生徒')),
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('校長')),
                    TextButton(
                        onPressed: () => _controllerOnce.play(),
                        child: _textButton('学校')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ConfettiWidget buildFireworksWidget() {
    return ConfettiWidget(
      confettiController: _controllerOnce,
      blastDirectionality: BlastDirectionality.explosive,
      maxBlastForce: 40,
      emissionFrequency: 0.001,
      shouldLoop: false,
      // number of particles to emit
      numberOfParticles: 80,
      // start again as soon as the animation is finished
      colors: const [
        Color.fromARGB(255, 255, 255, 100),
        Color.fromARGB(120, 255, 255, 100),
      ],
      createParticlePath: drawChar,
      strokeWidth: 4,
      strokeColor: const Color.fromARGB(80, 255, 255, 100),
    );
  }

  ConfettiWidget buildJetWidget() {
    return ConfettiWidget(
      confettiController: _controllerJet,
      blastDirectionality: BlastDirectionality.directional,
      emissionFrequency: 0.50,
      blastDirection: pi / 2,
      // don't specify a direction, blast randomly
      shouldLoop: true,
      numberOfParticles: 2,
      // number of particles to emit
      // start again as soon as the animation is finished
      colors: const [
        Colors.yellow
      ],
      createParticlePath: drawStar,
      strokeWidth: 2,
      strokeColor: const Color.fromARGB(80, 255, 255, 255),
    );
  }

  Container _textButton(String text) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _text(text),
    );
  }

  Text _largeText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              blurRadius: 20.0,
              color: Colors.yellow,
              offset: Offset(5.0, 5.0),
            ),
          ],
          fontSize: 50),
    );
  }

  Text _text(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 30),
    );
  }
}
