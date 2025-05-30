import 'package:flutter/material.dart';

// Helper widget to show animated stars
Widget buildStars(int stars) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (i) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Icon(
            i < stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: i < stars ? Colors.amber.shade600 : Colors.grey.shade300,
            size: 44,
          ),
        )
    ),
  );
}

class GameWinDialog extends StatelessWidget {
  final int level;
  final int score;
  final int goal;
  final int stars;
  final VoidCallback onNext;
  final VoidCallback onMenu;
  final VoidCallback onReplay;

  const GameWinDialog({
    super.key,
    required this.level,
    required this.score,
    required this.goal,
    required this.stars,
    required this.onNext,
    required this.onMenu,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Card with nice gradient background and less empty space
            Container(
              margin: EdgeInsets.only(top: 68, left: 16, right: 16, bottom: 32),
              padding: EdgeInsets.fromLTRB(19, 20, 18, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFe0e7ff), Color(0xFFf5f7fa), Color(0xFFc1eaff)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.14),
                    blurRadius: 32,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 0),
                  buildStars(stars),
                  SizedBox(height: 0),
                  // Banner image or text
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/banner.png', height: 122), // Use your PNG
                      Text(
                        "Completed!",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(color: Colors.pink.shade300, blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Target: ",
                        style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "$goal",
                        style: TextStyle(fontSize: 21, color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.check, color: Colors.green, size: 20),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Your Score: ",
                        style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "$score",
                        style: TextStyle(fontSize: 21, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: onMenu,
                        icon: Icon(Icons.menu, color: Colors.pink, size: 38),
                        tooltip: "Menu",
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: onNext,
                        icon: Icon(Icons.play_arrow_rounded, color: Colors.green, size: 46),
                        tooltip: "Next Level",
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: onReplay,
                        icon: Icon(Icons.refresh, color: Colors.blue, size: 38),
                        tooltip: "Replay",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bigger level badge!
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade400,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.22),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "Level $level",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(color: Colors.blue.shade200, blurRadius: 7)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }
}
