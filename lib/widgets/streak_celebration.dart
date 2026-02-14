import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakCelebrationOverlay extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const StreakCelebrationOverlay({Key? key, required this.onAnimationComplete})
      : super(key: key);

  @override
  State<StreakCelebrationOverlay> createState() =>
      _StreakCelebrationOverlayState();
}

class _StreakCelebrationOverlayState extends State<StreakCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 Saniye sürsün
    );

    // Büyüme ve Küçülme Efekti (Elastic)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.5), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 3.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Sonlara doğru kaybolma
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    // Başlat
    _controller.forward().then((_) => widget.onAnimationComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DEV ATEŞ İKONU 🔥
            Icon(
              Icons.local_fire_department_rounded,
              color: Colors.deepOrangeAccent,
              size: 150,
              shadows: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 50,
                  spreadRadius: 20,
                )
              ],
            ),
            const SizedBox(height: 20),
            // YAZI
            Material(
              // Text'in altını çizmemesi için Material lazım
              color: Colors.transparent,
              child: Text(
                "SERİ ARTTI!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    const Shadow(blurRadius: 10, color: Colors.orange),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
