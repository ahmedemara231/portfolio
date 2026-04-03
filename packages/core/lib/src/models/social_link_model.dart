class SocialLinkModel {
  final String? id;
  final String icon;
  final String url;
  final int order;

  const SocialLinkModel({
    this.id,
    this.icon = '',
    this.url = '',
    this.order = 0,
  });

  factory SocialLinkModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return SocialLinkModel(
      id: id,
      icon: map['icon'] ?? '',
      url: map['url'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'url': url,
      'order': order,
    };
  }

  SocialLinkModel copyWith({String? id, String? icon, String? url, int? order}) {
    return SocialLinkModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      order: order ?? this.order,
    );
  }
}
