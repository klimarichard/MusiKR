enum Accidental {
  doubleFlat,
  flat,
  natural,
  sharp,
  doubleSharp;

  int get semitoneOffset => const [-2, -1, 0, 1, 2][index];

  /// Unicode music symbol
  String get symbol => const ['𝄫', '♭', '', '♯', '𝄪'][index];
}
