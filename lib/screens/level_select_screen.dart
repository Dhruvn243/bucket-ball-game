import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final int maxLevels;

  const LevelSelectScreen({super.key, this.maxLevels = 20});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int highestUnlockedLevel = 1;
  Map<int, int> starsByLevel = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestUnlockedLevel = prefs.getInt('highestUnlockedLevel') ?? 1;
      starsByLevel = Map<int, int>.fromIterable(
        List.generate(widget.maxLevels, (i) => i + 1),
        key: (lvl) => lvl,
        value: (lvl) => prefs.getInt('stars_lvl_$lvl') ?? 0,
      );
    });
  }

  // Handles updating stars and unlocking next level after finishing a game
  Future<void> _onLevelCompleted(int level, int starsEarned) async {
    final prefs = await SharedPreferences.getInstance();
    int prevStars = prefs.getInt('stars_lvl_$level') ?? 0;
    bool improved = starsEarned > prevStars;
    // Only update if the new stars are higher
    if (improved) {
      await prefs.setInt('stars_lvl_$level', starsEarned);
    }
    // Unlock next level if this is the highest unlocked and it was just completed
    if (level == highestUnlockedLevel &&
        highestUnlockedLevel < widget.maxLevels &&
        starsEarned > 0) {
      highestUnlockedLevel++;
      await prefs.setInt('highestUnlockedLevel', highestUnlockedLevel);
    }
    await _loadProgress();
  }

  // Game-like rule card (bottom sheet)
  void _showRulesCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 140),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),


          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff014871), Color(0xffd7ede2)], // Orange to pink
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.18),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.help_rounded, color: Colors.white, size: 44),
                    SizedBox(height: 10),
                    Text(
                      "Game Rules",
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
                      ),
                    ),
                    SizedBox(height: 18),
                    _buildRule("Catch the falling balls with your bucket."),
                    _buildRule("Each caught ball adds to your score."),
                    _buildRule("Reach the target to complete the level."),
                    _buildRule("Complete a level to unlock the next one."),
                    _buildRule("Miss too many balls and you'll have to try again!"),
                    SizedBox(height: 12),
                    Text(
                      "Good luck!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1,
                        shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 5)],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              // Close button (cartoon style)
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.close_rounded, color: Colors.pink, size: 27),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildRule(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• ",
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8fd3f4), Color(0xFF84fab0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Text(
                        "Levels",
                        style: TextStyle(
                          fontSize: 39,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade900,
                          letterSpacing: 2,
                          shadows: [Shadow(color: Colors.white, blurRadius: 5)],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.help_outline, color: Colors.white, size: 30),
                      onPressed: () => _showRulesCard(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: GridView.builder(
                    itemCount: widget.maxLevels,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 40,
                      crossAxisSpacing: 17,
                    ),
                    itemBuilder: (context, idx) {
                      final levelNum = idx + 1;
                      final unlocked = levelNum <= highestUnlockedLevel;
                      final stars = starsByLevel[levelNum] ?? 0;

                      return GestureDetector(
                        onTap: unlocked
                            ? () async {
                          final starsEarned = await Navigator.of(context).push<int>(
                            MaterialPageRoute(
                              builder: (_) => GameScreen(level: levelNum),
                            ),
                          );
                          if (starsEarned != null && starsEarned > 0) {
                            await _onLevelCompleted(levelNum, starsEarned);
                          }
                        }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: unlocked
                                ? (levelNum == highestUnlockedLevel
                                ? Colors.orange.shade200
                                : Colors.white)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: unlocked ? Colors.white : Colors.grey.shade500,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: unlocked
                                    ? Colors.greenAccent.withOpacity(0.16)
                                    : Colors.grey.withOpacity(0.07),
                                blurRadius: 9,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              unlocked
                                  ? Text(
                                "$levelNum",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: levelNum == highestUnlockedLevel
                                      ? Colors.orange.shade900
                                      : Colors.green.shade900,
                                  shadows: [
                                    Shadow(color: Colors.white, blurRadius: 7),
                                  ],
                                ),
                              )
                                  : Icon(Icons.lock, color: Colors.amber.shade800, size: 35),
                              // Stars if unlocked
                              if (unlocked)
                                Positioned(
                                  bottom: 3,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      3,
                                          (i) => Icon(
                                        i < stars ? Icons.star : Icons.star_border,
                                        color: Colors.amber.shade700,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              // New badge for the latest unlocked level
                              if (levelNum == highestUnlockedLevel)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "NEW!",
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "${starsByLevel.values.fold(0, (a, b) => a + b)}/${widget.maxLevels * 3}",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
