class CvFile {
  final int? id;
  final String name;
  final String path;
  final DateTime addedAt;
  final bool isDefault;

  const CvFile({
    this.id,
    required this.name,
    required this.path,
    required this.addedAt,
    this.isDefault = false,
  });

  factory CvFile.fromMap(Map<String, dynamic> map) {
    return CvFile(
      id: map['id'] as int?,
      name: map['name'] as String,
      path: map['path'] as String,
      addedAt: DateTime.parse(map['added_at'] as String),
      isDefault: (map['is_default'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'path': path,
      'added_at': addedAt.toIso8601String(),
      'is_default': isDefault ? 1 : 0,
    };
  }

  CvFile copyWith({
    int? id,
    String? name,
    String? path,
    DateTime? addedAt,
    bool? isDefault,
  }) {
    return CvFile(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      addedAt: addedAt ?? this.addedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
