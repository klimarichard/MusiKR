import 'package:freezed_annotation/freezed_annotation.dart';

part 'repeat_info.freezed.dart';

/// Repeat and navigation metadata for a Section.
@freezed
class RepeatInfo with _$RepeatInfo {
  const factory RepeatInfo({
    /// Number of times the section is played (default 2 = play twice)
    @Default(2) int repeatCount,

    /// Numbered endings present in this section (e.g. [1, 2] for 1st and 2nd endings)
    @Default([]) List<int> numberedEndings,

    /// True when the last bar of the section is a split bar ending
    @Default(false) bool hasSplitBarEnding,
  }) = _RepeatInfo;
}
