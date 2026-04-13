import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_signature.freezed.dart';

@freezed
class TimeSignature with _$TimeSignature {
  const factory TimeSignature({
    required int numerator,
    required int denominator,
  }) = _TimeSignature;

  factory TimeSignature.common() =>
      const TimeSignature(numerator: 4, denominator: 4);

  factory TimeSignature.cut() =>
      const TimeSignature(numerator: 2, denominator: 2);

  factory TimeSignature.waltz() =>
      const TimeSignature(numerator: 3, denominator: 4);

  factory TimeSignature.fiveEight() =>
      const TimeSignature(numerator: 5, denominator: 8);

  factory TimeSignature.sevenEight() =>
      const TimeSignature(numerator: 7, denominator: 8);
}
