class FamilyModel {
  final String id;
  final String name;
  final DateTime createdAt;

  FamilyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory FamilyModel.fromMap(String id, Map<String, dynamic> data) {
    return FamilyModel(
      id: id,
      name: data['name'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt,
    };
  }
} 