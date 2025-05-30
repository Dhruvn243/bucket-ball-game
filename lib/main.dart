import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import splash

void main() {
  runApp(const BucketGameApp());
}

class BucketGameApp extends StatelessWidget {
  const BucketGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bucket Ball Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF00BFFF),
          secondary: Color(0xFF303F9F),
        ),
        fontFamily: 'SF Pro',
        useMaterial3: true,
      ),
      home: SplashScreen(), // Start with splash
    );
  }
}
