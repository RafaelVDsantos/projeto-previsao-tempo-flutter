import 'package:flutter/material.dart';
import 'screens/previsao_screen.dart';

void main() => runApp(const PrevisaoApp());

class PrevisaoApp extends StatelessWidget {
  const PrevisaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PrevisaoScreen(),
    );
  }
}