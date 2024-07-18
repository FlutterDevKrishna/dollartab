import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class AnimatedAdBanner extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onTap;

  const AnimatedAdBanner({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedAdBannerState createState() => _AnimatedAdBannerState();
}

class _AnimatedAdBannerState extends State<AnimatedAdBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _confettiController.play();
        Future.delayed(const Duration(seconds: 2), () {
          _controller.reverse();
          _confettiController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.0,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Text('Error loading image'));
                        },
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2, // straight up
                colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow],
                createParticlePath: _drawStar, // Use a custom shape
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned.fill(
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        'Celebration!',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Path _drawStar(Size size) {
    // Draw a star path for custom confetti shapes
    final path = Path();
    final double halfWidth = size.width / 2;
    final double externalRadius = size.width / 2;
    final double internalRadius = externalRadius / 2.5;
    final double step = pi / 5;

    for (double i = 0; i < 2 * pi; i += step) {
      final double r = i % (2 * step) == 0 ? externalRadius : internalRadius;
      final double x = halfWidth + r * cos(i);
      final double y = halfWidth - r * sin(i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }
}
