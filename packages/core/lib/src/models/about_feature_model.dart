class AboutFeatureModel {
  final String? id;
  final String icon;
  final String title;
  final String description;
  final int order;

  const AboutFeatureModel({
    this.id,
    this.icon = '',
    this.title = '',
    this.description = '',
    this.order = 0,
  });

  factory AboutFeatureModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return AboutFeatureModel(
      id: id,
      icon: map['icon'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'description': description,
      'order': order,
    };
  }

  AboutFeatureModel copyWith({
    String? id,
    String? icon,
    String? title,
    String? description,
    int? order,
  }) {
    return AboutFeatureModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }
}
