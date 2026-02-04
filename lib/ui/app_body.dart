import 'package:flutter/material.dart';
import 'package:ludo/ui/home.dart';

class AppBody extends StatelessWidget {
  const AppBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Ludo')),
        backgroundColor: Colors.white12,
      ),
      body: const Home(),
    );
  }
}
