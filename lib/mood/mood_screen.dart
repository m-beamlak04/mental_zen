import 'package:flutter/material.dart';

import 'mood_service.dart';

import 'dart:async';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> with WidgetsBindingObserver {
  final MoodService _moodService = MoodService();
  final TextEditingController _noteController = TextEditingController();

  late String _date;
  Timer? _dateTimer;

  int? _selectedRating;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasExistingMood = false;
  String? _loadError;

  final List<String> _moodEmojis = ['😞', '🙁', '😐', '🙂', '😄'];
  final List<String> _moodLabels = ['Awful', 'Bad', 'Okay', 'Good', 'Great'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _date = _moodService.getTodayDate();
    _loadMood();

    _dateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkDateChange(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dateTimer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  void _checkDateChange() {
    final today = _moodService.getTodayDate();

    if (!mounted || _isSaving || _isLoading || today == _date) {
      return;
    }

    setState(() {
      _date = today;
      _selectedRating = null;
      _noteController.clear();
      _hasExistingMood = false;
      _loadError = null;
      _isLoading = true;
    });

    _loadMood();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDateChange();
    }
  }

  Future<void> _loadMood() async {
    try {
      final mood = await _moodService.getMood(_date);

      if (!mounted) return;

      setState(() {
        if (mood != null) {
          _selectedRating = mood.rating;
          _noteController.text = mood.note ?? '';
          _hasExistingMood = true;
        }

        _loadError = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = 'Unable to load your mood. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMood() async {
    if (_date != _moodService.getTodayDate()) {
      _checkDateChange();
      return;
    }

    if (_selectedRating == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a mood.')));
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _moodService.saveMood(
        date: _date,
        rating: _selectedRating!,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mood saved successfully!')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      debugPrint('Failed to save mood: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save your mood. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildMoodSelector() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(_moodEmojis.length, (index) {
        final rating = index + 1;
        final isSelected = _selectedRating == rating;

        return Expanded(
          child: GestureDetector(
            onTap: _isSaving
                ? null
                : () {
                    setState(() {
                      _selectedRating = isSelected ? null : rating;
                    });
                  },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.secondaryContainer
                        : colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    _moodEmojis[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _moodLabels[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mood Log')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mood Log')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_loadError!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _loadError = null;
                  });
                  _loadMood();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Log')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How are you feeling today?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a moment to check in with yourself.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(_date, style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),

              _buildMoodSelector(),

              const SizedBox(height: 32),
              Text(
                "What's on your mind?",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _noteController,
                enabled: !_isSaving,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Add an optional note...',
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveMood,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _hasExistingMood
                            ? "Update Today's Mood"
                            : "Save Today's Mood",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
