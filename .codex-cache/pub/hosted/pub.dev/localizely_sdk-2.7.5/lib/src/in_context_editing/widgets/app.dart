import 'package:flutter/material.dart';

class App extends StatelessWidget {
  final Widget child;

  App({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.normal,
            color: Colors.black54,
          ),
          bodyMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Colors.black54,
          ),
        ),
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
