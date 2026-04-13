import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/note_name.dart';
import '../value_objects/accidental.dart';

part 'key_signature.freezed.dart';

enum KeyMode { major, minor }

@freezed
class KeySignature with _$KeySignature {
  const factory KeySignature({
    required NoteName root,
    @Default(Accidental.natural) Accidental accidental,
    @Default(KeyMode.major) KeyMode mode,
  }) = _KeySignature;

  factory KeySignature.cMajor() =>
      const KeySignature(root: NoteName.c);

  factory KeySignature.aMinor() =>
      const KeySignature(root: NoteName.a, mode: KeyMode.minor);
}
