import 'package:freezed_annotation/freezed_annotation.dart';
import 'bar.dart';
import 'repeat_info.dart';

part 'section.freezed.dart';

@freezed
class Section with _$Section {
  const factory Section({
    required String id,

    /// Display name shown in the section header (e.g. "A", "Verse", "Chorus")
    @Default('') String name,

    /// Non-null when this section has repeat or navigation markings.
    RepeatInfo? repeatInfo,

    @Default([]) List<Bar> bars,
  }) = _Section;
}
