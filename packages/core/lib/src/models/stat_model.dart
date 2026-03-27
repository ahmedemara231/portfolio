class StatModel {
  final String? id;
  final String value;
  final String label;
  final int order;

  const StatModel({
    this.id,
    this.value = '',
    this.label = '',
    this.order = 0,
  });

  factory StatModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return StatModel(
      id: id,
      value: map['value'] ?? '',
      label: map['label'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'label': label,
      'order': order,
    };
  }

  StatModel copyWith({String? id, String? value, String? label, int? order}) {
    return StatModel(
      id: id ?? this.id,
      value: value ?? this.value,
      label: label ?? this.label,
      order: order ?? this.order,
    );
  }
}
