import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/value_objects/chord_input_mode.dart';

/// User-facing settings: bar layout, min width, and default input mode.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => _SettingsList(settings: settings),
      ),
    );
  }
}

class _SettingsList extends ConsumerStatefulWidget {
  final AppSettings settings;

  const _SettingsList({required this.settings});

  @override
  ConsumerState<_SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends ConsumerState<_SettingsList> {
  late AppSettings _current;

  @override
  void initState() {
    super.initState();
    _current = widget.settings;
  }

  Future<void> _save(AppSettings updated) async {
    setState(() => _current = updated);
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    ref.invalidate(appSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Equal-width bars'),
          subtitle: const Text(
              'All bars in a row are the same width. Off = proportional to chord count.'),
          value: _current.equalWidthBars,
          onChanged: (v) => _save(_current.copyWith(equalWidthBars: v)),
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Minimum bar width'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                min: 12,
                max: 40,
                divisions: 28,
                value: _current.minBarWidthMm,
                label: '${_current.minBarWidthMm.round()} mm',
                onChanged: (v) =>
                    setState(() => _current = _current.copyWith(minBarWidthMm: v)),
                onChangeEnd: (v) => _save(_current.copyWith(minBarWidthMm: v)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  '${_current.minBarWidthMm.round()} mm',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Default input mode'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: SegmentedButton<ChordInputMode>(
              segments: const [
                ButtonSegment(
                  value: ChordInputMode.smartKeyboard,
                  label: Text('Smart Keyboard'),
                  icon: Icon(Icons.piano),
                ),
                ButtonSegment(
                  value: ChordInputMode.text,
                  label: Text('Text'),
                  icon: Icon(Icons.keyboard_alt_outlined),
                ),
              ],
              selected: {_current.defaultInputMode},
              onSelectionChanged: (s) =>
                  _save(_current.copyWith(defaultInputMode: s.first)),
            ),
          ),
        ),
      ],
    );
  }
}
