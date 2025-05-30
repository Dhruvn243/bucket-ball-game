import 'dart:math';
import 'package:flutter/material.dart';
import 'game_win_dialog.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---- Difficulty Logic ----
double getBallSpeed(int level) {
  if (level == 1) return 0.007;
  if (level == 2) return 0.012;
  if (level == 3) return 0.017;
  if (level == 4) return 0.022;
  return 0.025 + (level - 5) * 0.002;
}

int getDropIntervalMs(int level) {
  if (level == 1) return 1200;
  if (level == 2) return 950;
  if (level == 3) return 800;
  if (level == 4) return 650;
  return 500;
}

int getGoal(int level) {
  if (level == 1) return 5;
  if (level == 2) return 8;
  if (level == 3) return 10;
  if (level == 4) return 12;
  return 15 + (level - 5) * 2;
}

int calculateStars(int score, int goal) {
  if (score >= goal) return 3;
  if (score >= goal * 0.8) return 2;
  return 1;
}


Future<void> unlockLevel(int level) async {
  final prefs = await SharedPreferences.getInstance();
  int highestUnlocked = prefs.getInt('unlocked_level') ?? 1;
  if (level > highestUnlocked) {
    await prefs.setInt('unlocked_level', level);
  }
}

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({Key? key, required this.level}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late double bucketX; // -1.0 (left) to 1.0 (right)
  late double bucketWidth;
  late Ticker _ticker;
  int frameCount = 0;
  final List<_FallingBall> _balls = [];
  int score = 0;
  late int goal;
  bool levelComplete = false;
  late String bgImage;
  bool isPaused = false;

  final List<String> bgImages = [
    'assets/bg1.png',
    'assets/bg2.png',
    'assets/bg3.png',
    'assets/bg4.png',
  ];
  final List<String> ballImages = [
    'assets/red.png',
    'assets/purple.png',
    'assets/green.png',
    'assets/blue.png',
  ];

  @override
  void initState() {
    super.initState();
    bgImage = bgImages[(widget.level - 1) % bgImages.length];
    bucketX = 0;
    bucketWidth = 80;
    goal = getGoal(widget.level);
    _ticker = createTicker((_) {
      if (!isPaused) {
        setState(() {
          _updateBalls();
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _addBall() {
    final random = Random();
    _balls.add(_FallingBall(
      x: random.nextDouble(),
      y: -0.15,
      speed: getBallSpeed(widget.level),
      img: ballImages[random.nextInt(ballImages.length)],
    ));
  }

  void _updateBalls() {
    if (levelComplete) return;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double ballImageHeight = 36;
    double bucketImageHeight = 90;
    double bottomMargin = 90;
    double bucketTop = screenHeight - bucketImageHeight - bottomMargin;
    double extraOffset = 4;
    double catchY = (bucketTop - ballImageHeight - extraOffset) / screenHeight;
    double removeY = 1.05;

    // Frame-based ball dropping
    frameCount++;
    int framesPerDrop = (60 * getDropIntervalMs(widget.level) / 1000).round();
    if (frameCount % framesPerDrop == 0 && !levelComplete && !isPaused) {
      _addBall();
    }

    _balls.removeWhere((ball) {
      double previousY = ball.y;
      ball.y += ball.speed;
      ball.lastY = previousY;

      double bucketCenter = (bucketX + 1) / 2 * (screenWidth - bucketWidth) + bucketWidth / 2;
      double ballX = ball.x * (screenWidth - 40) + 20;

      // Remove caught ball at rim (tunneling-proof)
      if (ball.lastY < catchY && ball.y >= catchY && ball.y < removeY) {
        bool caught = (ballX > bucketCenter - bucketWidth / 2 - 18) &&
            (ballX < bucketCenter + bucketWidth / 2 + 18);
        if (caught) {
          score += 1;
          if (score >= goal) {
            levelComplete = true;
            _showLevelCompleteDialog();
          }
          return true;
        }
      }
      if (ball.y >= removeY) {
        return true;
      }
      return false;
    });
  }

  void _showLevelCompleteDialog() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    int starsEarned = calculateStars(score, goal);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameWinDialog(
        level: widget.level,
        score: score,
        goal: goal,
        stars: starsEarned,
        onNext: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(starsEarned); // Pop GameScreen, return stars
          // Optionally, open next level directly if you want
          // Navigator.of(context).push(...);
        },
        onMenu: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(starsEarned); // Pop GameScreen, return stars
        },
        onReplay: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Pop current GameScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GameScreen(level: widget.level),
            ),
          );
        },
      ),
    );



  }


  void _moveBucket(double delta) {
    setState(() {
      bucketX += delta;
      if (bucketX < -1.0) bucketX = -1.0;
      if (bucketX > 1.0) bucketX = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(bgImage, fit: BoxFit.cover),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              double delta = details.delta.dx / (screenWidth / 2);
              _moveBucket(delta);
            },
            child: Stack(
              children: [
                // Balls
                ..._balls.map((ball) {
                  double left = ball.x * (screenWidth - 40) + 20;
                  double top = ball.y * screenHeight;
                  return Positioned(
                    left: left,
                    top: top,
                    child: Image.asset(
                      ball.img,
                      width: 36,
                      height: 36,
                    ),
                  );
                }).toList(),

                // Bucket
                Positioned(
                  left: (bucketX + 1) / 2 * (screenWidth - bucketWidth),
                  bottom: 90,
                  child: Image.asset(
                    'assets/bucket.png',
                    width: bucketWidth,
                    height: 90,
                  ),
                ),
                if (isPaused)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Text('Paused',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          // UI overlays (score, level, etc.)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text('Level ${widget.level}',
                    style: GoogleFonts.rubik(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text('Score: $score / $goal',
                    style: GoogleFonts.rubik(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 8),
                Spacer(),
              ],
            ),
          ),
          // Pause/play button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white, size: 32),
                  onPressed: () {
                    setState(() {
                      isPaused = !isPaused;
                    });
                  },
                ),
              ),
            ),
          ),
          // Exit button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Ball model
class _FallingBall {
  double x, y, speed;
  final String img;
  double lastY;

  _FallingBall({
    required this.x,
    required this.y,
    required this.speed,
    required this.img,
  }) : lastY = y;
}
