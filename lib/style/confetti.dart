// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:confetti/confetti.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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

  static const xOffset = 0.5;
  var turns = 0.0;
  var isLeftRocketVisible = false;
  var isRightRocketVisible = false;
  var isLeftInvaderVisible = true;
  var isLeftWordItemVisible = true;
  late List<Path> charPaths;

  late final ConfettiController controllerWordFireworks = ConfettiController(
      duration: const Duration(seconds: 1)
  );

  late final ConfettiController controllerStarFireworks = ConfettiController(
      duration: const Duration(seconds: 1)
  );

  late final ConfettiController controllerLeftJet = ConfettiController(
      duration: const Duration(seconds: 1)
  );
  late final ConfettiController controllerRightJet = ConfettiController(
      duration: const Duration(seconds: 1)
  );

  late final Animation<double> invaderLoopController = AnimationController(
    duration: const Duration(seconds: 8),
    vsync: this,
  )
    ..repeat(reverse: true);

  late final AnimationController controllerRotation = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )
    ..addListener(() {
      setState(() => turns += 0.02);
    });

  AnimationController buildRocketAnimationController(Duration duration) {
    return AnimationController(
      duration: duration,
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      });
  }

  late final controllerLeftRocket = buildRocketAnimationController(const Duration(milliseconds: 700));
  late final controllerRightRocket = buildRocketAnimationController(const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();

    rootBundle.load("assets/fonts/Roboto-Bold.ttf").then((ByteData data) {
      // Create a font reader
      var reader = PMFontReader();
      // Parse the font
      var myFont = reader.parseTTFAsset(data);
      // Generate the complete path for a specific character
      charPaths = List.generate(26, (i) => 65 + i)//.followedBy(List.generate(6, (i) => 97 + i))
          .map((i) => myFont.generatePathForCharacter(i))
          .toList();
    });
  }

  @override
  void dispose() {
    controllerWordFireworks.dispose();
    super.dispose();
  }

  Animation<AlignmentGeometry> buildInvaderLoopAnimation(double x) {
    return Tween<AlignmentGeometry>(
      begin: Alignment(x, -0.8),
      end: Alignment(x, -0.2),
    ).animate(invaderLoopController);
  }

  @override
  Widget build(BuildContext context) {
    var invaderLeft = buildInvaderLeft();
    var invaderRight = buildInvaderRight();

    return SafeArea(
      child: Stack(
        children: <Widget>[
          invaderLeft,
          invaderRight,

          // Bottom word stack
          Align(
            alignment: const Alignment(-(xOffset*1.3), 1.0),
            child: Wrap(
              children: [
                Column(
                  children: <Widget>[
                    Visibility(
                      visible: isLeftWordItemVisible,
                      child: TextButton(
                          onPressed: animateLeftRocket,
                          child: _textButton('英語')),
                    ),
                    TextButton(
                        onPressed: animateLeftRocket,
                        child: _textButton('ビサヤ語')),
                    TextButton(
                        onPressed: animateLeftRocket,
                        child: _textButton('韓国語')),
                    TextButton(
                        onPressed: animateLeftRocket,
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
                        onPressed: animateRightRocket,
                        child: _textButton('先生')),
                    TextButton(
                        onPressed: animateRightRocket,
                        child: _textButton('生徒')),
                    TextButton(
                        onPressed: animateRightRocket,
                        child: _textButton('校長')),
                    TextButton(
                        onPressed: animateRightRocket,
                        child: _textButton('学校')),
                  ],
                ),
              ],
            ),
          ),

          buildWordRocket('英語', -xOffset, isLeftRocketVisible,
              controllerLeftRocket, invaderLeft.alignment.value),
          buildWordRocketFail('校長', xOffset, isRightRocketVisible,
              controllerRightRocket, invaderRight.alignment.value),
        ],
      ),
    );
  }

  Widget buildWordRocket(String text, double x, bool isVisible,
      AnimationController controller, AlignmentGeometry alignment) {
    return AlignTransition(
      alignment: Tween<AlignmentGeometry>(
        begin: Alignment(x, 1.0),
        end: alignment.add(const Alignment(0, 0.1)),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn)),
      child: Stack(alignment: Alignment.center, children: [
        buildJetWidget(controllerLeftJet),
        Visibility(
          visible: isVisible,
          child: _largeText(text, Colors.white),
        ),
      ]),
    );
  }

  Widget buildWordRocketFail(String text, double x, bool isVisible,
      AnimationController controller, AlignmentGeometry alignment) {
    return AlignTransition(
      alignment: Tween<AlignmentGeometry>(
        begin: Alignment(x, 1.0),
        end: alignment.add(const Alignment(0, 0.1)),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut)),
      child: Stack(alignment: Alignment.center, children: [
        buildJetWidget(controllerRightJet),
        buildStarFireworksWidget(),
        Visibility(
          visible: isVisible,
          child: _largeText(text, Colors.white),
        ),
      ]),
    );
  }

  ConfettiWidget buildWordFireworksWidget() {
    return ConfettiWidget(
      confettiController: controllerWordFireworks,
      blastDirectionality: BlastDirectionality.explosive,
      maxBlastForce: 40,
      emissionFrequency: 0.001,
      numberOfParticles: 120,
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

  ConfettiWidget buildStarFireworksWidget() {
    return ConfettiWidget(
      confettiController: controllerStarFireworks,
      blastDirectionality: BlastDirectionality.explosive,
      maxBlastForce: 20,
      emissionFrequency: 0.001,
      numberOfParticles: 80,
      colors: const [ Colors.yellow ],
      createParticlePath: drawStar,
      strokeWidth: 2,
      strokeColor: const Color.fromARGB(80, 255, 255, 255),
    );
  }

  ConfettiWidget buildJetWidget(ConfettiController controller) {
    return ConfettiWidget(
      canvas: const Size(1500, 1500),
      confettiController: controller,
      blastDirectionality: BlastDirectionality.directional,
      maxBlastForce: 120,
      particleDrag: 0.03,
      emissionFrequency: 0.50,
      blastDirection: pi / 2,
      gravity: 1.0,
      shouldLoop: true,
      numberOfParticles: 4,
      colors: const [ Colors.yellow ],
      createParticlePath: drawStar,
      strokeWidth: 2,
      strokeColor: const Color.fromARGB(80, 255, 255, 255),
    );
  }

  Container _textButton(String text) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(30, 255, 255, 255),
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
          fontFamily: 'Noto Sans JP',
          shadows: const [
            Shadow(
              blurRadius: 20.0,
              color: Colors.yellow,
              offset: Offset(5.0, 5.0),
            ),
          ],
          fontSize: 80),
    );
  }

  Text _text(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontFamily: 'Noto Sans JP',
          color: Colors.white,
          fontSize: 35),
    );
  }

  animateLeftRocket() {
    controllerLeftRocket.reset();
    controllerLeftJet.play();
    isLeftInvaderVisible = true;
    isLeftRocketVisible = true;
    isLeftWordItemVisible = false;
    controllerLeftRocket.forward().then((value) {
      controllerWordFireworks.play();
      controllerLeftJet.stop();
      isLeftInvaderVisible = false;
      isLeftRocketVisible = false;
      setState(() {});
    }).timeout(const Duration(milliseconds: 4000), onTimeout: () {
      controllerLeftRocket.reset();
      isLeftInvaderVisible = true;
      isLeftWordItemVisible = true;
      setState(() {});
    });
  }

  animateRightRocket() {
    controllerRightRocket.reset();
    isRightRocketVisible = true;
    controllerRightJet.play();
    controllerRightRocket.forward().then((value) {
      controllerStarFireworks.play();
      controllerRightJet.stop();
      isRightRocketVisible = false;
      setState(() {});
    }).timeout(const Duration(milliseconds: 5000), onTimeout: () {
      controllerRightRocket.reset();
    });
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

  buildInvaderLeft() => AlignTransition(
    alignment: buildInvaderLoopAnimation(-xOffset * 1.2),
    child: Stack(
      children: [
        buildWordFireworksWidget(),
        Visibility(
          visible: isLeftInvaderVisible,
          child: buildColorizedText('English'),
        ),
      ],
    ),
  );

  buildInvaderRight() {
    return AlignTransition(
      alignment: buildInvaderLoopAnimation(xOffset * 1.2),
      child: buildColorizedText('Teacher'),
    );
  }

  buildColorizedText(String text) {
    const colorizeColors = [
      Colors.yellow,
      Colors.white,
    ];
    return AnimatedTextKit(
      repeatForever: true,
      isRepeatingAnimation: true,
      animatedTexts: [
        ColorizeAnimatedText(
          text,
          textStyle: const TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontFamily: 'Noto Sans JP',
              shadows: [
                Shadow(
                  blurRadius: 20.0,
                  color: Colors.yellow,
                  offset: Offset(5.0, 5.0),
                ),
              ],
              fontSize: 50),
          colors: colorizeColors,
        ),
      ],
    );
  }
}
