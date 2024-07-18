import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiPainter extends StatefulWidget {
  @override
  _ConfettiPainterState createState() => _ConfettiPainterState();
}

class _ConfettiPainterState extends State<ConfettiPainter> {
  late List<ConfettiParticle> _particles;
  late Timer _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(100, (index) => ConfettiParticle(_random));
    _timer = Timer.periodic(Duration(seconds: 2), (_) {
      setState(() {
        _particles = List.generate(100, (index) => ConfettiParticle(_random));
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConfettiCustomPainter(_particles),
      child: Container(),
    );
  }
}

class _ConfettiCustomPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiCustomPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiParticle {
  static const List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
  late Color color;
  late double x;
  late double y;
  late double speedX;
  late double speedY;
  late double size;
  final Random random;

  ConfettiParticle(this.random) {
    color = colors[random.nextInt(colors.length)];
    x = random.nextDouble();
    y = random.nextDouble();
    speedX = random.nextDouble() * 2 - 1;
    speedY = random.nextDouble() * 2 + 2;
    size = random.nextDouble() * 4 + 2;
  }

  void update() {
    x += speedX * 0.01;
    y += speedY * 0.01;
    if (y > 1) {
      y = -size / 100;
    }
  }

  void draw(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(x * size.width, y * size.height), this.size, paint);
  }
}