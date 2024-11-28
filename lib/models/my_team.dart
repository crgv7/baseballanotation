class MyTeam {
  final int? id;
  final String name;
  final String? imageUrl;
  final int wins;
  final int losses;
  final int runsScored;
  final int runsAllowed;

  MyTeam({
    this.id,
    required this.name,
    this.imageUrl,
    this.wins = 0,
    this.losses = 0,
    this.runsScored = 0,
    this.runsAllowed = 0,
  });

  MyTeam copyWith({
    int? id,
    String? name,
    String? imageUrl,
    int? wins,
    int? losses,
    int? runsScored,
    int? runsAllowed,
  }) {
    return MyTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      runsScored: runsScored ?? this.runsScored,
      runsAllowed: runsAllowed ?? this.runsAllowed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'wins': wins,
      'losses': losses,
      'runsScored': runsScored,
      'runsAllowed': runsAllowed,
    };
  }

  factory MyTeam.fromMap(Map<String, dynamic> map) {
    return MyTeam(
      id: map['id'] as int?,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      wins: map['wins'] as int,
      losses: map['losses'] as int,
      runsScored: map['runsScored'] as int,
      runsAllowed: map['runsAllowed'] as int,
    );
  }
}
