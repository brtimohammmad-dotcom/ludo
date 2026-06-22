import 'package:flutter/material.dart';
import 'package:ludo/ui/app_body.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🟢 ۱. این امپورت را حتماً بگذار

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(), // یا هر ویجتی که ریشه اصلی برنامه‌ات است
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        fontFamily: 'Roboto',
      ),
      home: AppBody(),
    );
  }
}
