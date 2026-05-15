class SubjectModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String color;

  SubjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.color,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, String id) {
    return SubjectModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      color: map['color'] ?? '#6C63FF',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'color': color,
    };
  }
}