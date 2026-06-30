class KidProfile {
  final String id;
  final String name;
  final int age;
  final String? avatar;

  KidProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'avatar': avatar,
  };

  factory KidProfile.fromMap(Map<String, dynamic> map) {
    return KidProfile(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      avatar: map['avatar'],
    );
  }

  KidProfile copyWith({String? name, int? age, String? avatar}) {
    return KidProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
    );
  }
}
