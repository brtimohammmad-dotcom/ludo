import 'package:flutter/material.dart';
import 'package:ludo/ui/app_body.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
   const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 final Widget material = MaterialApp(
    title: 'Ludo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.dark()),
    home: AppBody(),
  );

  @override
  Widget build(BuildContext context) {
    return material;
  }
}

