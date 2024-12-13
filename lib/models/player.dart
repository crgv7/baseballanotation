class Player {
  final int? id;
  final String name;
  final bool isPitcher;

  // Batting stats
  final int? hits;
  final int? atBats;
  final double? average;
  final int? homeRuns;
  final int? doubles; // New field for 2B
  final int? triples; // New field for 3B
  final int? rbi;
  final int? runs;
  final int? stolenBases;
  final int? hbp; // Hit By Pitch
  final int? sf; // Sacrifice Fly
  final int? bb; // Base on Balls (Walks)
  final double? obp; // On-base percentage
  final double? bbPercentage; // Base on balls percentage
  final double? slg; // Slugging percentage
  final double? babip; // Batting Average on Balls in Play
  final double? kPercentage;

  // Pitching stats
  final int? wins;
  final int? losses;
  final double? era; // Earned run average
  final int? strikeouts;
  final int? walks;
  final double? whip; // Walks + Hits per Inning Pitched
  final int? inningsPitched;
  final int? saves;

  Player({
    this.id,
    required this.name,
    required this.isPitcher,
    this.hits,
    this.atBats,
    this.average,
    this.homeRuns,
    this.doubles, // New field
    this.triples, // New field
    this.rbi,
    this.runs,
    this.stolenBases,
    this.hbp,
    this.sf,
    this.bb,
    this.obp,
    this.bbPercentage,
    this.slg,
    this.babip,
    this.kPercentage,
    this.wins,
    this.losses,
    this.era,
    this.strikeouts,
    this.walks,
    this.whip,
    this.inningsPitched,
    this.saves,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int?,
      name: map['name'] as String,
      isPitcher: (map['is_pitcher'] as int) == 1,
      hits: map['hits'] as int?,
      atBats: map['at_bats'] as int?,
      average: map['average'] as double?,
      homeRuns: map['home_runs'] as int?,
      doubles: map['doubles'] as int?, // New field
      triples: map['triples'] as int?, // New field
      rbi: map['rbi'] as int?,
      runs: map['runs'] as int?,
      stolenBases: map['stolen_bases'] as int?,
      hbp: map['hbp'] as int?,
      sf: map['sf'] as int?,
      bb: map['bb'] as int?,
      obp: map['obp'] as double?,
      bbPercentage: map['bb_percentage'] as double?,
      slg: map['slg'] as double?,
      babip: map['babip'] as double?,
      kPercentage: map['k_percentage'] as double?,
      wins: map['wins'] as int?,
      losses: map['losses'] as int?,
      era: map['era'] as double?,
      strikeouts: map['strikeouts'] as int?,
      walks: map['walks'] as int?,
      whip: map['whip'] as double?,
      inningsPitched: map['innings_pitched'] as int?,
      saves: map['saves'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_pitcher': isPitcher ? 1 : 0,
      'hits': hits,
      'at_bats': atBats,
      'average': average,
      'home_runs': homeRuns,
      'doubles': doubles, // New field
      'triples': triples, // New field
      'rbi': rbi,
      'runs': runs,
      'stolen_bases': stolenBases,
      'hbp': hbp,
      'sf': sf,
      'bb': bb,
      'obp': obp,
      'bb_percentage': bbPercentage,
      'slg': slg,
      'babip': babip,
      'k_percentage': kPercentage,
      'wins': wins,
      'losses': losses,
      'era': era,
      'strikeouts': strikeouts,
      'walks': walks,
      'whip': whip,
      'innings_pitched': inningsPitched,
      'saves': saves,
    };
  }

  Player copyWith({
    int? id,
    String? name,
    bool? isPitcher,
    int? hits,
    int? atBats,
    double? average,
    int? homeRuns,
    int? doubles, // New field
    int? triples, // New field
    int? rbi,
    int? runs,
    int? stolenBases,
    int? hbp,
    int? sf,
    int? bb,
    double? obp,
    double? bbPercentage,
    double? slg,
    double? babip,
    double? kPercentage,
    int? wins,
    int? losses,
    double? era,
    int? strikeouts,
    int? walks,
    double? whip,
    int? inningsPitched,
    int? saves,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isPitcher: isPitcher ?? this.isPitcher,
      hits: hits ?? this.hits,
      atBats: atBats ?? this.atBats,
      average: average ?? this.average,
      homeRuns: homeRuns ?? this.homeRuns,
      doubles: doubles ?? this.doubles, // New field
      triples: triples ?? this.triples, // New field
      rbi: rbi ?? this.rbi,
      runs: runs ?? this.runs,
      stolenBases: stolenBases ?? this.stolenBases,
      hbp: hbp ?? this.hbp,
      sf: sf ?? this.sf,
      bb: bb ?? this.bb,
      obp: obp ?? this.obp,
      bbPercentage: bbPercentage ?? this.bbPercentage,
      slg: slg ?? this.slg,
      babip: babip ?? this.babip,
      kPercentage: kPercentage ?? this.kPercentage,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      era: era ?? this.era,
      strikeouts: strikeouts ?? this.strikeouts,
      walks: walks ?? this.walks,
      whip: whip ?? this.whip,
      inningsPitched: inningsPitched ?? this.inningsPitched,
      saves: saves ?? this.saves,
    );
  }
}
