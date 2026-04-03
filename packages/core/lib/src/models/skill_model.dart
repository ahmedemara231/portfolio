class TechnicalSkillModel {
  final String? id;
  final String icon;
  final String name;
  final String level;
  final int order;

  const TechnicalSkillModel({
    this.id,
    this.icon = '',
    this.name = '',
    this.level = '',
    this.order = 0,
  });

  factory TechnicalSkillModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return TechnicalSkillModel(
      id: id,
      icon: map['icon'] ?? '',
      name: map['name'] ?? '',
      level: map['level'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'name': name,
      'level': level,
      'order': order,
    };
  }

  TechnicalSkillModel copyWith({
    String? id,
    String? icon,
    String? name,
    String? level,
    int? order,
  }) {
    return TechnicalSkillModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      level: level ?? this.level,
      order: order ?? this.order,
    );
  }
}

class SoftSkillModel {
  final String? id;
  final String icon;
  final String name;
  final String description;
  final int order;

  const SoftSkillModel({
    this.id,
    this.icon = '',
    this.name = '',
    this.description = '',
    this.order = 0,
  });

  factory SoftSkillModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return SoftSkillModel(
      id: id,
      icon: map['icon'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'name': name,
      'description': description,
      'order': order,
    };
  }

  SoftSkillModel copyWith({
    String? id,
    String? icon,
    String? name,
    String? description,
    int? order,
  }) {
    return SoftSkillModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }
}
