enum NoteName {
  c,
  d,
  e,
  f,
  g,
  a,
  b;

  /// Semitone offset from C (equal temperament)
  int get semitones => const [0, 2, 4, 5, 7, 9, 11][index];

  String get displayName => name.toUpperCase();
}
