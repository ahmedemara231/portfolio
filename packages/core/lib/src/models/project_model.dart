class ProjectModel {
  final String? id;
  final String title;
  final String description;
  final String image;
  final List<String> tags;
  final String downloads;
  final double rating;
  final String codeUrl;
  final String liveUrl;
  final String googlePlayUrl;
  final String appStoreUrl;
  final String tagColor;
  final int order;

  const ProjectModel({
    this.id,
    this.title = '',
    this.description = '',
    this.image = '',
    this.tags = const [],
    this.downloads = '',
    this.rating = 0,
    this.codeUrl = '',
    this.liveUrl = '',
    this.googlePlayUrl = '',
    this.appStoreUrl = '',
    this.tagColor = '',
    this.order = 0,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return ProjectModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      downloads: map['downloads'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      codeUrl: map['codeUrl'] ?? '',
      liveUrl: map['liveUrl'] ?? '',
      googlePlayUrl: map['googlePlayUrl'] ?? '',
      appStoreUrl: map['appStoreUrl'] ?? '',
      tagColor: map['tagColor'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'tags': tags,
      'downloads': downloads,
      'rating': rating,
      'codeUrl': codeUrl,
      'liveUrl': liveUrl,
      'googlePlayUrl': googlePlayUrl,
      'appStoreUrl': appStoreUrl,
      'tagColor': tagColor,
      'order': order,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    List<String>? tags,
    String? downloads,
    double? rating,
    String? codeUrl,
    String? liveUrl,
    String? googlePlayUrl,
    String? appStoreUrl,
    String? tagColor,
    int? order,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      tags: tags ?? this.tags,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      codeUrl: codeUrl ?? this.codeUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      googlePlayUrl: googlePlayUrl ?? this.googlePlayUrl,
      appStoreUrl: appStoreUrl ?? this.appStoreUrl,
      tagColor: tagColor ?? this.tagColor,
      order: order ?? this.order,
    );
  }
}
