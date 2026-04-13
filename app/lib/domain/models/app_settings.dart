import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/chord_input_mode.dart';

part 'app_settings.freezed.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    /// Equal-width bar mode — ON by default per spec
    @Default(true) bool equalWidthBars,

    /// Minimum bar width in millimetres — 18mm per spec
    @Default(18.0) double minBarWidthMm,

    /// Which chord input mode opens by default in the editor
    @Default(ChordInputMode.smartKeyboard) ChordInputMode defaultInputMode,
  }) = _AppSettings;

  factory AppSettings.defaults() => const AppSettings();
}
