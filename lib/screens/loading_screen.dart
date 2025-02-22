import 'package:flutter/material.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;
  String _displayText = "";
  int _textIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;
  Timer? _loadingTimer;
  Timer? _typingTimer;

  final List<String> _loadingTexts = [
    "Reduce, Reuse, Recycle",
    "Go Green",
    "Give Nature a Healthy Future"
  ];

  @override
  void initState() {
    super.initState();
    _startLoading();
    _startTypingEffect();
  }

  void _startLoading() {
    _loadingTimer = Timer.periodic(Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.2;
        });
      }
      if (_progress >= 1.0) {
        timer.cancel();
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login'); // ✅ Navigate to Login
          }
        });
      }
    });
  }

  void _startTypingEffect() {
    _typingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          if (_isDeleting) {
            if (_charIndex > 0) {
              _charIndex--;
              _displayText = _loadingTexts[_textIndex].substring(0, _charIndex);
            } else {
              _isDeleting = false;
              _textIndex = (_textIndex + 1) % _loadingTexts.length;
            }
          } else {
            if (_charIndex < _loadingTexts[_textIndex].length) {
              _charIndex++;
              _displayText = _loadingTexts[_textIndex].substring(0, _charIndex);
            } else {
              Future.delayed(Duration(milliseconds: 500), () {
                _isDeleting = true;
              });
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC1E899), // Soft Green Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🌱 GIF Animation with Fallback
            Image.network(
              "https://cdn.pixabay.com/animation/2024/02/17/14/31/14-31-36-345_512.gif",
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.eco, size: 100, color: Colors.green),
            ),
            SizedBox(height: 30),

            // ✨ Typing Effect Text
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: Text(
                _displayText,
                key: ValueKey(_displayText),
                style: TextStyle(
                  color: Color(0xFF9A6735), // Earthy Brown Text
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),

            // 📊 **Smooth Loading Bar**
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _progress),
              duration: Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Container(
                  width: 280,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(0xFFE6F0DC), // Light Green Background
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(0xFF55883B), // Deep Leaf Green Progress
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
