import 'package:flutter/material.dart';
import 'splashscreen.dart';

void main() {
  runApp(const NitiMitraApp());
}

class NitiMitraApp extends StatelessWidget {
  const NitiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NitiMitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: const SplashScreen(), // Start with Splash
    );
  }
}
