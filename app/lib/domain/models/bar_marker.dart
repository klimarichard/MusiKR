import 'package:freezed_annotation/freezed_annotation.dart';

part 'bar_marker.freezed.dart';

/// A repeat, navigation, or articulation marker attached to a bar position.
///
/// Sealed — exhaustive pattern matching enforced at compile time.
/// Adding a new variant here requires updating RepeatBracketPainter and
/// RepeatValidator to handle it.
@freezed
sealed class BarMarker with _$BarMarker {
  /// |: — open repeat barline
  const factory BarMarker.repeatStart() = RepeatStart;

  /// :| — close repeat barline; [playCount] defaults to 2
  const factory BarMarker.repeatEnd({@Default(2) int playCount}) = RepeatEnd;

  /// Start of a numbered ending bracket (1st, 2nd, 3rd…)
  const factory BarMarker.endingStart({required int number}) = EndingStart;

  /// End of a numbered ending bracket
  const factory BarMarker.endingEnd() = EndingEnd;

  /// 𝄌 Coda symbol
  const factory BarMarker.coda() = Coda;

  /// 𝄋 Segno symbol
  const factory BarMarker.segno() = Segno;

  /// Fine marker
  const factory BarMarker.fine() = Fine;

  /// D.C. — Dal Capo (go to beginning)
  const factory BarMarker.dalCapo() = DalCapo;

  /// D.S. — Dal Segno (go to segno)
  const factory BarMarker.dalSegno() = DalSegno;

  /// D.C. al Fine
  const factory BarMarker.dalCapoAlFine() = DalCapoAlFine;

  /// D.S. al Coda
  const factory BarMarker.dalSegnoAlCoda() = DalSegnoAlCoda;

  /// 𝄐 Fermata
  const factory BarMarker.fermata() = Fermata;

  /// // Caesura (railroad tracks)
  const factory BarMarker.caesura() = Caesura;

  /// , Breath mark
  const factory BarMarker.breathMark() = BreathMark;
}
