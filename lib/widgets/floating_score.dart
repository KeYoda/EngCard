import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingScoreOverlay extends StatefulWidget {
  const FloatingScoreOverlay({Key? key}) : super(key: key);

  @override
  FloatingScoreOverlayState createState() => FloatingScoreOverlayState();
}

class FloatingScoreOverlayState extends State<FloatingScoreOverlay> {
  final List<_ScoreItem> _items = [];

  void showScore({required Offset position, required int points}) {
    final String id = DateTime.now().microsecondsSinceEpoch.toString();

    final double randomAngle = (Random().nextDouble() - 0.5) * 0.5;

    setState(() {
      _items.add(_ScoreItem(
        id: id,
        position: position,
        opacity: 1.0,
        scale: 0.5,
        points: points,
        angle: randomAngle,
      ));
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      _updateItem(
          id,
          (item) => item.copyWith(
                position: Offset(item.position.dx, item.position.dy - 100),
                opacity: 0.0,
                scale: 1.5,
              ));
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _items.removeWhere((item) => item.id == id);
        });
      }
    });
  }

  void _updateItem(String id, _ScoreItem Function(_ScoreItem) update) {
    if (!mounted) return;
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = update(_items[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _items.map((item) {
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            left: item.position.dx,
            top: item.position.dy,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: item.opacity,
              child: Transform.rotate(
                angle: item.angle,
                child: Transform.scale(
                  scale: item.scale,
                  child: Text(
                    "+${item.points}",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFF9F1C),
                      shadows: [
                        const Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        ),
                        const Shadow(
                          blurRadius: 2,
                          color: Colors.white,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScoreItem {
  final String id;
  final Offset position;
  final double opacity;
  final double scale;
  final int points;
  final double angle;

  _ScoreItem({
    required this.id,
    required this.position,
    required this.opacity,
    required this.scale,
    required this.points,
    required this.angle,
  });

  _ScoreItem copyWith({Offset? position, double? opacity, double? scale}) {
    return _ScoreItem(
      id: id,
      position: position ?? this.position,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      points: points,
      angle: angle,
    );
  }
}
