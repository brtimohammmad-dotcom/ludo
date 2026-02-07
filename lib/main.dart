import 'package:flutter/material.dart';
import 'package:ludo/ui/app_body.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Ludo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: const ColorScheme.dark(),fontFamily: 'Roboto'),
      home: const AppBody(),
    );
  }
}
