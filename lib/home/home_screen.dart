import 'package:flutter/material.dart';

import '../mood/mood_screen.dart';
import '../mood/mood_trends_screen.dart';
import '../journal/journal_screen.dart';
import '../wellness/wellness_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Zen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => _openScreen(context, const SettingsScreen()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your Moment of Peace',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a little time for yourself today.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Daily mood check-in
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'How are you feeling today?',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('😞', style: TextStyle(fontSize: 28)),
                      Text('🙁', style: TextStyle(fontSize: 28)),
                      Text('😐', style: TextStyle(fontSize: 28)),
                      Text('🙂', style: TextStyle(fontSize: 28)),
                      Text('😄', style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _openScreen(context, const MoodScreen()),
                    child: const Text("Record Today's Mood"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Today's reflection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Reflection", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Text("What is something you're grateful for today?"),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        _openScreen(context, const JournalScreen()),
                    child: const Text('Write in Journal'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mood trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Mood Trends', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Text('View your recent mood patterns.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        _openScreen(context, const MoodTrendsScreen()),
                    child: const Text('View Trends'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => _openScreen(context, const JournalScreen()),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.menu_book_outlined), Text('Journal')],
              ),
            ),
            TextButton(
              onPressed: () => _openScreen(context, const MoodTrendsScreen()),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.show_chart), Text('Trends')],
              ),
            ),
            TextButton(
              onPressed: () => _openScreen(context, const WellnessScreen()),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.favorite_outline), Text('Resources')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
