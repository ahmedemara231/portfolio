class ToolModel {
  final String? id;
  final String name;
  final int order;

  const ToolModel({
    this.id,
    this.name = '',
    this.order = 0,
  });

  factory ToolModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return ToolModel(
      id: id,
      name: map['name'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'order': order,
    };
  }

  ToolModel copyWith({String? id, String? name, int? order}) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }
}
