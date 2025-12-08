import 'package:flutter/material.dart';
import 'package:oliminate_mobile/left_drawer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const String routeName = '/landing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oliminate"),
        toolbarHeight: kToolbarHeight,
      ),
      drawer: const LeftDrawer(),
      body: const Center(
        child: Text('Landing Page'),
      ),
    );
  }
}
