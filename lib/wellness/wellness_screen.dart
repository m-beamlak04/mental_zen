import 'package:flutter/material.dart';

class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wellness Resources')),
      body: const Center(child: Text('Wellness resources coming soon')),
    );
  }
}
