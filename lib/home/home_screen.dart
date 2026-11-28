import 'package:flutter/material.dart';

import '../mood/mood_screen.dart';
import '../mood/mood_trends_screen.dart';
import '../journal/journal_screen.dart';
import '../wellness/wellness_screen.dart';
import '../settings/settings_screen.dart';
import '../models/mood.dart';
import '../mood/mood_service.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final MoodService _moodService = MoodService();

  late Stream<Mood?> _todayMoodStream;
  late String _currentDate;
  Timer? _dateTimer;

  final List<String> _moodEmojis = ['😞', '🙁', '😐', '🙂', '😄'];
  final List<String> _moodLabels = ['Awful', 'Bad', 'Okay', 'Good', 'Great'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeMoodStream();

    _dateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkDateChange(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dateTimer?.cancel();
    super.dispose();
  }

  void _checkDateChange() {
    final today = _moodService.getTodayDate();

    if (today != _currentDate && mounted) {
      setState(() {
        _initializeMoodStream();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDateChange();
    }
  }

  void _initializeMoodStream() {
    _currentDate = _moodService.getTodayDate();
    _todayMoodStream = _moodService.watchMood(_currentDate);
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildDailyMoodCard() {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<Mood?>(
          stream: _todayMoodStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(
                children: [
                  const Text("Unable to load today's mood."),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _initializeMoodStream();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final mood = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  mood == null ? 'How are you feeling today?' : "Today's Mood",
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                if (mood == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _moodEmojis.map((emoji) {
                      return Text(emoji, style: const TextStyle(fontSize: 28));
                    }).toList(),
                  )
                else ...[
                  Text(
                    _moodEmojis[mood.rating - 1],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Feeling ${_moodLabels[mood.rating - 1]}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ],

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => _openScreen(context, const MoodScreen()),
                  child: Text(
                    mood == null
                        ? "Record Today's Mood"
                        : "Update Today's Mood",
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
          _buildDailyMoodCard(),
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
