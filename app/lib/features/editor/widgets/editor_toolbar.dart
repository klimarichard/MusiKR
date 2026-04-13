import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/metadata.dart';
import '../../../domain/value_objects/chord_input_mode.dart';
import '../state/editor_providers.dart';

/// Action buttons rendered in the [EditorScreen] AppBar.
///
/// Consumes [editorProvider] to reflect undo/redo availability and the
/// current input mode.
class EditorToolbar extends ConsumerWidget {
  final String songId;

  const EditorToolbar({super.key, required this.songId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorAsync = ref.watch(editorProvider(songId));
    final notifier = ref.read(editorProvider(songId).notifier);

    final canUndo =
        editorAsync.valueOrNull?.canUndo ?? false;
    final canRedo =
        editorAsync.valueOrNull?.canRedo ?? false;
    final inputMode =
        editorAsync.valueOrNull?.inputMode ?? ChordInputMode.smartKeyboard;
    final song = editorAsync.valueOrNull?.song;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.undo),
          tooltip: 'Undo',
          onPressed: canUndo ? notifier.undo : null,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          tooltip: 'Redo',
          onPressed: canRedo ? notifier.redo : null,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add bar',
          onPressed: song == null
              ? null
              : () {
                  final sectionId = song.sections.last.id;
                  notifier.insertBar(sectionId: sectionId);
                },
        ),
        IconButton(
          icon: const Icon(Icons.playlist_add),
          tooltip: 'Add section',
          onPressed: song == null ? null : () => notifier.insertSection(),
        ),
        IconButton(
          icon: const Icon(Icons.tune),
          tooltip: 'Metadata',
          onPressed: song == null
              ? null
              : () => _showMetadataSheet(context, ref, song.metadata),
        ),
        IconButton(
          icon: Icon(
            inputMode == ChordInputMode.smartKeyboard
                ? Icons.piano
                : Icons.keyboard_alt_outlined,
          ),
          tooltip: 'Toggle input mode',
          onPressed: () => notifier.setInputMode(
            inputMode == ChordInputMode.smartKeyboard
                ? ChordInputMode.text
                : ChordInputMode.smartKeyboard,
          ),
        ),
      ],
    );
  }

  void _showMetadataSheet(
    BuildContext context,
    WidgetRef ref,
    Metadata current,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MetadataSheet(songId: songId, current: current),
    );
  }
}

// ---------------------------------------------------------------------------
// Metadata editing sheet
// ---------------------------------------------------------------------------

class _MetadataSheet extends ConsumerStatefulWidget {
  final String songId;
  final Metadata current;

  const _MetadataSheet({required this.songId, required this.current});

  @override
  ConsumerState<_MetadataSheet> createState() => _MetadataSheetState();
}

class _MetadataSheetState extends ConsumerState<_MetadataSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _artistCtrl;
  late final TextEditingController _tempoCtrl;
  late Feel _feel;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.current.title);
    _artistCtrl = TextEditingController(text: widget.current.artist);
    _tempoCtrl =
        TextEditingController(text: widget.current.tempo.toString());
    _feel = widget.current.feel;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _tempoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Song info',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _artistCtrl,
            decoration: const InputDecoration(labelText: 'Artist / Composer'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tempoCtrl,
                  decoration: const InputDecoration(labelText: 'Tempo (BPM)'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Feel'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Feel>(
                      value: _feel,
                      isDense: true,
                      items: Feel.values
                          .map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(f.displayName),
                              ))
                          .toList(),
                      onChanged: (f) => setState(() => _feel = f!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _save() {
    final tempo = int.tryParse(_tempoCtrl.text) ?? widget.current.tempo;
    final updated = widget.current.copyWith(
      title: _titleCtrl.text.trim(),
      artist: _artistCtrl.text.trim(),
      tempo: tempo.clamp(20, 400),
      feel: _feel,
    );
    ref.read(editorProvider(widget.songId).notifier).updateMetadata(updated);
    Navigator.of(context).pop();
  }
}
