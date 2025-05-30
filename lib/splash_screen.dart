import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'screens/level_select_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _shimmerController;
  late Animation<double> _logoAnim;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoAnim = CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    _logoController.forward();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _shimmerAnim = Tween<double>(begin: -2, end: 2).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutCubic,
    ));

    // Start shimmer just once
    _shimmerController.forward();

    // Go to Level Select after shimmer completes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bucket = Image.asset(
      'assets/bucket.png',
      width: 110,
      height: 110,
      fit: BoxFit.contain,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Game background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Optional overlay for better text contrast
          // Positioned.fill(
          //   child: Container(color: Colors.black.withOpacity(0.08)),
          // ),
          // Foreground: Positioned column
          LayoutBuilder(
            builder: (context, constraints) {
              // Dynamically size/position for any device!
              final double screenHeight = constraints.maxHeight;
              final double logoTop = screenHeight * 0.19; // adjust as needed
              final double titleTop = screenHeight * 0.41;

              return Stack(
                children: [
                  // Logo + glow
                  Positioned(
                    top: logoTop,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _logoAnim,
                      child: AnimatedBuilder(
                        animation: _logoAnim,
                        builder: (context, child) {
                          final bounce = math.sin(_logoAnim.value * math.pi) * 10;
                          return Transform.translate(
                            offset: Offset(0, bounce),
                            child: child,
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.23),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.lightBlueAccent.withOpacity(0.18),
                                    blurRadius: 48,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.99),
                                  width: 5,
                                ),
                              ),
                              child: ClipOval(child: bucket),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Title with shimmer (just once)
                  Positioned(
                    top: titleTop,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _shimmerAnim,
                      builder: (context, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.85),
                                  Colors.yellowAccent,
                                  Colors.lightBlueAccent,
                                ],
                                stops: const [0.1, 0.6, 1.0],
                                begin: Alignment(-1 + _shimmerAnim.value, 0),
                                end: Alignment(1 + _shimmerAnim.value, 0),
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        "BUCKET BALL GAME",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.coiny(
                          fontSize: 32,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            const Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(1, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Subtitle
                  // Subtitle at the bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 42, // Adjust this value for more/less bottom margin
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: const Text(
                        "by Your Studio",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
