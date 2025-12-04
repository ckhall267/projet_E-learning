import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const Med3DAcademyApp());
}

class Med3DAcademyApp extends StatelessWidget {
  const Med3DAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Med3D Academy',
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: const Color(0xFF23B8C0),
      ),
      home: const LoginPage(),
    );
  }
}
