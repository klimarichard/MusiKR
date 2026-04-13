import 'package:freezed_annotation/freezed_annotation.dart';
import 'time_signature.dart';
import 'key_signature.dart';

part 'metadata.freezed.dart';

enum Feel {
  swing,
  straight,
  latin,
  bossa,
  waltz,
  funk,
  ballad,
  other;

  String get displayName => switch (this) {
    Feel.swing    => 'Swing',
    Feel.straight => 'Straight',
    Feel.latin    => 'Latin',
    Feel.bossa    => 'Bossa Nova',
    Feel.waltz    => 'Waltz',
    Feel.funk     => 'Funk',
    Feel.ballad   => 'Ballad',
    Feel.other    => 'Other',
  };
}

@freezed
class Metadata with _$Metadata {
  const factory Metadata({
    @Default('') String title,
    @Default('') String artist,
    @Default('') String composer,
    @Default('') String catalogRef,
    @Default(120) int tempo,
    @Default(Feel.straight) Feel feel,
    required TimeSignature timeSignature,
    required KeySignature keySignature,
    @Default([]) List<String> tags,
  }) = _Metadata;

  factory Metadata.defaults() => Metadata(
    timeSignature: TimeSignature.common(),
    keySignature: KeySignature.cMajor(),
  );
}
