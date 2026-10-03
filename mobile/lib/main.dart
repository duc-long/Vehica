import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VehicaApp());
}

class VehicaApp extends StatelessWidget {
  const VehicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehica Car Rental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1216),
        primaryColor: const Color(0xFF107C74),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF107C74),
          surface: Color(0xFF161B22),
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Vehica Car Rental App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
