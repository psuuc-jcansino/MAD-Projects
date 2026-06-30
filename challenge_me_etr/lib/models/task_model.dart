class TaskModel {
  final int? id;
  final String description;
  final int categoryId;
  final bool isCompleted;
  final DateTime? completedAt;

  TaskModel({
    this.id,
    required this.description,
    required this.categoryId,
    this.isCompleted = false,
    this.completedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      description: map['description'] as String? ?? '',
      categoryId: map['categoryId'] as int? ?? 0,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'categoryId': categoryId,
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    int? id,
    String? description,
    int? categoryId,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
