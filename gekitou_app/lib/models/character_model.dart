class Character {
  final String id;
  final String name;
  final String? imageUrl;
  final int popularity;
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final String difficulty;
  final int level;
  Character({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.popularity,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.difficulty,
    this.level = 1,
  });

  factory Character.fromAniList({
    required String id,
    required String name,
    required String? imageUrl,
    required int popularity,
  }) {
    final difficultyLevel = popularity / 50.0;

    final baseHp = 80;
    final baseAttack = 15;
    final baseDefense = 10;
    final baseSpeed = 12;

    final hp = (baseHp + (difficultyLevel * 40)).toInt(); // 80-120
    final attack = (baseAttack + (difficultyLevel * 10)).toInt(); // 15-25
    final defense = (baseDefense + (difficultyLevel * 8)).toInt(); // 10-18
    final speed = (baseSpeed + (difficultyLevel * 8)).toInt(); // 12-20

    late String difficulty;
    if (popularity <= 15) {
      difficulty = 'easy';
    } else if (popularity <= 35) {
      difficulty = 'normal';
    } else {
      difficulty = 'hard';
    }

    return Character(
      id: id,
      name: name,
      imageUrl: imageUrl,
      popularity: popularity,
      hp: hp,
      attack: attack,
      defense: defense,
      speed: speed,
      difficulty: difficulty,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'popularity': popularity,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'speed': speed,
      'difficulty': difficulty,
      'level': level,
    };
  }

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      popularity: map['popularity'] ?? 0,
      hp: map['hp'] ?? 100,
      attack: map['attack'] ?? 15,
      defense: map['defense'] ?? 10,
      speed: map['speed'] ?? 12,
      difficulty: map['difficulty'] ?? 'normal',
      level: map['level'] ?? 1,
    );
  }

  Character copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? popularity,
    int? hp,
    int? attack,
    int? defense,
    int? speed,
    String? difficulty,
    int? level,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      popularity: popularity ?? this.popularity,
      hp: hp ?? this.hp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      difficulty: difficulty ?? this.difficulty,
      level: level ?? this.level,
    );
  }
}
