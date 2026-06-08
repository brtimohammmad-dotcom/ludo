import 'package:flutter/material.dart';
import 'package:ludo/ui/join_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(child: JoinScreen())]);
  }
}
