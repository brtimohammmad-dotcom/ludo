import 'package:flutter/material.dart';
import 'package:ludo/ui/home/home.dart';

class AppBody extends StatelessWidget {
  const AppBody({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Home(),
    );
  }
}
