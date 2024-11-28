class Team {
  final int? id;
  final String name;
  final String? imageUrl;
  final int wins;
  final int losses;
  final int runs;

  Team({
    this.id,
    required this.name,
    this.imageUrl,
    required this.wins,
    required this.losses,
    required this.runs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'wins': wins,
      'losses': losses,
      'runs': runs,
    };
  }

  static Team fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as int?,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      wins: map['wins'] as int,
      losses: map['losses'] as int,
      runs: map['runs'] as int,
    );
  }

  Team copyWith({
    int? id,
    String? name,
    String? imageUrl,
    int? wins,
    int? losses,
    int? runs,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      runs: runs ?? this.runs,
    );
  }
}
