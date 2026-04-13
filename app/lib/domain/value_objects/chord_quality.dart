enum ChordQuality {
  major,
  minor,
  dominant7,
  major7,
  minor7,
  diminished,
  augmented,
  sus2,
  sus4,
  halfDiminished,
  diminished7,
  minorMajor7,
  augmented7,
  majorFlat5,
  power; // 5th only

  /// Short display label used in the Smart Keyboard and chord symbol rendering
  String get label => switch (this) {
    ChordQuality.major        => '',
    ChordQuality.minor        => 'm',
    ChordQuality.dominant7    => '7',
    ChordQuality.major7       => 'maj7',
    ChordQuality.minor7       => 'm7',
    ChordQuality.diminished   => '°',
    ChordQuality.augmented    => '+',
    ChordQuality.sus2         => 'sus2',
    ChordQuality.sus4         => 'sus4',
    ChordQuality.halfDiminished => 'ø',
    ChordQuality.diminished7  => '°7',
    ChordQuality.minorMajor7  => 'mMaj7',
    ChordQuality.augmented7   => '+7',
    ChordQuality.majorFlat5   => 'maj♭5',
    ChordQuality.power        => '5',
  };
}
