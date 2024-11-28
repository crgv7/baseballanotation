class Game {
  final int? id;
  final int myTeamId;
  final int opponentTeamId;
  final int myTeamRuns;
  final int opponentTeamRuns;
  final int year;
  final String? opponentTeamName; // Campo para almacenar temporalmente el nombre del equipo oponente

  Game({
    this.id,
    required this.myTeamId,
    required this.opponentTeamId,
    required this.myTeamRuns,
    required this.opponentTeamRuns,
    required this.year,
    this.opponentTeamName,
  });

  Game copyWith({
    int? id,
    int? myTeamId,
    int? opponentTeamId,
    int? myTeamRuns,
    int? opponentTeamRuns,
    int? year,
    String? opponentTeamName,
  }) {
    return Game(
      id: id ?? this.id,
      myTeamId: myTeamId ?? this.myTeamId,
      opponentTeamId: opponentTeamId ?? this.opponentTeamId,
      myTeamRuns: myTeamRuns ?? this.myTeamRuns,
      opponentTeamRuns: opponentTeamRuns ?? this.opponentTeamRuns,
      year: year ?? this.year,
      opponentTeamName: opponentTeamName ?? this.opponentTeamName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'myTeamId': myTeamId,
      'opponentTeamId': opponentTeamId,
      'myTeamRuns': myTeamRuns,
      'opponentTeamRuns': opponentTeamRuns,
      'year': year,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int?,
      myTeamId: map['myTeamId'] as int,
      opponentTeamId: map['opponentTeamId'] as int,
      myTeamRuns: map['myTeamRuns'] as int,
      opponentTeamRuns: map['opponentTeamRuns'] as int,
      year: map['year'] as int,
    );
  }
}
