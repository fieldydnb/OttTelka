import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OttTelka',
      home: Scaffold(
        appBar: AppBar(title: const Text('OttTelka Player')),
        body: const Center(child: Text('DASH Player App')),
      ),
    );
  }
}
